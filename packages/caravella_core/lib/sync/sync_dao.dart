import 'package:sqflite/sqflite.dart';

import 'package:caravella_core/data/sqlite_expense_group_repository.dart';
import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/models/paired_device.dart';
import 'package:caravella_core/sync/utils/sync_clock.dart';

/// Data-access object for sync-specific queries against the SQLite database.
///
/// All methods operate on the sync metadata tables and columns added in
/// schema v2 (`device_id`, `updated_at`, `deleted`, `sync_version`,
/// `device_meta`, `sync_log`).
class SyncDao {
  static const _tag = 'sync.dao';

  /// The underlying sqflite [Database].
  final Database db;

  /// Creates a [SyncDao] backed by the given [db].
  const SyncDao(this.db);

  // ---------------------------------------------------------------------------
  // Group delta queries
  // ---------------------------------------------------------------------------

  /// Returns non-deleted, sync-enabled groups whose `updated_at` is strictly
  /// greater than [timestampMs].
  ///
  /// Only groups explicitly marked as shared (`sync_enabled = 1`) are
  /// eligible to leave the device — this is the privacy boundary between
  /// local-only and shared groups.
  ///
  /// Each entry is a raw row map from the `groups` table.
  Future<List<Map<String, dynamic>>> getGroupsDeltaSince(
    int timestampMs,
  ) async {
    final rows = await db.query(
      SqliteExpenseGroupRepository.tableGroups,
      where: 'updated_at > ? AND deleted = 0 AND sync_enabled = 1',
      whereArgs: [timestampMs],
      orderBy: 'updated_at ASC',
    );
    LoggerService.debug(
      'getGroupsDeltaSince($timestampMs) → ${rows.length} groups',
      name: _tag,
    );
    return rows;
  }

  /// Returns soft-deleted, sync-enabled groups whose `updated_at` is
  /// strictly greater than [timestampMs].
  ///
  /// Same `sync_enabled = 1` boundary as [getGroupsDeltaSince] — deletions
  /// of groups that were never shared must not leak to peers either.
  Future<List<Map<String, dynamic>>> getDeletedGroupsSince(
    int timestampMs,
  ) async {
    final rows = await db.query(
      SqliteExpenseGroupRepository.tableGroups,
      where: 'updated_at > ? AND deleted = 1 AND sync_enabled = 1',
      whereArgs: [timestampMs],
      orderBy: 'updated_at ASC',
    );
    LoggerService.debug(
      'getDeletedGroupsSince($timestampMs) → ${rows.length} groups',
      name: _tag,
    );
    return rows;
  }

  // ---------------------------------------------------------------------------
  // Group sync metadata
  // ---------------------------------------------------------------------------

  /// Updates only the sync-specific columns for an existing group row.
  Future<void> upsertGroupSyncMeta(
    String groupId, {
    required String deviceId,
    required int updatedAt,
    required int syncVersion,
  }) async {
    await db.update(
      SqliteExpenseGroupRepository.tableGroups,
      {
        'device_id': deviceId,
        'updated_at': updatedAt,
        'sync_version': syncVersion,
      },
      where: 'id = ?',
      whereArgs: [groupId],
    );
    LoggerService.debug(
      'upsertGroupSyncMeta($groupId, v=$syncVersion)',
      name: _tag,
    );
  }

  /// Marks a group as soft-deleted by setting `deleted = 1` and updating the
  /// `updated_at` timestamp.
  Future<void> softDeleteGroup(String groupId) async {
    final nowMs = SyncClock.nowMs();
    await db.update(
      SqliteExpenseGroupRepository.tableGroups,
      {'deleted': 1, 'updated_at': nowMs},
      where: 'id = ?',
      whereArgs: [groupId],
    );
    LoggerService.info('Soft-deleted group $groupId', name: _tag);
  }

  // ---------------------------------------------------------------------------
  // Sync log
  // ---------------------------------------------------------------------------

