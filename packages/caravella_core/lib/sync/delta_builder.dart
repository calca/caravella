import 'package:sqflite/sqflite.dart';

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
///   "device_id": "uuid",
///   "device_name": "Device Name",
///   "timestamp": 1234567890,
///   "groups": [ ...full group JSON objects ],
///   "deleted_groups": [ "group-id-1", "group-id-2" ]
/// }
/// ```
class DeltaBuilder {
  static const _tag = 'sync.delta';

  final SyncDao _syncDao;
  final SqliteExpenseGroupRepository _repository;

  /// Creates a [DeltaBuilder] backed by the given [syncDao] and [repository].
  const DeltaBuilder({
    required SyncDao syncDao,
    required SqliteExpenseGroupRepository repository,
  })  : _syncDao = syncDao,
        _repository = repository;

  /// Builds an outgoing delta for the given [peerId].
  ///
  /// Only groups modified after the last sync with [peerId] are included.
  /// Each group is fully serialized via [ExpenseGroup.toJson()] so the
  /// receiver can reconstruct the complete model.
  Future<Map<String, dynamic>> buildDelta(
    Database db,
    String peerId,
  ) async {
    final lastSync = await _syncDao.getLastSyncTime(peerId) ?? 0;

    LoggerService.debug(
      'Building delta for peer=$peerId since=$lastSync',
      name: _tag,
    );

    // Fetch changed group rows (metadata only — we need the IDs). Both
    // queries are already scoped to groups [peerId] has been granted access
    // to — see SyncDao.grantGroupAccess.
    final changedRows = await _syncDao.getGroupsDeltaSince(lastSync, peerId);
    final deletedRows =
        await _syncDao.getDeletedGroupsSince(lastSync, peerId);

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

    final delta = <String, dynamic>{
      'device_id': identity.deviceId,
      'device_name': identity.deviceName,
      'timestamp': SyncClock.nowMs(),
      'groups': groups,
      'deleted_groups': deletedGroups,
    };

    LoggerService.info(
      'Delta built: ${groups.length} groups, '
      '${deletedGroups.length} deleted for peer=$peerId',
      name: _tag,
    );

    return delta;
  }

  /// Validates and returns a parsed delta received from a remote peer.
  ///
  /// Throws [FormatException] if required fields are missing.
  static Map<String, dynamic> parseDelta(Map<String, dynamic> raw) {
    if (!raw.containsKey('device_id') || raw['device_id'] is! String) {
      throw const FormatException('Delta missing required field: device_id');
    }
    if (!raw.containsKey('timestamp') || raw['timestamp'] is! int) {
      throw const FormatException('Delta missing required field: timestamp');
    }
    if (!raw.containsKey('groups') || raw['groups'] is! List) {
      throw const FormatException('Delta missing required field: groups');
    }
    if (!raw.containsKey('deleted_groups') ||
        raw['deleted_groups'] is! List) {
      throw const FormatException(
        'Delta missing required field: deleted_groups',
      );
    }

    return raw;
  }
}
