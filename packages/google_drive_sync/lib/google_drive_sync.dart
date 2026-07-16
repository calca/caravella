/// Google Drive cloud relay for Caravella's sync feature.
///
/// Gated end-to-end on `--dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true` via
/// [GoogleDriveSyncFactory] — when the flag isn't set, the app never
/// constructs [GoogleDriveCloudChannel] and this package's `google_sign_in`/
/// `googleapis` dependencies are never exercised at runtime. See
/// `docs/GOOGLE_DRIVE_SYNC_SETUP.md` for the Google Cloud Console setup and
/// `docs/PACKAGE_GOOGLE_DRIVE_SYNC.md` for how this package fits together.
library;

export 'src/google_drive_auth_service.dart';
export 'src/google_drive_api_client.dart';
export 'src/google_drive_cloud_channel.dart';
export 'src/google_drive_sync_factory.dart';
