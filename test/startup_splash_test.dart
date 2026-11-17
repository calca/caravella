import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/startup_entrance.dart';
import 'package:io_caravella_egm/main/startup_splash.dart';
import 'package:material_ui/material_ui.dart';

double _opacity(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find.descendant(
        of: find.byType(StartupEntrance),
        matching: find.byType(FadeTransition),
      ),
    )
    .opacity
    .value;

void main() {
  testWidgets('the cards come in once, at the start', (tester) async {
    Widget entrance(Key key) => Directionality(
      textDirection: TextDirection.ltr,
      child: StartupEntrance(
        key: key,
        delay: const Duration(milliseconds: 150),
        child: const Text('Norway'),
      ),
    );

    await tester.pumpWidget(entrance(const ValueKey(1)));
    expect(_opacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 140));
    expect(_opacity(tester), 0, reason: 'still waiting for the splash');
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);

    // Later (another group featured, a page rebuilt): shown at once.
    await tester.pumpWidget(entrance(const ValueKey(2)));
    expect(_opacity(tester), 1);
  });

  test('Android hears that Home is ready, once', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('io.caravella.egm/splash'),
          (call) async {
            calls.add(call.method);
            return null;
          },
        );

    StartupSplash.homeReady();
    StartupSplash.homeReady();
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['homeReady']);
  });
}
