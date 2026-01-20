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
            home: const GroupCreationWizardPage(fromWelcome: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find a context within the wizard that has access to WizardState
      // Use a widget that's inside the MultiProvider scope
      final scaffoldContext = tester.element(find.byType(Scaffold).first);
      final gloc = gen.AppLocalizations.of(scaffoldContext);
      final wizardState = Provider.of<WizardState>(
        scaffoldContext,
        listen: false,
      );
      final currentStepLabel = '1/${wizardState.totalSteps}';

      // Should start on step 1 (User Name Welcome)
      expect(find.text(gloc.wizard_user_name_welcome), findsOneWidget);
      expect(find.text(currentStepLabel), findsOneWidget);

      // Should show name input field
      expect(find.byType(TextField), findsOneWidget);

      // Next button should always be enabled on user name step (name is optional)
      expect(find.text(gloc.wizard_next), findsOneWidget);
      final nextButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('Should enable finish button when group name is entered', (
      WidgetTester tester,
    ) async {
      // Test without user name step (fromWelcome: false)
      // With fromWelcome: false, wizard has only 2 steps: TypeAndName -> Completion
      // So the first step shows "Finish" button, not "Next"
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
            home: const GroupCreationWizardPage(fromWelcome: false),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final pageContext = tester.element(find.byType(GroupCreationWizardPage));
      final gloc = gen.AppLocalizations.of(pageContext);

      // Should start on Type and Name step (first step when fromWelcome is false)
      // Finish button should be disabled initially (group name is required)
      expect(find.text(gloc.wizard_finish), findsOneWidget);
      var finishButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(finishButton.onPressed, isNull);

      // Enter group name
      await tester.enterText(find.byType(TextField), 'Test Group');
      await tester.pump();

      // Finish button should be enabled
      finishButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(finishButton.onPressed, isNotNull);
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
            home: const GroupCreationWizardPage(fromWelcome: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find a context within the wizard that has access to WizardState
      final scaffoldContext = tester.element(find.byType(Scaffold).first);
      final gloc = gen.AppLocalizations.of(scaffoldContext);
      final wizardState = Provider.of<WizardState>(
        scaffoldContext,
        listen: false,
      );
      final stepTwoLabel = '2/${wizardState.totalSteps}';

      // Step 1: User Name (Welcome step)
      expect(find.text(gloc.wizard_user_name_welcome), findsOneWidget);
      // Enter user name and proceed
      await tester.enterText(find.byType(TextField), 'Test User');
      await tester.pump();
      await tester.tap(find.text(gloc.wizard_next));
      await tester.pumpAndSettle();

      // Step 2: Type and Name
      expect(find.text(stepTwoLabel), findsOneWidget);

      // Step 3: Completion (skip further steps for this test)
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
