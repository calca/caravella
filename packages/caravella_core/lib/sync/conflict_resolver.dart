import 'package:sqflite/sqflite.dart';

import 'package:caravella_core/data/sqlite_expense_group_repository.dart';
import 'package:caravella_core/data/sqlite_group_mapper.dart';
import 'package:caravella_core/model/expense_group.dart';
import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/delta_builder.dart';
import 'package:caravella_core/sync/models/sync_problem.dart';
import 'package:caravella_core/sync/models/sync_result.dart';
import 'package:caravella_core/sync/sync_dao.dart';
import 'package:caravella_core/sync/utils/sync_clock.dart';

/// Applies incoming sync deltas using a **Last Writer Wins** (LWW) strategy.
///
/// For each remote group the resolver compares `updated_at` timestamps:
/// * If the group does not exist locally → upsert it.
/// * If the remote timestamp is more recent → overwrite local data.
/// * Otherwise → skip (local copy is newer or identical).
///
/// Soft-deleted groups follow the same LWW logic.
/// The entire operation runs inside a single database transaction.
class ConflictResolver {
  static const _tag = 'sync.conflict';

  final SyncDao _syncDao;

  /// Creates a [ConflictResolver] backed by the given [syncDao].
  const ConflictResolver({required SyncDao syncDao}) : _syncDao = syncDao;

