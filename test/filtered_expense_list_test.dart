import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:org_app_caravella/manager/details/widgets/filtered_expense_list.dart';
import 'package:org_app_caravella/data/model/expense_details.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart';

void main() {
  group('FilteredExpenseList Tests', () {
    late List<ExpenseDetails> testExpenses;
    late List<ExpenseCategory> testCategories;
    late List<ExpenseParticipant> testParticipants;

    setUp(() {
      testCategories = [
        ExpenseCategory(name: 'Food', id: 'cat1'),
        ExpenseCategory(name: 'Transport', id: 'cat2'),
      ];

      testParticipants = [
        ExpenseParticipant(name: 'Alice', id: 'part1'),
        ExpenseParticipant(name: 'Bob', id: 'part2'),
      ];

      testExpenses = [
        ExpenseDetails(
          id: 'exp1',
          name: 'Pizza dinner',
          amount: 25.50,
          category: testCategories[0],
          paidBy: testParticipants[0],
          date: DateTime.now(),
          note: 'Delicious pizza',
        ),
        ExpenseDetails(
          id: 'exp2',
          name: 'Bus ticket',
          amount: 5.00,
          category: testCategories[1],
          paidBy: testParticipants[1],
          date: DateTime.now().subtract(Duration(hours: 1)),
          note: 'City transport',
        ),
      ];
    });

    testWidgets('FilteredExpenseList displays expenses correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: FilteredExpenseList(
              expenses: testExpenses,
              currency: '€',
              onExpenseTap: (expense) {},
              categories: testCategories,
              participants: testParticipants,
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check that the expenses are displayed
      expect(find.text('Pizza dinner'), findsOneWidget);
      expect(find.text('Bus ticket'), findsOneWidget);
    });

    testWidgets('Filter toggle shows filter controls', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: FilteredExpenseList(
              expenses: testExpenses,
              currency: '€',
              onExpenseTap: (expense) {},
              categories: testCategories,
              participants: testParticipants,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially filters should be hidden
      // Italian localization for search hint
      expect(find.text('Cerca per nome o nota...'), findsNothing);

      // Tap the filter toggle button
      await tester.tap(find.byIcon(Icons.filter_list_outlined));
      await tester.pumpAndSettle();

      // Now filters should be visible
      expect(find.text('Cerca per nome o nota...'), findsOneWidget);
      expect(find.text('Categoria'), findsOneWidget);
      expect(find.text('Pagato da'), findsOneWidget);
    });

    testWidgets('Filter button is disabled when no expenses present', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: FilteredExpenseList(
              expenses: [], // Empty expenses list
              currency: '€',
              onExpenseTap: (expense) {},
              categories: testCategories,
              participants: testParticipants,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the filter toggle button
      final filterIcon = find.byIcon(Icons.filter_list_outlined);
      expect(filterIcon, findsOneWidget);
      final iconButton = find.ancestor(
        of: filterIcon,
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);
      final IconButton buttonWidget = tester.widget(iconButton);
      expect(buttonWidget.onPressed, isNull);

      // Try tapping the disabled button - should not show filters
      await tester.tap(iconButton);
      await tester.pumpAndSettle();

      // Filters should not be visible since button is disabled
      expect(find.text('Cerca per nome o nota...'), findsNothing);
    });

    testWidgets('Enhanced empty state appears when no expenses and callback provided', (
      tester,
    ) async {
      bool addExpenseCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: FilteredExpenseList(
              expenses: [], // Empty expenses list
              currency: '€',
              onExpenseTap: (expense) {},
              categories: testCategories,
              participants: testParticipants,
              onAddExpense: () {
                addExpenseCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that the enhanced empty state is displayed
      expect(find.text('Pronti per iniziare?'), findsOneWidget); // Italian title
      expect(find.text('Aggiungi la prima spesa per iniziare con questo gruppo!'), findsOneWidget); // Italian subtitle
      expect(find.text('Aggiungi Prima Spesa'), findsOneWidget); // Italian button text

      // Check that the call-to-action button is present and works
      final addButton = find.text('Aggiungi Prima Spesa');
      expect(addButton, findsOneWidget);
      
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      
      expect(addExpenseCalled, isTrue);
    });

    testWidgets('Enhanced empty state shows welcome image or fallback icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: FilteredExpenseList(
              expenses: [], // Empty expenses list
              currency: '\$',
              onExpenseTap: (expense) {},
              categories: testCategories,
              participants: testParticipants,
              onAddExpense: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for either the image or the fallback icon
      final imageWidget = find.byType(Image);
      final iconWidget = find.byIcon(Icons.receipt_long_outlined);
      
      // Either the image should load or the fallback icon should be present
      expect(imageWidget.evaluate().isNotEmpty || iconWidget.evaluate().isNotEmpty, isTrue);
      
      // Check English text is displayed correctly
      expect(find.text('Ready to start tracking?'), findsOneWidget);
      expect(find.text('Add your first expense to get started with this group!'), findsOneWidget);
      expect(find.text('Add First Expense'), findsOneWidget);
    });

    testWidgets('Simple empty state shown when filters are active', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: FilteredExpenseList(
              expenses: testExpenses, // Has expenses but will be filtered out
              currency: '€',
              onExpenseTap: (expense) {},
              categories: testCategories,
              participants: testParticipants,
              onAddExpense: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Show filters
      await tester.tap(find.byIcon(Icons.filter_list_outlined));
      await tester.pumpAndSettle();

      // Enter a search query that won't match anything
      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pumpAndSettle();

      // Should show simple empty state for filtered results, not enhanced empty state
      expect(find.text('Pronti per iniziare?'), findsNothing); // Enhanced state title
      expect(find.text('Nessuna spesa trovata con i filtri selezionati'), findsOneWidget); // Simple filtered state
      expect(find.byIcon(Icons.search_off_outlined), findsOneWidget); // Search off icon for filtered state
    });
  });
}
