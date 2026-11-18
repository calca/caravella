import 'dart:io';

import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/settings/pages/whats_new_page.dart';
import 'package:material_ui/material_ui.dart';

/// The in-app changelog renders through gpt_markdown: every language's
/// file shows its sections without errors.
void main() {
  // The release checklist trims the in-app notes; this catches a release
  // that forgot to.
  for (final lang in ['en', 'it', 'es', 'pt', 'zh']) {
    test('$lang changelog keeps only the last two minor versions', () {
      final text = File('assets/docs/CHANGELOG_$lang.md').readAsStringSync();
      final minors = RegExp(
        r'^## (\d+\.\d+)\.\d+',
        multiLine: true,
      ).allMatches(text).map((m) => m.group(1)).toSet();
      expect(minors.length, lessThanOrEqualTo(2), reason: '$minors');
    });
  }

  for (final lang in ['en', 'it', 'es', 'pt', 'zh']) {
    testWidgets('What\'s new renders the $lang changelog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);

      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(lang),
            theme: CaravellaThemes.light,
            home: const WhatsNewPage(),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.textContaining('2.4.1', findRichText: true), findsWidgets);
      // Only the last two minor versions ship; older ones are on the site.
      expect(find.textContaining('2.3.0', findRichText: true), findsNothing);
      await tester.scrollUntilVisible(
        find.byIcon(Icons.open_in_new_rounded),
        300,
      );
      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
    });
  }
}
