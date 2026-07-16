import 'package:caravella_core/caravella_core.dart';

import 'google_drive_cloud_channel.dart';

/// Factory gating the Google Drive cloud channel on the
/// `ENABLE_GOOGLE_DRIVE_SYNC` build flag.
///
/// See `docs/GOOGLE_DRIVE_SYNC_SETUP.md` for the Google Cloud Console setup
/// this depends on, and `docs/BUILD_VARIANTS.md` for the flag reference.
class GoogleDriveSyncFactory {
  /// Optional iOS OAuth client ID, baked in at build time via
  /// `--dart-define=GOOGLE_DRIVE_IOS_CLIENT_ID=...`. Not needed on Android —
  /// see the setup guide.
  static const String _iosClientId = String.fromEnvironment(
    'GOOGLE_DRIVE_IOS_CLIENT_ID',
  );

  /// Whether this build was compiled with Google Drive sync support.
  static bool get isEnabled =>
      const bool.fromEnvironment('ENABLE_GOOGLE_DRIVE_SYNC', defaultValue: false);

  /// Creates the [CloudRelayChannel] for this build: a real
  /// [GoogleDriveCloudChannel] when [isEnabled], otherwise `null` — callers
  /// should treat `null` as "cloud sync unavailable in this build" and hide
  /// the corresponding UI (see `SyncSettingsScreen`).
  static CloudRelayChannel? createCloudChannel() {
    if (!isEnabled) return null;

    return GoogleDriveCloudChannel(
      iosClientId: _iosClientId.isEmpty ? null : _iosClientId,
    );
  }
}
