import 'dart:async';

import 'package:home_widget/home_widget.dart';

import '../logging/logger_service.dart';

/// Callback invoked when a home widget requests opening a group.
typedef HomeWidgetTapCallback =
    void Function(String groupId, String groupTitle);

/// Service to manage Android home widget refresh.
///
/// Note: Platform checks are handled by [PlatformHomeWidgetManager].
class AppHomeWidgetService {
  // Must match the provider class in
  // android/app/src/main/kotlin/org/app/caravella/HomeWidgetProvider.kt
  // and the receiver declared in AndroidManifest.xml.
  static const String _androidWidgetProvider =
      'io.caravella.egm.HomeWidgetProvider';
  static const String _tapScheme = 'caravella';
  static const String _tapHost = 'home_widget';
  static const String _tapPath = '/add_expense';

  static StreamSubscription<Uri?>? _widgetTapSubscription;
  /// Serializes repeated initialize calls to avoid overlapping subscriptions.
  static Future<void> _tapInitializationFuture = Future.value();

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

  /// Handles home widget tap deep-links and forwards them to [onTap].
  static Future<void> initializeTapHandling(
    HomeWidgetTapCallback onTap,
  ) async {
    final previousInitialization = _tapInitializationFuture;
    final currentInitialization = Completer<void>();
    _tapInitializationFuture = currentInitialization.future;
    try {
      try {
        await previousInitialization;
      } catch (_) {
        // Continue with latest initialization request.
      }
      await _initializeTapHandlingInternal(onTap);
      currentInitialization.complete();
    } catch (e, st) {
      currentInitialization.completeError(e, st);
      rethrow;
    }
  }

  static Future<void> _initializeTapHandlingInternal(
    HomeWidgetTapCallback onTap,
  ) async {
    try {
      final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      _forwardTapIfValid(initialUri, onTap);
    } catch (e) {
      LoggerService.error(
        'Unable to read initial home widget launch data',
        name: 'widget',
        error: e,
      );
    }

    final previousSubscription = _widgetTapSubscription;
    _widgetTapSubscription = HomeWidget.widgetClicked.listen(
      (uri) => _forwardTapIfValid(uri, onTap),
      onError: (Object e) {
        LoggerService.error(
          'Unable to receive home widget tap updates',
          name: 'widget',
          error: e,
        );
      },
    );
    await previousSubscription?.cancel();
  }

  /// Cancels tap handling subscription.
  static Future<void> disposeTapHandling() async {
    await _widgetTapSubscription?.cancel();
    _widgetTapSubscription = null;
  }

  static void _forwardTapIfValid(Uri? uri, HomeWidgetTapCallback onTap) {
    if (uri == null) return;
    if (uri.scheme != _tapScheme ||
        uri.host != _tapHost ||
        uri.path != _tapPath) {
      return;
    }

    final groupId = uri.queryParameters['groupId'];
    final groupTitle = uri.queryParameters['groupTitle'];
    if (groupId == null ||
        groupId.isEmpty ||
        groupTitle == null ||
        groupTitle.isEmpty) {
      return;
    }
    onTap(groupId, groupTitle);
  }
}
