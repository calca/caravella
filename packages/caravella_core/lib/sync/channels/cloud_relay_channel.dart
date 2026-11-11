import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:caravella_core/services/logging/logger_service.dart';

/// One sync cycle, run by the channel's timer (see [CloudRelayChannel.start]).
typedef CloudSyncCycle = Future<void> Function();

/// Cloud relay channel for syncing device shards via a cloud provider.
///
/// This is an **interface** — `caravella_core` stays independent of any
/// concrete cloud provider SDK (see the package boundary rules in
/// `CLAUDE.md`). The real implementation lives in the separate
/// `google_drive_sync` package (`GoogleDriveCloudChannel`), handed out by
/// `GmsIntegrations.createCloudChannel` (`caravella_gms`) only when the app
/// is compiled with `--dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true` and never
/// in the F-Droid build — see `SyncBootstrap` (`lib/sync/sync_bootstrap.dart`)
/// for the wiring.
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

  /// Uploads this device's shard (its full snapshot, a delta JSON string),
  /// replacing the previous one. Throws [CloudNotSignedInException] without
  /// an account, or the provider's error.
  Future<void> uploadShard(String deviceId, String jsonPayload);

  /// Downloads every device's shard, this one's included. Throws
  /// [CloudNotSignedInException] without an account, or the provider's error.
  Future<List<String>> downloadAllShards();

  /// Runs [cycle] every so often until [stop]. The cycle itself (download,
  /// apply, upload) is `SyncOrchestrator`'s. No-op if [isEnabled] is false.
  Future<void> start({required CloudSyncCycle cycle});

  /// Stops periodic sync.
  Future<void> stop();
}

/// No account is signed in to the cloud provider (never signed in, signed
/// out, or access revoked).
class CloudNotSignedInException implements Exception {
  const CloudNotSignedInException();

  @override
  String toString() => 'Not signed in to the cloud account';
}
