import 'dart:math';

import 'package:sqflite/sqflite.dart';

import 'package:caravella_core/data/sqlite_expense_group_repository.dart';
import 'package:caravella_core/data/sqlite_group_mapper.dart';
import 'package:caravella_core/data/sqlite_group_writer.dart';
import 'package:caravella_core/data/sqlite_tables.dart';
import 'package:caravella_core/model/expense_details.dart';
import 'package:caravella_core/model/expense_group.dart';
import 'package:caravella_core/model/second_currency.dart';
import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/delta_builder.dart';
import 'package:caravella_core/sync/models/sync_problem.dart';
import 'package:caravella_core/sync/models/sync_result.dart';
import 'package:caravella_core/sync/sync_dao.dart';
import 'package:caravella_core/sync/utils/sync_clock.dart';

/// Applies incoming sync deltas.
///
/// A group from a 2.5 device carries each expense's last-change time, its
/// deleted expenses and the time of its own fields (`_sync.expenses`,
/// `_sync.deleted_expenses`, `_sync.meta_updated_at`, see [DeltaBuilder]);
/// when this device has the group too, the two are **merged** (#728):
/// * each expense: the newer of the two copies; one only one side has is
///   kept, unless the other side deleted it later than its last change;
/// * the group's own fields (name, dates, people, budget, payments…): from
///   the side that changed them last, plus anyone an expense refers to;
/// * deleted expenses: both sides', remembered to pass on.
/// Nothing is written when the merge changes nothing here.
///
/// Otherwise — a new group, a group deleted here, or a group from an older
/// app — it is **Last Writer Wins** on the group's `updated_at`:
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
    // Deltas older than schema 2 don't know `payments`, `budget`,
    // `secondCurrency` or an expense's `original`: keep ours.
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
            columns: [
              'id',
              'updated_at',
              'meta_updated_at',
              'deleted',
              'device_id',
              'sync_version',
              'payments',
              'budget_amount',
              'budget_period',
              'second_currency',
            ],
            where: 'id = ?',
            whereArgs: [groupId],
          );

          final remoteStamps = _times(syncMeta['expenses']);
          final remoteTombstones =
              _times(syncMeta['deleted_expenses']) ?? const <String, int>{};
          final remoteMetaAt =
              syncMeta['meta_updated_at'] as int? ?? remoteUpdatedAt;

          // Both have it and the sender knows expense times: merge.
          if (remoteStamps != null &&
              localRows.isNotEmpty &&
              localRows.first['deleted'] == 0) {
            final changed = await _mergeGroup(
              txn,
              local: localRows.first,
              remoteJson: remoteJson,
              remoteStamps: remoteStamps,
              remoteTombstones: remoteTombstones,
              remoteMetaAt: remoteMetaAt,
              remoteSyncVersion: remoteSyncVersion,
              peerId: peerId,
            );
            changed ? applied++ : skipped++;
            continue;
          }

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

          // A peer on 2.4 doesn't know payments, budgets or second
          // currencies and sends the group without them: keep the ones this
          // device has (payments for people still in it; an expense's
          // original amount while the peer left its amount as it was).
          if (keepLocalPayments && localRows.isNotEmpty) {
            final ids = {for (final p in group.participants) p.id};
            final localExpenses = {
              for (final row in await txn.query(
                SqliteExpenseGroupRepository.tableExpenses,
                columns: ['id', 'amount', 'original'],
                where: 'group_id = ? AND original IS NOT NULL',
                whereArgs: [groupId],
              ))
                row['id'] as String: row,
            };
            group = group.copyWith(
              expenses: [
                for (final e in group.expenses)
                  switch (localExpenses[e.id]) {
                    final row? when row['amount'] == e.amount => e.copyWith(
                      original: SqliteGroupMapper.jsonColumn(
                        row['original'],
                        OriginalAmount.fromJson,
                      ),
                    ),
                    _ => e,
                  },
              ],
              secondCurrency: SqliteGroupMapper.jsonColumn(
                localRows.first['second_currency'],
                SecondCurrency.fromJson,
              ),
              payments: [
                for (final p in SqliteGroupMapper.paymentsFromColumn(
                  localRows.first['payments'],
                ))
                  if (ids.contains(p.fromId) && ids.contains(p.toId)) p,
              ],
              budget: SqliteGroupMapper.budgetFromColumns(localRows.first),
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
            metaUpdatedAt: remoteMetaAt,
            expenseStamps: remoteStamps ?? const {},
          );
          if (remoteStamps != null) {
            await _replaceTombstones(txn, groupId, remoteTombstones);
          }

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
  /// Sync metadata ([deviceId], [updatedAt], [syncVersion],
  /// [metaUpdatedAt]) is set in the same write to avoid a temporal window
  /// with stale values. Expenses get their time from [expenseStamps], else
  /// [updatedAt].
  Future<void> _saveGroupInTransaction(
    Transaction txn,
    ExpenseGroup group, {
    required String deviceId,
    required int updatedAt,
    required int syncVersion,
    int? metaUpdatedAt,
    Map<String, int> expenseStamps = const {},
  }) async {
    // The rows that changed only; an expense the remote copy doesn't have is
    // removed without a tombstone: it is not this device's deletion.
    await SqliteGroupWriter.write(
      txn,
      group,
      _groupRow(
        group,
        deviceId: deviceId,
        updatedAt: updatedAt,
        syncVersion: syncVersion,
        metaUpdatedAt: metaUpdatedAt ?? updatedAt,
      ),
      changedAt: updatedAt,
      expenseStamps: expenseStamps,
      recordDeletions: false,
    );
  }

  /// Merges a group both devices have, expense by expense (see the class
  /// doc). Returns whether anything changed here.
  Future<bool> _mergeGroup(
    Transaction txn, {
    required Map<String, Object?> local,
    required Map<String, dynamic> remoteJson,
    required Map<String, int> remoteStamps,
    required Map<String, int> remoteTombstones,
    required int remoteMetaAt,
    required int remoteSyncVersion,
    required String peerId,
  }) async {
    final groupId = local['id'] as String;
    const mapper = SqliteGroupMapper();
    final mine = await mapper.loadGroupById(txn, groupId);
    if (mine == null) return false;
    final theirs = ExpenseGroup.fromJson(remoteJson);

    final myStamps = {
      for (final row in await txn.query(
        SqliteExpenseGroupRepository.tableExpenses,
        columns: ['id', 'updated_at'],
        where: 'group_id = ?',
        whereArgs: [groupId],
      ))
        row['id'] as String: row['updated_at'] as int,
    };
    final myTombstones = {
      for (final row in await txn.query(
        kTableExpenseTombstones,
        where: 'group_id = ?',
        whereArgs: [groupId],
      ))
        row['expense_id'] as String: row['deleted_at'] as int,
    };
    final myMetaAt =
        local['meta_updated_at'] as int? ?? local['updated_at'] as int? ?? 0;
    final metaFromThem = remoteMetaAt > myMetaAt;
    var changed = metaFromThem;

    // Deleted expenses: the later deletion of each, from both sides.
    final tombstones = {...myTombstones};
    remoteTombstones.forEach((id, at) {
      if (at > (tombstones[id] ?? -1)) {
        tombstones[id] = at;
        changed = true;
      }
    });

    // Each expense: the newer copy, unless deleted after it last changed.
    final myExpenses = {for (final e in mine.expenses) e.id: e};
    final theirExpenses = {for (final e in theirs.expenses) e.id: e};
    final expenses = <ExpenseDetails>[];
    final stamps = <String, int>{};
    for (final id in {...myExpenses.keys, ...theirExpenses.keys}) {
      final my = myExpenses[id];
      final their = theirExpenses[id];
      final myAt = myStamps[id] ?? 0;
      final theirAt = remoteStamps[id] ?? 0;
      final takeTheirs = their != null && (my == null || theirAt > myAt);
      final at = takeTheirs ? theirAt : myAt;
      final deletedAt = tombstones[id];
      if (deletedAt != null && at <= deletedAt) {
        if (my != null) changed = true;
        continue;
      }
      if (takeTheirs) changed = true;
      if (tombstones.remove(id) != null) changed = true;
      expenses.add(takeTheirs ? their : my!);
      stamps[id] = at;
    }
    if (!changed) return false;

    // The group's own fields from the side that changed them last, plus
    // anyone and any category an expense refers to.
    final base = metaFromThem ? theirs : mine;
    final participants = [...base.participants];
    final categories = [...base.categories];
    for (final e in expenses) {
      if (!participants.any((p) => p.id == e.paidBy.id)) {
        participants.add(e.paidBy);
      }
      if (!categories.any((c) => c.id == e.category.id)) {
        categories.add(e.category);
      }
    }
    final ids = {for (final p in participants) p.id};
    final merged = base.copyWith(
      expenses: expenses,
      participants: participants,
      categories: categories,
      payments: [
        for (final p in base.payments)
          if (ids.contains(p.fromId) && ids.contains(p.toId)) p,
      ],
    );

    // A new local change: `updated_at` moves to now, so the merged group
    // goes on to the other devices this one syncs with.
    final now = SyncClock.nowMs();
    await SqliteGroupWriter.write(
      txn,
      merged,
      _groupRow(
        merged,
        deviceId: metaFromThem ? peerId : local['device_id'] as String? ?? '',
        updatedAt: now,
        syncVersion: max(local['sync_version'] as int? ?? 0, remoteSyncVersion),
        metaUpdatedAt: max(myMetaAt, remoteMetaAt),
      ),
      changedAt: now,
      expenseStamps: stamps,
      recordDeletions: false,
    );
    await _replaceTombstones(txn, groupId, tombstones);
    return true;
  }

  /// Makes [tombstones] (expense id → deletion time) the group's deleted
  /// expenses.
  Future<void> _replaceTombstones(
    Transaction txn,
    String groupId,
    Map<String, int> tombstones,
  ) async {
    await txn.delete(
      kTableExpenseTombstones,
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    for (final entry in tombstones.entries) {
      await txn.insert(kTableExpenseTombstones, {
        'expense_id': entry.key,
        'group_id': groupId,
        'deleted_at': entry.value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// An id → time map from a delta, or null when the sender sent none (an
  /// app before 2.5) or something unreadable.
  static Map<String, int>? _times(Object? value) {
    if (value is! Map) return null;
    final times = <String, int>{};
    for (final entry in value.entries) {
      final at = entry.value;
      if (entry.key is! String || at is! int) return null;
      times[entry.key as String] = at;
    }
    return times;
  }

  /// The `groups` row for [group] with these sync columns.
  static Map<String, Object?> _groupRow(
    ExpenseGroup group, {
    required String deviceId,
    required int updatedAt,
    required int syncVersion,
    required int metaUpdatedAt,
  }) => {
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
    ...SqliteGroupMapper.budgetToColumns(group.budget),
    'second_currency': SqliteGroupMapper.toJsonColumn(
      group.secondCurrency?.toJson(),
    ),
    'device_id': deviceId,
    'updated_at': updatedAt,
    'meta_updated_at': metaUpdatedAt,
    'deleted': 0,
    'sync_version': syncVersion,
  };
}
