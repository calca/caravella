import 'dart:async';

import 'package:caravella_core/caravella_core.dart';

import 'google_drive_api_client.dart';
import 'google_drive_auth_service.dart';

/// Real [CloudRelayChannel] implementation backed by Google Drive's
/// `appDataFolder`.
///
/// Only ever constructed when the app is built with
/// `--dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true` — see
/// [GoogleDriveSyncFactory] (`google_drive_sync_factory.dart`) and
/// `lib/sync/sync_bootstrap.dart` in the app for the gating.
class GoogleDriveCloudChannel extends CloudRelayChannel {
  static const _tag = 'sync.channel.cloud.drive';

  /// Default polling interval for periodic sync.
  static const Duration defaultPollInterval = Duration(minutes: 15);

  final GoogleDriveAuthService _auth;

  Timer? _pollTimer;

  GoogleDriveCloudChannel({String? iosClientId})
      : _auth = GoogleDriveAuthService(iosClientId: iosClientId);

  @override
  String get channelName => 'cloud';

  /// The signed-in Google account's email, or `null` if not signed in.
  ///
  /// Shown in the UI so the user can see which account is linked (see
  /// `SyncSettingsScreen`'s cloud sync card).
  String? get signedInAccountEmail => _auth.currentUser?.email;

  /// Shows the Google sign-in UI. Returns `true` on success.
  Future<bool> signIn() async => (await _auth.signIn()) != null;

  /// Restores a previous sign-in session without showing any UI. Callers
  /// (e.g. the sync settings screen on load) should call this once cloud
  /// sync is known to be enabled, so the linked account shows up without
  /// forcing the user to sign in again every app launch.
  Future<bool> restoreSession() async => (await _auth.signInSilently()) != null;

  /// Signs out of the linked Google account.
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> uploadShard(String deviceId, String jsonPayload) async {
    final client = await _auth.authenticatedClient();
    if (client == null) {
      LoggerService.warning(
        'uploadShard skipped — not signed in to Google Drive',
        name: _tag,
      );
      return;
    }
    try {
      await GoogleDriveApiClient(client).uploadShard(deviceId, jsonPayload);
    } finally {
      client.close();
    }
  }

  @override
  Future<List<String>> downloadAllShards() async {
    final client = await _auth.authenticatedClient();
    if (client == null) {
      LoggerService.warning(
        'downloadAllShards skipped — not signed in to Google Drive',
        name: _tag,
      );
      return const [];
    }
    try {
      return await GoogleDriveApiClient(client).downloadAllShards();
    } finally {
      client.close();
    }
  }

  @override
  Future<void> start({required DeltaJsonCallback onShards}) async {
    final enabled = await isEnabled();
    if (!enabled) {
      LoggerService.info('Cloud sync is disabled — skipping start', name: _tag);
      return;
    }

    _pollTimer?.cancel();

    void scheduleNext() {
      _pollTimer = Timer(defaultPollInterval, () async {
        try {
          final shards = await downloadAllShards();
          if (shards.isNotEmpty) {
            await onShards(shards, channelName);
          }
        } catch (e, st) {
          LoggerService.error(
            'Periodic cloud sync failed',
            name: _tag,
            error: e,
            stackTrace: st,
          );
        } finally {
          // Reschedule only if stop() hasn't been called concurrently.
          if (_pollTimer != null) {
            scheduleNext();
          }
        }
      });
    }

    scheduleNext();
    LoggerService.info(
      'Cloud sync polling started (interval=${defaultPollInterval.inMinutes}min)',
      name: _tag,
    );
  }

  @override
  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    LoggerService.info('Cloud sync polling stopped', name: _tag);
  }

  @override
  Future<SyncResult> syncNow() async {
    final shards = await downloadAllShards();
    return SyncResult(
      applied: shards.length,
      skipped: 0,
      errors: 0,
      channel: channelName,
      peerId: signedInAccountEmail ?? '',
      syncedAt: DateTime.fromMillisecondsSinceEpoch(
        SyncClock.nowMs(),
        isUtc: true,
      ),
    );
  }
}
