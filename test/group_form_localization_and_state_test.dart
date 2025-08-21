import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart';
import 'package:org_app_caravella/manager/group/group_form_state.dart';
import 'package:org_app_caravella/data/expense_participant.dart';

void main() {
  group('GroupFormState basic logic', () {
    test('isValid requires title and at least one participant', () {
      final s = GroupFormState();
      expect(s.isValid, false);
      s.setTitle('Trip');
      expect(s.isValid, false); // still needs participant
      s.addParticipant(ExpenseParticipant(name: 'Alice'));
      expect(s.isValid, true);
    });
  });

  group('Localization keys for new group form UI', () {
    Future<void> pumpLocalized(
      Locale locale,
      WidgetTester tester,
      void Function(AppLocalizations loc) body,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: const SizedBox.shrink(),
        ),
      );
      await tester.pump();
      final loc = AppLocalizations.of(tester.element(find.byType(SizedBox)));
      body(loc);
    }

    testWidgets('English keys exist', (tester) async {
      await pumpLocalized(const Locale('en'), tester, (loc) {
        expect(loc.background_options.isNotEmpty, true);
        expect(loc.choose_image_or_color.isNotEmpty, true);
        expect(loc.discard_changes_title.isNotEmpty, true);
      });
    });

    testWidgets('Italian keys exist', (tester) async {
      await pumpLocalized(const Locale('it'), tester, (loc) {
        expect(loc.background_options.isNotEmpty, true);
        expect(loc.choose_image_or_color.isNotEmpty, true);
        expect(loc.discard_changes_title.isNotEmpty, true);
      });
    });
  });
}