  /// Returns the most recent `synced_at` timestamp for the given [peerId],
  /// or `null` if no sync has been recorded for that peer.
  Future<int?> getLastSyncTime(String peerId) async {
    final rows = await db.query(
      SqliteExpenseGroupRepository.tableSyncLog,
      columns: ['synced_at'],
      where: 'peer_id = ?',
      whereArgs: [peerId],
      orderBy: 'synced_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['synced_at'] as int;
  }

  /// Records a sync exchange in the `sync_log` table.
  Future<void> insertSyncLog({
    required String peerId,
    required String channel,
    required int deltaSent,
    required int deltaRecv,
  }) async {
    final nowMs = SyncClock.nowMs();
    await db.insert(SqliteExpenseGroupRepository.tableSyncLog, {
      'peer_id': peerId,
      'channel': channel,
      'synced_at': nowMs,
      'delta_sent': deltaSent,
      'delta_recv': deltaRecv,
    });
    LoggerService.debug(
      'insertSyncLog(peer=$peerId, ch=$channel, '
      'sent=$deltaSent, recv=$deltaRecv)',
      name: _tag,
    );
  }

  /// Returns the last [limit] sync-log entries, newest first.
  Future<List<Map<String, dynamic>>> getSyncHistory({int limit = 20}) async {
    return db.query(
      SqliteExpenseGroupRepository.tableSyncLog,
      orderBy: 'synced_at DESC',
      limit: limit,
    );
  }

  // ---------------------------------------------------------------------------
  // Device metadata
  // ---------------------------------------------------------------------------

  /// Inserts or replaces a row in the `device_meta` table.
  Future<void> upsertDeviceMeta({
    required String deviceId,
    required String deviceName,
    required int lastSeen,
    String? vectorClock,
  }) async {
    await db.insert(
      SqliteExpenseGroupRepository.tableDeviceMeta,
      {
        'device_id': deviceId,
        'device_name': deviceName,
        'last_seen': lastSeen,
        'vector_clock': vectorClock,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    LoggerService.debug(
      'upsertDeviceMeta(id=$deviceId, name=$deviceName)',
      name: _tag,
    );
  }

  // ---------------------------------------------------------------------------
  // Group sync status
  // ---------------------------------------------------------------------------

  /// Returns the sync status for a specific group.
  ///
  /// Compares the group's `updated_at` against the most recent `synced_at`
  /// from the sync_log. Returns `true` if the group is fully synced (i.e. the
  /// last sync happened after the last update), `false` otherwise.
  ///
  /// Uses the global last-sync time because each sync exchange transfers the
  /// full delta for all groups — so a single successful sync brings every
  /// shared group up to date.
  Future<bool> isGroupSynced(String groupId) async {
    final groupRows = await db.query(
      SqliteExpenseGroupRepository.tableGroups,
      columns: ['updated_at', 'sync_enabled'],
      where: 'id = ?',
      whereArgs: [groupId],
    );
    if (groupRows.isEmpty) return false;

    final syncEnabled = (groupRows.first['sync_enabled'] as int?) == 1;
    if (!syncEnabled) return true; // Not a shared group — always "synced"

    final updatedAt = groupRows.first['updated_at'] as int? ?? 0;

    final syncRows = await db.query(
      SqliteExpenseGroupRepository.tableSyncLog,
      columns: ['MAX(synced_at) as last_sync'],
    );
    if (syncRows.isEmpty || syncRows.first['last_sync'] == null) return false;

    final lastSync = syncRows.first['last_sync'] as int;
    return lastSync >= updatedAt;
  }

  /// Returns the sync status for all sync-enabled groups as a map of
  /// `groupId → isSynced`.
  Future<Map<String, bool>> getAllGroupSyncStatuses() async {
    final groups = await db.query(
      SqliteExpenseGroupRepository.tableGroups,
      columns: ['id', 'updated_at', 'sync_enabled'],
      where: 'deleted = 0 AND sync_enabled = 1',
    );
    if (groups.isEmpty) return {};

    final syncRows = await db.query(
      SqliteExpenseGroupRepository.tableSyncLog,
      columns: ['MAX(synced_at) as last_sync'],
    );
    final lastSync = (syncRows.isNotEmpty)
        ? (syncRows.first['last_sync'] as int?) ?? 0
        : 0;

    final result = <String, bool>{};
    for (final row in groups) {
      final groupId = row['id'] as String;
      final updatedAt = row['updated_at'] as int? ?? 0;
      result[groupId] = lastSync >= updatedAt;
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Paired devices
  // ---------------------------------------------------------------------------

  /// Records (or refreshes) a mutual pairing with [deviceId], establishing
  /// it as trusted for automatic LAN sync.
  Future<void> addPairedDevice({
    required String deviceId,
    required String deviceName,
    required String platform,
  }) async {
    await db.insert(
      SqliteExpenseGroupRepository.tablePairedDevices,
      {
        'device_id': deviceId,
        'device_name': deviceName,
        'platform': platform,
        'paired_at': SyncClock.nowMs(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    LoggerService.info(
      'Paired with device $deviceId ($deviceName)',
      name: _tag,
    );
  }

  /// Whether [deviceId] has completed the pairing handshake and is trusted
  /// for automatic LAN sync.
  Future<bool> isPaired(String deviceId) async {
    final rows = await db.query(
      SqliteExpenseGroupRepository.tablePairedDevices,
      columns: ['device_id'],
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Returns all paired devices, most recently paired first.
  Future<List<PairedDevice>> getPairedDevices() async {
    final rows = await db.query(
      SqliteExpenseGroupRepository.tablePairedDevices,
      orderBy: 'paired_at DESC',
    );
    return rows.map(PairedDevice.fromRow).toList();
  }

  /// Removes a pairing, revoking [deviceId]'s trust for automatic LAN sync.
  Future<void> removePairedDevice(String deviceId) async {
    await db.delete(
      SqliteExpenseGroupRepository.tablePairedDevices,
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
    LoggerService.info('Removed pairing with device $deviceId', name: _tag);
  }
}
