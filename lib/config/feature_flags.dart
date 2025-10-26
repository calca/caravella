/// Feature flags for enabling/disabling features at compile time
/// 
/// These flags are configured at build time and cannot be changed at runtime.
/// Use dart-define to configure: --dart-define=ENABLE_GOOGLE_DRIVE_BACKUP=true
class FeatureFlags {
  /// Enable Google Drive backup functionality
  /// 
  /// This feature requires:
  /// - Google Cloud Console project with Drive API enabled
  /// - OAuth 2.0 configuration
  /// - google-services.json file in android/app/
  /// 
  /// Default: false (disabled)
  /// To enable: flutter build apk --dart-define=ENABLE_GOOGLE_DRIVE_BACKUP=true
  static const bool enableGoogleDriveBackup = bool.fromEnvironment(
    'ENABLE_GOOGLE_DRIVE_BACKUP',
    defaultValue: false,
  );
}
