/// Interface for update-related localized strings.
///
/// This allows the package to be localization-agnostic while still
/// supporting localized UI text. The app provides an implementation.
abstract class UpdateLocalizations {
  String get updateAvailable;
  String get updateAvailableDesc;
  String get updateLater;
  String get updateNow;
  String get updateDownloading;
  String get updateInstalling;
  String get updateError;
  String get checkForUpdates;
  String get checkForUpdatesDesc;
  String get checkingForUpdates;
  String get noUpdateAvailable;
}
