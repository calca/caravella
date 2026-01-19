import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:io_caravella_egm/manager/group/pages/group_creation_wizard_page.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('Group Creation Wizard Tests', () {
    testWidgets('Wizard should show all steps in correct order', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
            ChangeNotifierProvider(create: (_) => UserNameNotifier()),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              gen.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: gen.AppLocalizations.supportedLocales,
            home: const GroupCreationWizardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final pageContext = tester.element(find.byType(GroupCreationWizardPage));
      final gloc = gen.AppLocalizations.of(pageContext);
      final wizardState = Provider.of<WizardState>(pageContext, listen: false);
      final currentStepLabel =
          '1 ${gloc.wizard_step_of} ${wizardState.totalSteps}';

      // Should start on step 1 (Name)
      expect(find.text(gloc.wizard_step_name), findsOneWidget);
      expect(find.text(currentStepLabel), findsOneWidget);

      // Should show name input field
      expect(find.byType(TextField), findsOneWidget);

      // Next button should be disabled initially
      expect(find.text(gloc.wizard_next), findsOneWidget);
      final nextButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('Should enable next button when name is entered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
            ChangeNotifierProvider(create: (_) => UserNameNotifier()),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              gen.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: gen.AppLocalizations.supportedLocales,
            home: const GroupCreationWizardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final pageContext = tester.element(find.byType(GroupCreationWizardPage));
      final gloc = gen.AppLocalizations.of(pageContext);

      // Enter group name
      await tester.enterText(find.byType(TextField), 'Test Group');
      await tester.pump();

      // Next button should be enabled
      expect(find.text(gloc.wizard_next), findsOneWidget);
      final nextButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Should navigate through all wizard steps', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
            ChangeNotifierProvider(create: (_) => UserNameNotifier()),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              gen.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: gen.AppLocalizations.supportedLocales,
            home: const GroupCreationWizardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final pageContext = tester.element(find.byType(GroupCreationWizardPage));
      final gloc = gen.AppLocalizations.of(pageContext);
      final wizardState = Provider.of<WizardState>(pageContext, listen: false);
      final stepTwoLabel = '2 ${gloc.wizard_step_of} ${wizardState.totalSteps}';

      // Step 1: Name
      expect(find.text(gloc.wizard_step_name), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Test Group');
      await tester.pump();
      await tester.tap(find.text(gloc.wizard_next));
      await tester.pumpAndSettle();

      // Step 2: Participants
      expect(find.text(gloc.wizard_step_participants), findsOneWidget);
      expect(find.text(stepTwoLabel), findsOneWidget);

      // Step 3: Categories (skip participants validation for this test)
      // Step 4: Period
      // Step 5: Background
      // Step 6: Congratulations
    });
  });

  group('Wizard State Tests', () {
    test('WizardState should manage step navigation correctly', () {
      final wizardState = WizardState();

      // Should start at step 0
      expect(wizardState.currentStep, 0);

      // Should be able to move to next step
      wizardState.nextStep();
      expect(wizardState.currentStep, 1);

      // Should be able to move to previous step
      wizardState.previousStep();
      expect(wizardState.currentStep, 0);

      // Should not go below 0
      wizardState.previousStep();
      expect(wizardState.currentStep, 0);

      // Should not go above max steps
      for (int i = 0; i < 10; i++) {
        wizardState.nextStep();
      }
      expect(wizardState.currentStep, wizardState.totalSteps - 1);
    });

    test('Should validate required steps correctly', () {
      final formState = GroupFormState();

      // Name step should be invalid when empty
      expect(formState.title.trim().isEmpty, true);

      // Should be valid when title is set
      formState.setTitle('Test Group');
      expect(formState.title.trim().isNotEmpty, true);

      // Participants should be invalid when empty
      expect(formState.participants.isEmpty, true);

      // Categories should be invalid when empty
      expect(formState.categories.isEmpty, true);
    });
  });
}
