import 'dart:async';
import 'dart:typed_data';

import 'package:caravella_core/services/widgets/app_home_widget_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('home_widget');
  const eventChannelName = 'home_widget/updates';
  const codec = StandardMethodCodec();

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(eventChannelName, (ByteData? message) async {
          final call = codec.decodeMethodCall(message);
          if (call.method == 'listen' || call.method == 'cancel') {
            return codec.encodeSuccessEnvelope(null);
          }
          return null;
        });
  });

  tearDown(() async {
    await AppHomeWidgetService.disposeTapHandling();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(eventChannelName, null);
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

  test('initializeTapHandling forwards valid initial home widget tap', () async {
    HomeWidgetTapAction? tappedAction;
    String? tappedGroupId;
    String? tappedGroupTitle;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'initiallyLaunchedFromHomeWidget') {
            return 'caravella://home_widget/add_expense?groupId=g1&groupTitle=Trip';
          }
          return null;
        });

    await AppHomeWidgetService.initializeTapHandling((action, groupId, groupTitle) {
      tappedAction = action;
      tappedGroupId = groupId;
      tappedGroupTitle = groupTitle;
    });

    expect(tappedAction, HomeWidgetTapAction.addExpense);
    expect(tappedGroupId, 'g1');
    expect(tappedGroupTitle, 'Trip');
  });

  test('initializeTapHandling ignores invalid initial home widget tap', () async {
    var callbackCalled = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'initiallyLaunchedFromHomeWidget') {
            return 'caravella://home_widget/other_path?groupId=g1&groupTitle=Trip';
          }
          return null;
        });

    await AppHomeWidgetService.initializeTapHandling((_, __, ___) {
      callbackCalled = true;
    });

    expect(callbackCalled, isFalse);
  });

  test('initializeTapHandling forwards widgetClicked stream tap', () async {
    HomeWidgetTapAction? tappedAction;
    String? tappedGroupId;
    String? tappedGroupTitle;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async => null);

    await AppHomeWidgetService.initializeTapHandling((action, groupId, groupTitle) {
      tappedAction = action;
      tappedGroupId = groupId;
      tappedGroupTitle = groupTitle;
    });

    final completer = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          eventChannelName,
          codec.encodeSuccessEnvelope(
            'caravella://home_widget/add_expense?groupId=g2&groupTitle=Trip2',
          ),
          (_) => completer.complete(),
        );
    await completer.future;

    expect(tappedAction, HomeWidgetTapAction.addExpense);
    expect(tappedGroupId, 'g2');
    expect(tappedGroupTitle, 'Trip2');
  });

  test(
    'initializeTapHandling processes initial tap and subsequent stream tap',
    () async {
      final tappedIds = <String>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'initiallyLaunchedFromHomeWidget') {
              return 'caravella://home_widget/add_expense?groupId=g1&groupTitle=Trip1';
            }
            return null;
          });

      await AppHomeWidgetService.initializeTapHandling((_, groupId, _) {
        tappedIds.add(groupId);
      });

      final completer = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            eventChannelName,
            codec.encodeSuccessEnvelope(
              'caravella://home_widget/add_expense?groupId=g2&groupTitle=Trip2',
            ),
            (_) => completer.complete(),
          );
      await completer.future;

      expect(tappedIds, ['g1', 'g2']);
    },
  );

  test(
    'initializeTapHandling ignores initial tap with missing query parameters',
    () async {
      var callbackCalled = false;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'initiallyLaunchedFromHomeWidget') {
              return 'caravella://home_widget/add_expense?groupId=g1';
            }
            return null;
          });

      await AppHomeWidgetService.initializeTapHandling((_, __, ___) {
        callbackCalled = true;
      });

      expect(callbackCalled, isFalse);
    },
  );

  test('initializeTapHandling ignores initial tap with invalid scheme', () async {
    var callbackCalled = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'initiallyLaunchedFromHomeWidget') {
            return 'wrong://home_widget/add_expense?groupId=g1&groupTitle=Trip';
          }
          return null;
        });

    await AppHomeWidgetService.initializeTapHandling((_, __, ___) {
      callbackCalled = true;
    });

    expect(callbackCalled, isFalse);
  });

  test('disposeTapHandling stops widgetClicked callbacks', () async {
    var callbackCalled = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async => null);

    await AppHomeWidgetService.initializeTapHandling((_, __, ___) {
      callbackCalled = true;
    });
    await AppHomeWidgetService.disposeTapHandling();

    final completer = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          eventChannelName,
          codec.encodeSuccessEnvelope(
            'caravella://home_widget/add_expense?groupId=g2&groupTitle=Trip2',
          ),
          (_) => completer.complete(),
        );
    await completer.future;

    expect(callbackCalled, isFalse);
  });

  test('initializeTapHandling forwards open group action', () async {
    HomeWidgetTapAction? tappedAction;
    String? tappedGroupId;
    String? tappedGroupTitle;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'initiallyLaunchedFromHomeWidget') {
            return 'caravella://home_widget/open_group?groupId=g1&groupTitle=Trip';
          }
          return null;
        });

    await AppHomeWidgetService.initializeTapHandling((action, groupId, groupTitle) {
      tappedAction = action;
      tappedGroupId = groupId;
      tappedGroupTitle = groupTitle;
    });

    expect(tappedAction, HomeWidgetTapAction.openGroup);
    expect(tappedGroupId, 'g1');
    expect(tappedGroupTitle, 'Trip');
  });
}
