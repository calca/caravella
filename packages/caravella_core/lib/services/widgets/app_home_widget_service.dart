import 'package:home_widget/home_widget.dart';
import '../logging/logger_service.dart';

/// Service to manage Android home widget refresh.
///
/// Note: Platform checks are handled by [PlatformHomeWidgetManager].
class AppHomeWidgetService {
  /// Requests Android to refresh all Caravella widgets.
  static Future<void> updateWidgets() async {
    try {
      await HomeWidget.updateWidget(
        qualifiedAndroidName: 'io.caravella.egm.HomeWidgetProvider',
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
