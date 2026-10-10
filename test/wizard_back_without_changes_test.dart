import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/group/pages/group_creation_wizard_page.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  Future<gen.AppLocalizations> openWizard(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
          ChangeNotifierProvider(create: (_) => UserNameNotifier()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            gen.AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: gen.AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GroupCreationWizardPage(),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return gen.AppLocalizations.of(
      tester.element(find.byType(GroupCreationWizardPage)),
    );
  }

  Future<void> goBack(WidgetTester tester) async {
    await tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'opening the new-group wizard and going back without input does not ask '
    'to discard changes',
    (tester) async {
      final l10n = await openWizard(tester);
      await goBack(tester);

      expect(find.text(l10n.discard_changes_title), findsNothing);
      expect(find.byType(GroupCreationWizardPage), findsNothing);
    },
  );

  testWidgets('typing a group name still asks to discard changes', (
    tester,
  ) async {
    final l10n = await openWizard(tester);
    await tester.enterText(find.byType(TextField).first, 'Trip');
    await tester.pumpAndSettle();
    await goBack(tester);

    expect(find.text(l10n.discard_changes_title), findsOneWidget);
    expect(find.byType(GroupCreationWizardPage), findsOneWidget);
  });
}
