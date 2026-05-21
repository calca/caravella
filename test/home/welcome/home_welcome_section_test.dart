import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/welcome/home_welcome_section.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';

void main() {
  Widget localizedApp({required Widget home}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  testWidgets(
    'Welcome background fades in after welcome content starts',
    (tester) async {
      await tester.pumpWidget(
        localizedApp(home: const Scaffold(body: HomeWelcomeSection())),
      );

      // First frame: both animations are still at 0.
      var titleFade = tester.widget<FadeTransition>(
        find.byKey(const ValueKey('welcome_title_fade')),
      );
      var backgroundFade = tester.widget<FadeTransition>(
        find.byKey(const ValueKey('welcome_background_fade')),
      );
      expect(titleFade.opacity.value, 0.0);
      expect(backgroundFade.opacity.value, 0.0);

      // Start controller (post-frame callback), then progress a bit.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      titleFade = tester.widget<FadeTransition>(
        find.byKey(const ValueKey('welcome_title_fade')),
      );
      backgroundFade = tester.widget<FadeTransition>(
        find.byKey(const ValueKey('welcome_background_fade')),
      );

      // Content starts first; background is still delayed.
      expect(titleFade.opacity.value, greaterThan(0.0));
      expect(backgroundFade.opacity.value, 0.0);

      await tester.pump(const Duration(milliseconds: 230));

      titleFade = tester.widget<FadeTransition>(
        find.byKey(const ValueKey('welcome_title_fade')),
      );
      backgroundFade = tester.widget<FadeTransition>(
        find.byKey(const ValueKey('welcome_background_fade')),
      );
      expect(backgroundFade.opacity.value, greaterThan(0.0));
      expect(titleFade.opacity.value, greaterThan(backgroundFade.opacity.value));

      await tester.pump(const Duration(milliseconds: 480));

      titleFade = tester.widget<FadeTransition>(
        find.byKey(const ValueKey('welcome_title_fade')),
      );
      backgroundFade = tester.widget<FadeTransition>(
        find.byKey(const ValueKey('welcome_background_fade')),
      );
      expect(titleFade.opacity.value, closeTo(1.0, 0.001));
      expect(backgroundFade.opacity.value, closeTo(1.0, 0.001));
    },
  );
}
