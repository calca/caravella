import 'update_service_interface.dart';
import 'update_service_noop.dart';

// Conditionally import play store implementation
// This will only be imported when ENABLE_PLAY_UPDATES=true
import 'update_service_playstore.dart'
    if (dart.library.html) 'update_service_noop.dart';

/// Factory for creating update service instances based on build configuration.
class UpdateServiceFactory {
  /// Create the appropriate update service based on build flags.
  ///
  /// Returns PlayStoreUpdateService when ENABLE_PLAY_UPDATES=true,
  /// otherwise returns NoOpUpdateService.
  static UpdateService createUpdateService() {
    const isPlayUpdatesEnabled = bool.fromEnvironment(
      'ENABLE_PLAY_UPDATES',
      defaultValue: false,
    );

    if (isPlayUpdatesEnabled) {
      // Initialize logger for play store package
      initializePlayStoreUpdatesLogger();
      return const PlayStoreUpdateService();
    }

    return const NoOpUpdateService();
  }

  /// Create the appropriate update notifier based on build flags.
  static UpdateNotifier createUpdateNotifier() {
    const isPlayUpdatesEnabled = bool.fromEnvironment(
      'ENABLE_PLAY_UPDATES',
      defaultValue: false,
    );

    if (isPlayUpdatesEnabled) {
      return PlayStoreUpdateNotifier();
    }

    return NoOpUpdateNotifier();
  }

  /// Check if Play Store updates are enabled in this build.
  static bool get isPlayUpdatesEnabled =>
      const bool.fromEnvironment('ENABLE_PLAY_UPDATES', defaultValue: false);
}
