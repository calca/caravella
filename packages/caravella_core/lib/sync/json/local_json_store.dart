import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:caravella_core/model/expense_group.dart';
import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/device_identity.dart';
import 'package:caravella_core/sync/json/group_serializer.dart';
import 'package:caravella_core/sync/utils/sync_clock.dart';

/// Reads and writes per-device JSON shard files to the local filesystem.
///
/// Shard files are stored under
/// `${ApplicationDocumentsDirectory}/sync_shards/{deviceId}.json`.
///
/// Writes use an atomic pattern (write to `.tmp` then rename) to prevent
/// partial reads.
class LocalJsonStore {
  static const _tag = 'sync.json.store';
  static const _shardDir = 'sync_shards';

  /// Returns the directory where shard files are stored, creating it if needed.
  Future<Directory> _shardDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _shardDir));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
      LoggerService.debug('Created shard directory: ${dir.path}', name: _tag);
    }
    return dir;
  }

  /// Writes a device shard file for [deviceId].
  ///
  /// Serializes the given [groups] and [deletedGroups] into a sync payload
  /// via [GroupSerializer] and writes it atomically (write to `.tmp` then
  /// rename).
  Future<void> writeDeviceShard(
    String deviceId,
    List<ExpenseGroup> groups, {
    List<Map<String, dynamic>> deletedGroups = const [],
  }) async {
    final dir = await _shardDirectory();
    final target = File(p.join(dir.path, '$deviceId.json'));
    final tmp = File(p.join(dir.path, '$deviceId.json.tmp'));

    try {
      final identity = DeviceIdentity.instance;
      final payload = GroupSerializer.serializePayload(
        groups: groups,
        deviceId: deviceId,
        deviceName: identity.deviceName,
        deletedGroups: deletedGroups,
      );

      // Atomic write: .tmp → rename
      await tmp.writeAsString(payload, flush: true);
      await tmp.rename(target.path);

      LoggerService.info(
        'Wrote shard for device=$deviceId '
        '(${groups.length} groups, ${deletedGroups.length} deleted)',
        name: _tag,
      );
    } catch (e, st) {
      // Clean up tmp file on failure
      if (tmp.existsSync()) {
        try {
          await tmp.delete();
        } catch (_) {}
      }
      LoggerService.error(
        'Failed to write shard for device=$deviceId',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Reads a device shard file for [deviceId].
  ///
  /// Returns the raw JSON string, or `null` if the file does not exist.
  Future<String?> readDeviceShard(String deviceId) async {
    final dir = await _shardDirectory();
    final file = File(p.join(dir.path, '$deviceId.json'));

    if (!file.existsSync()) {
      LoggerService.debug(
        'Shard not found for device=$deviceId',
        name: _tag,
      );
      return null;
    }

    try {
      final content = await file.readAsString();
      LoggerService.debug(
        'Read shard for device=$deviceId (${content.length} bytes)',
        name: _tag,
      );
      return content;
    } catch (e, st) {
      LoggerService.error(
        'Failed to read shard for device=$deviceId',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Lists all available device shard IDs.
  ///
  /// Scans the shard directory for `.json` files and returns their base names
  /// (i.e. the device IDs).
  Future<List<String>> listShardDeviceIds() async {
    final dir = await _shardDirectory();

    if (!dir.existsSync()) return [];

    try {
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.json') && !f.path.endsWith('.json.tmp'))
          .toList();

      final ids = files
          .map((f) => p.basenameWithoutExtension(f.path))
          .toList();

      LoggerService.debug('Found ${ids.length} shard(s)', name: _tag);
      return ids;
    } catch (e, st) {
      LoggerService.error(
        'Failed to list shard device IDs',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Deletes shards whose last modification time is older than [maxAge].
  Future<void> deleteOldShards(Duration maxAge) async {
    final dir = await _shardDirectory();

    if (!dir.existsSync()) return;

    final cutoff = DateTime.fromMillisecondsSinceEpoch(
      SyncClock.nowMs(),
      isUtc: true,
    ).subtract(maxAge);
    var deleted = 0;

    try {
      final files = dir.listSync().whereType<File>().where(
            (f) => f.path.endsWith('.json') || f.path.endsWith('.json.tmp'),
          );

      for (final file in files) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoff)) {
          await file.delete();
          deleted++;
        }
      }

      if (deleted > 0) {
        LoggerService.info(
          'Deleted $deleted old shard(s) (older than ${maxAge.inHours}h)',
          name: _tag,
        );
      }
    } catch (e, st) {
      LoggerService.error(
        'Failed to delete old shards',
        name: _tag,
        error: e,
        stackTrace: st,
      );
    }
  }
}
