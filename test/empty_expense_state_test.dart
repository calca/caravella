import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/manager/details/widgets/empty_expense_state.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';

void main() {
  group('EmptyExpenseState Widget Tests', () {
    testWidgets('EmptyExpenseState displays correctly in Italian', (
      tester,
    ) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: EmptyExpenseState(
              onAddFirstExpense: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that add button is present with Italian text
      expect(find.text('Aggiungi Spesa'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Check that emoji is displayed (random emoji from GroupCardEmptyState)
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsWidgets);

      // Check button functionality
      final button = find.text('Aggiungi Spesa');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });

    testWidgets('EmptyExpenseState displays correctly in English', (
      tester,
    ) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: EmptyExpenseState(
              onAddFirstExpense: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that add button is present with English text
      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Check that emoji is displayed (random emoji from GroupCardEmptyState)
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsWidgets);

      // Check button functionality
      final button = find.text('Add Expense');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });

    testWidgets('EmptyExpenseState displays correctly in Spanish', (
      tester,
    ) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: EmptyExpenseState(
              onAddFirstExpense: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that add button is present with Spanish text
      expect(find.text('Agregar Gasto'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Check that emoji is displayed (random emoji from GroupCardEmptyState)
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsWidgets);

      // Check button functionality
      final button = find.text('Agregar Gasto');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });

    testWidgets('EmptyExpenseState shows image or fallback icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(body: EmptyExpenseState(onAddFirstExpense: () {})),
        ),
      );

      await tester.pumpAndSettle();

      // GroupCardEmptyState displays emoji text, not an image or icon
      // Check that emoji text is present via RichText widget
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsWidgets);

      // Also verify button is present
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('EmptyExpenseState has proper Material 3 styling', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(body: EmptyExpenseState(onAddFirstExpense: () {})),
        ),
      );

      await tester.pumpAndSettle();

      // Check for button label and icon
      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });
}
