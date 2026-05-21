import 'package:caravella_core/services/widgets/app_home_widget_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('home_widget');

  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('updateWidgets invokes native updateWidget method', () async {
    MethodCall? lastCall;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          lastCall = methodCall;
          return true;
        });

    await AppHomeWidgetService.updateWidgets();

    expect(lastCall, isNotNull);
    expect(lastCall!.method, 'updateWidget');
    expect(
      lastCall!.arguments,
      containsPair('qualifiedAndroidName', 'io.caravella.egm.HomeWidgetProvider'),
    );
  });

  test('updateWidgets handles platform errors gracefully', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          throw PlatformException(code: 'WIDGET_ERROR');
        });

    await expectLater(AppHomeWidgetService.updateWidgets(), completes);
  });
}
