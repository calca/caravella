import 'package:flutter/services.dart';

/// Service to manage Android home widget refresh.
///
/// Note: Platform checks are handled by [PlatformHomeWidgetManager].
class AppHomeWidgetService {
  static const MethodChannel _channel = MethodChannel(
    'io.caravella.egm/home_widget',
  );

  /// Requests native Android code to refresh all Caravella widgets.
  static Future<void> updateWidgets() async {
    try {
      await _channel.invokeMethod('updateHomeWidget');
    } catch (_) {
      // Silently fail - widgets are optional UI convenience.
    }
  }
}
