import 'package:sqflite/sqflite.dart';

import 'package:caravella_core/data/newer_format_exception.dart';
import 'package:caravella_core/data/sqlite_expense_group_repository.dart';
import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/device_identity.dart';
import 'package:caravella_core/sync/sync_dao.dart';
import 'package:caravella_core/sync/utils/sync_clock.dart';

/// Builds outgoing sync-delta payloads from local SQLite data and validates
/// incoming ones.
///
/// A delta is a JSON-serializable [Map] with the following shape:
/// ```json
/// {
///   "schema": 2,
///   "device_id": "uuid",
///   "device_name": "Device Name",
///   "timestamp": 1234567890,
///   "groups": [ ...full group JSON objects ],
///   "deleted_groups": [ "group-id-1", "group-id-2" ]
/// }
/// ```
class DeltaBuilder {
  static const _tag = 'sync.delta';

  /// Version of the delta format this app writes and can read.
  ///
  /// A newer app may add fields this one doesn't know: storing its groups
  /// would drop them, and sending them back would erase them on the newer
  /// device. So [parseDelta] refuses a delta with a higher version. Deltas
  /// from 2.4.0 have no `schema` field and count as version 1.
  ///
  /// 2: groups carry `payments` (Settle up). An older peer drops them, so
  /// `ConflictResolver` keeps this device's when a version 1 delta replaces
  /// a group.
  static const int schemaVersion = 2;

  final SyncDao _syncDao;
  final SqliteExpenseGroupRepository _repository;

  /// Creates a [DeltaBuilder] backed by the given [syncDao] and [repository].
  const DeltaBuilder({
    required SyncDao syncDao,
    required SqliteExpenseGroupRepository repository,
  }) : _syncDao = syncDao,
       _repository = repository;

  /// Builds an outgoing delta for the given [peerId].
  ///
  /// Only groups modified after the last sync with [peerId] are included.
  /// Each group is fully serialized via [ExpenseGroup.toJson()] so the
  /// receiver can reconstruct the complete model.
  Future<Map<String, dynamic>> buildDelta(Database db, String peerId) async {
    final lastSync = await _syncDao.getLastSyncTime(peerId) ?? 0;

    LoggerService.debug(
      'Building delta for peer=$peerId since=$lastSync',
      name: _tag,
    );

    // Fetch changed group rows (metadata only — we need the IDs). Both
    // queries are already scoped to groups [peerId] has been granted access
    // to — see SyncDao.grantGroupAccess.
    final changedRows = await _syncDao.getGroupsDeltaSince(lastSync, peerId);
    final deletedRows = await _syncDao.getDeletedGroupsSince(lastSync, peerId);
    final delta = await _assemble(changedRows, deletedRows);

    LoggerService.info(
      'Delta built: ${(delta['groups'] as List).length} groups, '
      '${(delta['deleted_groups'] as List).length} deleted for peer=$peerId',
      name: _tag,
    );

    return delta;
  }

  /// Builds this device's full snapshot for Google Drive: every group and
  /// every tombstone, in the same format as [buildDelta]. The user's other
  /// devices merge it with Last Writer Wins, so sending all of it each time
  /// is safe (unchanged groups are skipped there).
  Future<Map<String, dynamic>> buildSnapshot() async {
    final snapshot = await _assemble(
      await _syncDao.getAllGroupRows(),
      await _syncDao.getAllDeletedGroupRows(),
    );
    LoggerService.info(
      'Snapshot built: ${(snapshot['groups'] as List).length} groups, '
      '${(snapshot['deleted_groups'] as List).length} deleted',
      name: _tag,
    );
    return snapshot;
  }

  /// The delta for these group rows and tombstone rows.
  Future<Map<String, dynamic>> _assemble(
    List<Map<String, dynamic>> changedRows,
    List<Map<String, dynamic>> deletedRows,
  ) async {
    // Load full group objects for each changed row
    final groups = <Map<String, dynamic>>[];
    for (final row in changedRows) {
      final groupId = row['id'] as String;
      final result = await _repository.getGroupById(groupId);
      if (result.isSuccess && result.data != null) {
        final json = result.data!.toJson();
        // Attach sync metadata the receiver needs for conflict resolution
        json['_sync'] = {
          'device_id': row['device_id'],
          'updated_at': row['updated_at'],
          'sync_version': row['sync_version'],
        };
        groups.add(json);
      }
    }

    // Collect IDs + updated_at for deleted groups
    final deletedGroups = deletedRows.map((row) {
      return {
        'id': row['id'] as String,
        'updated_at': row['updated_at'] as int,
      };
    }).toList();

    final identity = DeviceIdentity.instance;

    return <String, dynamic>{
      'schema': schemaVersion,
      'device_id': identity.deviceId,
      'device_name': identity.deviceName,
      'timestamp': SyncClock.nowMs(),
      'groups': groups,
      'deleted_groups': deletedGroups,
    };
  }

  /// Validates and returns a parsed delta received from a remote peer.
  ///
  /// Throws [FormatException] if required fields are missing, and
  /// [NewerFormatException] if it comes from a newer app (see
  /// [schemaVersion]).
  static Map<String, dynamic> parseDelta(Map<String, dynamic> raw) {
    final schema = raw['schema'] ?? 1;
    if (schema is! int) {
      throw const FormatException('Delta has an invalid schema field');
    }
    if (schema > schemaVersion) {
      throw NewerFormatException('Sync delta', schema);
    }
    if (!raw.containsKey('device_id') || raw['device_id'] is! String) {
      throw const FormatException('Delta missing required field: device_id');
    }
    if (!raw.containsKey('timestamp') || raw['timestamp'] is! int) {
      throw const FormatException('Delta missing required field: timestamp');
    }
    if (!raw.containsKey('groups') || raw['groups'] is! List) {
      throw const FormatException('Delta missing required field: groups');
    }
    if (!raw.containsKey('deleted_groups') || raw['deleted_groups'] is! List) {
      throw const FormatException(
        'Delta missing required field: deleted_groups',
      );
    }

    return raw;
  }
}
