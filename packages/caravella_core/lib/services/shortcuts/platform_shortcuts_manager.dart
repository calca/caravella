import 'package:flutter/foundation.dart';
import 'dart:io';
import 'app_shortcuts_service.dart';

/// Platform-specific shortcuts manager
/// Handles platform checks and delegates to appropriate service
class PlatformShortcutsManager {
  /// Update shortcuts if platform supports them
  static Future<void> updateShortcuts() async {
    if (!(!kIsWeb && defaultTargetPlatform == TargetPlatform.android)) return;
    await AppShortcutsService.updateShortcuts();
  }

  /// Clear shortcuts if platform supports them
  static Future<void> clearShortcuts() async {
    if (!(!kIsWeb && defaultTargetPlatform == TargetPlatform.android)) return;
    await AppShortcutsService.clearShortcuts();
  }

  /// Initialize shortcuts service if platform supports them
  static Future<void> initialize(ShortcutTapCallback callback) async {
    if (!(!kIsWeb && defaultTargetPlatform == TargetPlatform.android)) return;
    AppShortcutsService.initialize(callback);
  }
}
