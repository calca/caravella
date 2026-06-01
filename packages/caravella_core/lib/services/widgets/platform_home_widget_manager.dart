import 'dart:io';

import '../../config/app_config.dart';
import 'app_home_widget_service.dart';

/// Platform-specific home widget manager.
class PlatformHomeWidgetManager {
  /// Refresh home widgets if platform supports them.
  static Future<void> updateHomeWidgets() async {
    if (!Platform.isAndroid || !AppConfig.enableAndroidWidget) return;
    await AppHomeWidgetService.updateWidgets();
  }

  /// Initialize widget tap handling if platform supports it.
  static Future<void> initializeTapHandling(
    HomeWidgetTapCallback callback,
  ) async {
    if (!Platform.isAndroid || !AppConfig.enableAndroidWidget) return;
    await AppHomeWidgetService.initializeTapHandling(callback);
  }

  /// Dispose widget tap handling if platform supports it.
  static Future<void> disposeTapHandling() async {
    if (!Platform.isAndroid || !AppConfig.enableAndroidWidget) return;
    await AppHomeWidgetService.disposeTapHandling();
  }
}
