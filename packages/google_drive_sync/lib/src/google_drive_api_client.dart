import 'dart:convert';

import 'package:caravella_core/caravella_core.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

/// Thin wrapper around [drive.DriveApi] for reading/writing per-device
/// "shards" (JSON delta payloads) in the user's Drive `appDataFolder`.
///
/// `appDataFolder` is a hidden, per-app space — files here don't appear in
/// the user's Drive UI and aren't reachable by other apps. Each device gets
/// its own file, named `caravella_shard_<deviceId>.json`, holding that
/// device's latest full delta payload; peers converge by downloading every
/// device's shard and merging (the same [SyncManager]/[ConflictResolver]
/// pipeline used for LAN/Bluetooth deltas).
class GoogleDriveApiClient {
  static const _tag = 'sync.channel.cloud.api';
  static const _shardPrefix = 'caravella_shard_';
  static const _shardSuffix = '.json';
  static const _mimeType = 'application/json';

  final drive.DriveApi _api;

  GoogleDriveApiClient(http.Client authenticatedClient)
      : _api = drive.DriveApi(authenticatedClient);

  String _shardFileName(String deviceId) => '$_shardPrefix$deviceId$_shardSuffix';

  /// Creates or overwrites this device's shard file with [jsonPayload].
  Future<void> uploadShard(String deviceId, String jsonPayload) async {
    final fileName = _shardFileName(deviceId);
    final bytes = utf8.encode(jsonPayload);
    final media = drive.Media(Stream.value(bytes), bytes.length, contentType: _mimeType);

    final existingId = await _findShardFileId(fileName);

    if (existingId != null) {
      await _api.files.update(drive.File(), existingId, uploadMedia: media);
      LoggerService.debug(
        'Updated shard $fileName (${bytes.length} bytes)',
        name: _tag,
      );
    } else {
      final file = drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'];
      await _api.files.create(file, uploadMedia: media);
      LoggerService.debug(
        'Created shard $fileName (${bytes.length} bytes)',
        name: _tag,
      );
    }
  }

  /// Downloads every device's shard (including this device's own — callers
  /// are expected to dedupe/no-op on their own `deviceId`, same as the LAN
  /// channel's delta exchange).
  Future<List<String>> downloadAllShards() async {
    final list = await _api.files.list(
      spaces: 'appDataFolder',
      q: "name contains '$_shardPrefix'",
      $fields: 'files(id, name)',
    );

    final files = list.files ?? const <drive.File>[];
    final shards = <String>[];

    for (final file in files) {
      final id = file.id;
      if (id == null) continue;
      try {
        final media = await _api.files.get(
          id,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ) as drive.Media;
        final bytes = await media.stream.fold<List<int>>(
          <int>[],
          (acc, chunk) => acc..addAll(chunk),
        );
        shards.add(utf8.decode(bytes));
      } catch (e, st) {
        LoggerService.error(
          'Failed to download shard ${file.name}',
          name: _tag,
          error: e,
          stackTrace: st,
        );
      }
    }

    LoggerService.debug('Downloaded ${shards.length} shard(s)', name: _tag);
    return shards;
  }

  Future<String?> _findShardFileId(String fileName) async {
    final list = await _api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$fileName'",
      $fields: 'files(id, name)',
    );
    final files = list.files;
    if (files == null || files.isEmpty) return null;
    return files.first.id;
  }
}
