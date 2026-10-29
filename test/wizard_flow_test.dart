import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zentoast/zentoast.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_type/group_type_localization.dart';
import 'package:io_caravella_egm/manager/group/pages/group_creation_wizard_page.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// The group creation wizard: your name (first start only) → what kind of
/// group → its name, dates and currency → who shares the expenses.
void main() {
  Future<gen.AppLocalizations> open(
    WidgetTester tester, {
    bool fromWelcome = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(412, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
          ChangeNotifierProvider(create: (_) => UserNameNotifier()),
        ],
        // Toasts (e.g. "already exists") need their provider, as in the app.
        child: ToastProvider.create(
          child: MaterialApp(
            localizationsDelegates: const [
              gen.AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: gen.AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            builder: (context, child) => Stack(
              children: [
                ?child,
                const ToastViewer(alignment: Alignment.bottomCenter),
              ],
            ),
            home: GroupCreationWizardPage(fromWelcome: fromWelcome),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return gen.AppLocalizations.of(
      tester.element(find.byType(GroupCreationWizardPage)),
    );
  }

  WizardState wizard(WidgetTester tester) => Provider.of<WizardState>(
    tester.element(find.byType(PageView)),
    listen: false,
  );

  GroupFormState form(WidgetTester tester) => Provider.of<GroupFormState>(
    tester.element(find.byType(PageView)),
    listen: false,
  );

  FilledButton mainButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton));

  Future<void> next(WidgetTester tester, gen.AppLocalizations l10n) async {
    await tester.tap(find.text(l10n.wizard_continue));
    await tester.pumpAndSettle();
  }

  testWidgets('from the welcome screen it starts with your name', (
    tester,
  ) async {
    final l10n = await open(tester, fromWelcome: true);

    expect(wizard(tester).totalSteps, 4);
    expect(find.text(l10n.wizard_name_title), findsOneWidget);
    expect(find.bySemanticsLabel('1/4'), findsOneWidget);
    // The name is optional.
    expect(mainButton(tester).onPressed, isNotNull);
    expect(find.text(l10n.wizard_skip), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Gigi');
    await tester.pump();
    expect(find.text('GI'), findsOneWidget);
  });

  testWidgets('from Groups it starts with the kind of group', (tester) async {
    final l10n = await open(tester);

    expect(wizard(tester).totalSteps, 3);
    expect(find.text(l10n.wizard_type_title), findsOneWidget);
    expect(find.text(l10n.wizard_skip), findsNothing);
    for (final type in ExpenseGroupType.values) {
      expect(
        find.text(GroupTypeLocalization.typeName(l10n, type)),
        findsOneWidget,
      );
    }
  });

  testWidgets('picking a kind of group swaps the starting categories', (
    tester,
  ) async {
    final l10n = await open(tester);
    await tester.tap(
      find.text(GroupTypeLocalization.typeName(l10n, ExpenseGroupType.travel)),
    );
    await tester.pump();

    final state = form(tester);
    expect(state.groupType, ExpenseGroupType.travel);
    final names = state.categories.map((c) => c.name).toSet();
    expect(
      names,
      containsAll(
        GroupTypeLocalization.localizedDefaultCategories(
          l10n,
          ExpenseGroupType.travel,
        ),
      ),
    );
    for (final personal
        in GroupTypeLocalization.localizedDefaultCategories(
          l10n,
          ExpenseGroupType.personal,
        ).where(
          (n) => !GroupTypeLocalization.localizedDefaultCategories(
            l10n,
            ExpenseGroupType.travel,
          ).contains(n),
        )) {
      expect(names, isNot(contains(personal)));
    }
  });

  testWidgets('the name is required to continue, nothing red before typing', (
    tester,
  ) async {
    final l10n = await open(tester);
    await next(tester, l10n);

    expect(find.text(l10n.wizard_details_title), findsOneWidget);
    expect(mainButton(tester).onPressed, isNull);
    expect(find.text(l10n.enter_title), findsOneWidget); // only as hint

    await tester.enterText(find.byType(TextField), 'Lisbon');
    await tester.pump();
    expect(mainButton(tester).onPressed, isNotNull);
    expect(form(tester).title, 'Lisbon');
  });

  testWidgets('people: you first, then friends added by name', (tester) async {
    final l10n = await open(tester);
    await next(tester, l10n);
    await tester.enterText(find.byType(TextField), 'Lisbon');
    await tester.pump();
    await next(tester, l10n);

    expect(find.text(l10n.wizard_participants_section_title), findsOneWidget);
    expect(find.text(l10n.wizard_create), findsOneWidget);
    // No name set: the placeholder "Me", without "(you)".
    expect(find.text(l10n.default_participant_me), findsOneWidget);

    // The same add flow as the pickers: a pill opens the name field, which
    // stays open for the next name.
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text(l10n.add_participant));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Anna');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    // A name already there is refused and stays in the field.
    await tester.enterText(find.byType(TextField), 'anna');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.widgetWithText(TextField, 'anna'), findsOneWidget);

    expect(form(tester).participants.map((p) => p.name), [
      l10n.default_participant_me,
      'Anna',
    ]);

    // Tap a friend to remove them; you can't be removed.
    await tester.tap(find.bySemanticsLabel(l10n.wizard_people_remove('Anna')));
    await tester.pump();
    expect(form(tester).participants, hasLength(1));
  });

  testWidgets('back goes to the previous step', (tester) async {
    final l10n = await open(tester);
    await next(tester, l10n);
    expect(wizard(tester).currentStep, 1);

    await tester.tap(find.byType(RoundBackButton));
    await tester.pumpAndSettle();
    expect(wizard(tester).currentStep, 0);
    expect(find.text(l10n.wizard_type_title), findsOneWidget);
  });

  testWidgets('swiping does not change step', (tester) async {
    await open(tester);
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.physics, isA<NeverScrollableScrollPhysics>());

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(wizard(tester).currentStep, 0);
  });

  group('WizardState', () {
    test('moves between steps within bounds', () {
      final state = WizardState();
      expect(state.steps, [
        WizardStep.userName,
        WizardStep.type,
        WizardStep.details,
        WizardStep.people,
      ]);
      expect(state.currentStep, 0);
      state.nextStep();
      expect(state.step, WizardStep.type);
      state.previousStep();
      state.previousStep();
      expect(state.currentStep, 0);
      for (var i = 0; i < 10; i++) {
        state.nextStep();
      }
      expect(state.currentStep, state.totalSteps - 1);
      expect(state.isLastStep, isTrue);
    });

    test('without the name step there are three steps', () {
      final state = WizardState(includeUserNameStep: false);
      expect(state.steps, [
        WizardStep.type,
        WizardStep.details,
        WizardStep.people,
      ]);
    });
  });
}
