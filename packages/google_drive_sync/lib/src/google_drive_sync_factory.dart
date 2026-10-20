import 'package:caravella_core/caravella_core.dart';

import 'google_drive_auth_service.dart';
import 'google_drive_backup_store.dart';
import 'google_drive_cloud_channel.dart';

/// Factory gating the Google Drive cloud channel on the
/// `ENABLE_GOOGLE_DRIVE_SYNC` build flag.
///
/// See `docs/GOOGLE_DRIVE_SYNC_SETUP.md` for the Google Cloud Console setup
/// this depends on, and `docs/BUILD_VARIANTS.md` for the flag reference.
class GoogleDriveSyncFactory {
  /// OAuth **Web** client ID of the `caravella-egm` Google Cloud project,
  /// required by Google sign-in on Android (Credential Manager). It isn't a
  /// secret: it only identifies the project, and sign-in still requires the
  /// app's package name + signing certificate to match one of the project's
  /// Android OAuth clients. Override with
  /// `--dart-define=GOOGLE_DRIVE_SERVER_CLIENT_ID=...` for another project.
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_DRIVE_SERVER_CLIENT_ID',
    defaultValue: _caravellaServerClientId,
  );
  static const String _caravellaServerClientId =
      '809210426021-lmearsi2rjnotc41sh1n268u11fudiku.apps.googleusercontent.com';

  /// Optional iOS OAuth client ID, baked in at build time via
  /// `--dart-define=GOOGLE_DRIVE_IOS_CLIENT_ID=...` — see the setup guide.
  static const String _iosClientId = String.fromEnvironment(
    'GOOGLE_DRIVE_IOS_CLIENT_ID',
  );

  /// Whether this build was compiled with Google Drive sync support.
  static bool get isEnabled => const bool.fromEnvironment(
    'ENABLE_GOOGLE_DRIVE_SYNC',
    defaultValue: false,
  );

  static GoogleDriveAuthService? _auth;

  /// One Google sign-in for sync and backup (it can only be initialized
  /// once per process).
  static GoogleDriveAuthService get _sharedAuth =>
      _auth ??= GoogleDriveAuthService(
        iosClientId: _iosClientId.isEmpty ? null : _iosClientId,
        serverClientId: serverClientId.isEmpty ? null : serverClientId,
      );

  /// Creates the [CloudRelayChannel] for this build: a real
  /// [GoogleDriveCloudChannel] when [isEnabled], otherwise `null` — callers
  /// should treat `null` as "cloud sync unavailable in this build" and hide
  /// the corresponding UI (see `SyncSettingsScreen`).
  static CloudRelayChannel? createCloudChannel() {
    if (!isEnabled) return null;
    return GoogleDriveCloudChannel(auth: _sharedAuth);
  }

  /// Backups in the user's Drive when [isEnabled], otherwise `null` (the
  /// app then offers only the file export).
  static CloudBackupStore? createBackupStore() {
    if (!isEnabled) return null;
    return GoogleDriveBackupStore(_sharedAuth);
  }
}
