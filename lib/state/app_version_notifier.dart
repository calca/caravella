import 'package:package_info_plus/package_info_plus.dart';
import 'async_state_notifier.dart';

/// Manages app version information using the AsyncStateNotifier pattern
/// Replaces direct FutureBuilder usage for better state management and error handling
class AppVersionNotifier extends AsyncStateNotifier<String> {
  static final AppVersionNotifier _instance = AppVersionNotifier._internal();
  
  factory AppVersionNotifier() => _instance;
  
  AppVersionNotifier._internal();
  
  /// Loads the app version information
  /// Returns a formatted version string with version and build number
  Future<void> loadAppVersion() async {
    await execute(() async {
      try {
        final info = await PackageInfo.fromPlatform();
        return '${info.version} (${info.buildNumber})';
      } catch (e) {
        // Fallback for when package info is not available
        return 'Unknown';
      }
    });
  }
  
  /// Refreshes the app version information in the background
  /// Useful for updates without showing loading indicators
  Future<void> refreshAppVersion() async {
    await executeInBackground(() async {
      try {
        final info = await PackageInfo.fromPlatform();
        return '${info.version} (${info.buildNumber})';
      } catch (e) {
        return 'Unknown';
      }
    });
  }
  
  /// Gets the current version if available, otherwise loads it
  Future<String> getOrLoadVersion() async {
    if (hasData) {
      return data!;
    }
    
    if (!isLoading) {
      await loadAppVersion();
    }
    
    return data ?? 'Loading...';
  }
}