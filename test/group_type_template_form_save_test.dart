import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/settings/pages/group_type_template_form_page.dart';
import 'package:io_caravella_egm/settings/state/group_type_templates_notifier.dart';
import 'package:material_ui/material_ui.dart';

/// Settings → group templates → new: Save is greyed out until there is a
/// name and at least one category (instead of a toast after tapping it).
void main() {
  testWidgets('Save waits for a name and a category', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: GroupTypeTemplateFormPage(notifier: GroupTypeTemplatesNotifier()),
      ),
    );
    await tester.pumpAndSettle();
    bool enabled() =>
        tester.widget<BottomActionBar>(find.byType(BottomActionBar)).enabled;

    expect(enabled(), isFalse);
    await tester.enterText(find.byType(TextField).first, 'Ski trip');
    await tester.pump();
    expect(enabled(), isFalse);

    await tester.tap(find.text('Add category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Lift pass');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(enabled(), isTrue);

    await tester.enterText(find.byType(TextField).first, '  ');
    await tester.pump();
    expect(enabled(), isFalse);
  });
}
