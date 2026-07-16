import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/models/sync_result.dart';

/// Callback invoked when remote shards are downloaded from cloud storage.
typedef DeltaJsonCallback = Future<void> Function(
  List<String> shards,
  String channel,
);

/// Cloud relay channel for syncing device shards via a cloud provider.
///
/// This is an **interface** — `caravella_core` stays independent of any
/// concrete cloud provider SDK (see the package boundary rules in
/// `CLAUDE.md`). The real implementation lives in the separate
/// `google_drive_sync` package (`GoogleDriveCloudChannel`), built only when
/// the app is compiled with `--dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true` —
/// see `SyncBootstrap` (`lib/sync/sync_bootstrap.dart`) for the wiring.
///
/// [isEnabled]/[setEnabled] are shared, concrete implementations (the user
/// opt-in flag is persisted via [SharedPreferences] under the key
/// `sync_cloud_enabled`, regardless of provider) — subclasses only need to
/// implement the actual transfer methods.
abstract class CloudRelayChannel {
  static const _tag = 'sync.channel.cloud';
  static const _prefKey = 'sync_cloud_enabled';

  /// The sync-log channel name this implementation reports under (e.g.
  /// `"cloud"`).
  String get channelName;

  /// Whether cloud sync is enabled (user opt-in).
  ///
  /// Reads the persisted preference. Defaults to `false` if not set.
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Enable or disable cloud sync.
  ///
  /// Persists the preference and logs the change.
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    LoggerService.info(
      'Cloud sync ${enabled ? 'enabled' : 'disabled'}',
      name: _tag,
    );
  }

  /// Upload a device shard to cloud storage.
  Future<void> uploadShard(String deviceId, String jsonPayload);

  /// Download all shards from cloud storage.
  Future<List<String>> downloadAllShards();

  /// Starts periodic sync. The [onShards] callback is invoked whenever new
  /// shards are downloaded. Implementations should no-op if [isEnabled] is
  /// `false`.
  Future<void> start({required DeltaJsonCallback onShards});

  /// Stops periodic sync.
  Future<void> stop();

  /// Triggers an immediate sync cycle.
  Future<SyncResult> syncNow();
}
