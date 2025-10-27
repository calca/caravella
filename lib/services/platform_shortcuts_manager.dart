import 'dart:io';
import 'app_shortcuts_service.dart';

/// Platform-specific shortcuts manager
/// Handles platform checks and delegates to appropriate service
class PlatformShortcutsManager {
  /// Update shortcuts if platform supports them
  static Future<void> updateShortcuts() async {
    if (!Platform.isAndroid) return;
    await AppShortcutsService.updateShortcuts();
  }

  /// Clear shortcuts if platform supports them
  static Future<void> clearShortcuts() async {
    if (!Platform.isAndroid) return;
    await AppShortcutsService.clearShortcuts();
  }

  /// Initialize shortcuts service if platform supports them
  static void initialize(
    void Function(String groupId, String groupTitle) callback,
  ) {
    if (!Platform.isAndroid) return;
    AppShortcutsService.initialize(callback);
  }
}