  /// Processes an incoming [delta] received over [channel] and returns a
  /// [SyncResult] with counters of applied / skipped / errored groups.
  ///
  /// The entire merge runs inside a single database transaction for atomicity.
  ///
  /// [checkGrants] false skips the per-group grant check: only for Google
  /// Drive, where every snapshot comes from the user's own devices (the
  /// same Google account), with all their groups.
  Future<SyncResult> applyDelta(
    Database db,
    Map<String, dynamic> delta,
    String channel, {
    bool checkGrants = true,
  }) async {
    final parsed = DeltaBuilder.parseDelta(delta);

    final peerId = parsed['device_id'] as String;
    // Deltas older than schema 2 don't know `payments`: keep ours.
    final keepLocalPayments = (parsed['schema'] as int? ?? 1) < 2;
    final peerName = parsed['device_name'] as String? ?? 'Unknown';
    final remoteGroups = (parsed['groups'] as List)
        .cast<Map<String, dynamic>>();
    final deletedGroups = (parsed['deleted_groups'] as List)
        .cast<Map<String, dynamic>>();

    int applied = 0;
    int skipped = 0;
    int errors = 0;
    final touchedGroupIds = <String>{};
    final newGroupIds = <String>{};
    final problems = <SyncProblem>[];
    // One per error: what went wrong and with which group, for the user.
    void problem(SyncProblemReason reason, [String? groupId]) {
      errors++;
      problems.add(
        SyncProblem(
          reason: reason,
          channel: channel,
          peerId: peerId,
          peerName: parsed['device_name'] as String?,
          groupId: groupId,
          at: DateTime.fromMillisecondsSinceEpoch(
            SyncClock.nowMs(),
            isUtc: true,
          ),
        ),
      );
    }

    LoggerService.info(
      'Applying delta from peer=$peerId ($peerName): '
      '${remoteGroups.length} groups, ${deletedGroups.length} deletions',
      name: _tag,
    );

    await db.transaction((txn) async {
      // ------------------------------------------------------------------
      // 1. Upsert / merge groups
      // ------------------------------------------------------------------
      for (final remoteJson in remoteGroups) {
        String? groupId;
        try {
          final syncMeta =
              remoteJson['_sync'] as Map<String, dynamic>? ?? const {};
          final remoteUpdatedAt = syncMeta['updated_at'] as int? ?? 0;
          final remoteSyncVersion = syncMeta['sync_version'] as int? ?? 0;

          groupId = remoteJson['id'] as String?;
          if (groupId == null) {
            LoggerService.warning('Skipping group with null ID', name: _tag);
            problem(SyncProblemReason.unreadable);
            continue;
          }

          // Defense in depth: independently verify *this* device granted
          // the peer access to this group, rather than trusting that the
          // sender only ever includes groups it was granted — a buggy or
          // compromised peer could otherwise push arbitrary groups.
          if (checkGrants && !await _isGrantedInTxn(txn, peerId, groupId)) {
            LoggerService.warning(
              'Rejecting group $groupId from peer=$peerId — not granted',
              name: _tag,
            );
            problem(SyncProblemReason.notShared, groupId);
            continue;
          }

          touchedGroupIds.add(groupId);

          // Check if we already have this group locally
          final localRows = await txn.query(
            SqliteExpenseGroupRepository.tableGroups,
            columns: ['id', 'updated_at', 'payments'],
            where: 'id = ?',
            whereArgs: [groupId],
          );

          if (localRows.isNotEmpty) {
            final localUpdatedAt = localRows.first['updated_at'] as int? ?? 0;

            if (remoteUpdatedAt <= localUpdatedAt) {
              LoggerService.debug(
                'Skipping group $groupId — local is newer or equal '
                '(local=$localUpdatedAt, remote=$remoteUpdatedAt)',
                name: _tag,
              );
              skipped++;
              continue;
            }
          }

          // Parse the full ExpenseGroup from the remote JSON
          var group = ExpenseGroup.fromJson(remoteJson);

          // A peer on 2.4 doesn't know payments and sends the group without
          // them: keep the ones this device has, for people still in it.
          if (keepLocalPayments && localRows.isNotEmpty) {
            final ids = {for (final p in group.participants) p.id};
            group = group.copyWith(
              payments: [
                for (final p in SqliteGroupMapper.paymentsFromColumn(
                  localRows.first['payments'],
                ))
                  if (ids.contains(p.fromId) && ids.contains(p.toId)) p,
              ],
            );
          }

          // Save via the repository's transaction-aware pattern with sync
          // metadata set in the same insert (avoids temporal inconsistency).
          await _saveGroupInTransaction(
            txn,
            group,
            deviceId: peerId,
            updatedAt: remoteUpdatedAt,
            syncVersion: remoteSyncVersion,
          );

          applied++;
          if (localRows.isEmpty) newGroupIds.add(groupId);
        } catch (e, st) {
          LoggerService.error(
            'Error applying remote group',
            name: _tag,
            error: e,
            stackTrace: st,
          );
          problem(SyncProblemReason.unreadable, groupId);
        }
      }

      // ------------------------------------------------------------------
      // 2. Handle deleted groups
      // ------------------------------------------------------------------
      for (final entry in deletedGroups) {
        String? groupId;
        try {
          groupId = entry['id'] as String?;
          final remoteUpdatedAt = entry['updated_at'] as int? ?? 0;

          if (groupId == null) {
            problem(SyncProblemReason.unreadable);
            continue;
          }

          if (checkGrants && !await _isGrantedInTxn(txn, peerId, groupId)) {
            LoggerService.warning(
              'Rejecting deletion of $groupId from peer=$peerId — not granted',
              name: _tag,
            );
            problem(SyncProblemReason.notShared, groupId);
            continue;
          }

          touchedGroupIds.add(groupId);

          final localRows = await txn.query(
            SqliteExpenseGroupRepository.tableGroups,
            columns: ['id', 'updated_at', 'deleted'],
            where: 'id = ?',
            whereArgs: [groupId],
          );

          if (localRows.isEmpty) {
            // Never had this group — nothing to delete.
            skipped++;
            continue;
          }

          final localUpdatedAt = localRows.first['updated_at'] as int? ?? 0;

          if (remoteUpdatedAt <= localUpdatedAt) {
            skipped++;
            continue;
          }

          await txn.update(
            SqliteExpenseGroupRepository.tableGroups,
            {'deleted': 1, 'updated_at': remoteUpdatedAt},
            where: 'id = ?',
            whereArgs: [groupId],
          );
          applied++;
        } catch (e, st) {
          LoggerService.error(
            'Error applying remote deletion',
            name: _tag,
            error: e,
            stackTrace: st,
          );
          problem(SyncProblemReason.unreadable, groupId);
        }
      }
    });

    // ------------------------------------------------------------------
    // 3. Record sync log & device meta
    // ------------------------------------------------------------------
    await _syncDao.insertSyncLog(
      peerId: peerId,
      channel: channel,
      deltaSent: 0,
      deltaRecv: applied,
    );

    await _syncDao.upsertDeviceMeta(
      deviceId: peerId,
      deviceName: peerName,
      lastSeen: SyncClock.nowMs(),
    );

    final result = SyncResult(
      applied: applied,
      skipped: skipped,
      errors: errors,
      channel: channel,
      peerId: peerId,
      syncedAt: DateTime.fromMillisecondsSinceEpoch(
        SyncClock.nowMs(),
        isUtc: true,
      ),
      groupIds: touchedGroupIds,
      newGroupIds: newGroupIds,
      peerName: parsed['device_name'] as String?,
      problems: problems,
    );

    LoggerService.info('Delta applied: $result', name: _tag);

    return result;
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  /// Whether [peerId] has been granted access to [groupId], queried through
  /// the given [txn] rather than [_syncDao]'s own `Database` reference —
  /// querying the outer `Database` from inside an active `db.transaction()`
  /// callback on the same connection can deadlock, so every read/write in
  /// here must go through [txn] (mirrors [_saveGroupInTransaction]).
  Future<bool> _isGrantedInTxn(
    Transaction txn,
    String peerId,
    String groupId,
  ) async {
    final rows = await txn.query(
      SqliteExpenseGroupRepository.tablePairedDeviceGroups,
      columns: ['device_id'],
      where: 'device_id = ? AND group_id = ?',
      whereArgs: [peerId, groupId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Saves a full [ExpenseGroup] inside an existing [txn].
  ///
  /// Mirrors the write logic of
  /// [SqliteExpenseGroupRepository.saveGroup] but operates on a
  /// [Transaction] rather than acquiring a new one.
  ///
  /// Sync metadata ([deviceId], [updatedAt], [syncVersion]) is set in the
  /// same INSERT to avoid a temporal window with stale values.
  Future<void> _saveGroupInTransaction(
    Transaction txn,
    ExpenseGroup group, {
    required String deviceId,
    required int updatedAt,
    required int syncVersion,
  }) async {
    // Upsert group row with sync columns set atomically.
    await txn.insert(SqliteExpenseGroupRepository.tableGroups, {
      'id': group.id,
      'title': group.title,
      'currency': group.currency,
      'start_date': group.startDate?.millisecondsSinceEpoch,
      'end_date': group.endDate?.millisecondsSinceEpoch,
      'timestamp': group.timestamp.millisecondsSinceEpoch,
      'pinned': group.pinned ? 1 : 0,
      'archived': group.archived ? 1 : 0,
      'file': group.file,
      'color': group.color,
      'notification_enabled': group.notificationEnabled ? 1 : 0,
      'group_type': group.groupType?.toJson(),
      'auto_location_enabled': group.autoLocationEnabled ? 1 : 0,
      'sync_enabled': group.syncEnabled ? 1 : 0,
      'payments': SqliteGroupMapper.paymentsToColumn(group.payments),
      'device_id': deviceId,
      'updated_at': updatedAt,
      'deleted': 0,
      'sync_version': syncVersion,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Delete existing child rows
    await txn.delete(
      SqliteExpenseGroupRepository.tableParticipants,
      where: 'group_id = ?',
      whereArgs: [group.id],
    );
    await txn.delete(
      SqliteExpenseGroupRepository.tableCategories,
      where: 'group_id = ?',
      whereArgs: [group.id],
    );
    await txn.delete(
      SqliteExpenseGroupRepository.tableExpenses,
      where: 'group_id = ?',
      whereArgs: [group.id],
    );

    // Re-insert participants
    for (final p in group.participants) {
      await txn.insert(SqliteExpenseGroupRepository.tableParticipants, {
        'id': p.id,
        'group_id': group.id,
        'name': p.name,
      });
    }

    // Re-insert categories
    for (final c in group.categories) {
      await txn.insert(SqliteExpenseGroupRepository.tableCategories, {
        'id': c.id,
        'group_id': group.id,
        'name': c.name,
      });
    }

    // Re-insert expenses + attachments
    const mapper = SqliteGroupMapper();
    for (final expense in group.expenses) {
      await txn.insert(
        SqliteExpenseGroupRepository.tableExpenses,
        mapper.expenseToMap(expense, group.id),
      );

      for (final attachment in expense.attachments) {
        await txn.insert(SqliteExpenseGroupRepository.tableAttachments, {
          'expense_id': expense.id,
          'file_path': attachment,
        });
      }
    }
  }
}
