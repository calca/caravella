import '../../platform/platform_info.dart';
import 'app_shortcuts_service.dart';

/// Platform-specific shortcuts manager
/// Handles platform checks and delegates to appropriate service
class PlatformShortcutsManager {
  /// Update shortcuts if platform supports them
  static Future<void> updateShortcuts() async {
    if (!PlatformInfo.isAndroid) return;
    await AppShortcutsService.updateShortcuts();
  }

  /// Clear shortcuts if platform supports them
  static Future<void> clearShortcuts() async {
    if (!PlatformInfo.isAndroid) return;
    await AppShortcutsService.clearShortcuts();
  }

  /// Initialize shortcuts service if platform supports them
  static Future<void> initialize(ShortcutTapCallback callback) async {
    if (!PlatformInfo.isAndroid) return;
    AppShortcutsService.initialize(callback);
  }
}
