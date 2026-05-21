import 'package:home_widget/home_widget.dart';
import '../logging/logger_service.dart';

/// Service to manage Android home widget refresh.
///
/// Note: Platform checks are handled by [PlatformHomeWidgetManager].
class AppHomeWidgetService {
  // Must match the provider class in
  // android/app/src/main/kotlin/org/app/caravella/HomeWidgetProvider.kt
  // and the receiver declared in AndroidManifest.xml.
  static const String _androidWidgetProvider =
      'io.caravella.egm.HomeWidgetProvider';

  /// Requests Android to refresh all Caravella widgets.
  static Future<void> updateWidgets() async {
    try {
      await HomeWidget.updateWidget(
        qualifiedAndroidName: _androidWidgetProvider,
      );
    } catch (e) {
      LoggerService.error(
        'Unable to refresh Android home widget',
        name: 'widget',
        error: e,
      );
    }
  }
}
