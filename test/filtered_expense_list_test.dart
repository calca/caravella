import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/manager/details/widgets/filtered_expense_list.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';

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

      // Header and filter icon should be hidden entirely now
      expect(find.byIcon(Icons.filter_list_outlined), findsNothing);
      expect(find.text('Attività'), findsNothing); // activity label hidden
    });

    testWidgets(
      'Enhanced empty state appears when no expenses and callback provided',
      (tester) async {
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
        expect(
          find.text('Pronti per iniziare?'),
          findsOneWidget,
        ); // Italian title
        expect(
          find.text('Aggiungi la prima spesa per iniziare con questo gruppo!'),
          findsOneWidget,
        ); // Italian subtitle
        expect(
          find.text('Aggiungi Prima Spesa'),
          findsOneWidget,
        ); // Italian button text

        // Check that the call-to-action button is present and works
        final addButton = find.text('Aggiungi Prima Spesa');
        expect(addButton, findsOneWidget);

        await tester.tap(addButton);
        await tester.pumpAndSettle();

        expect(addExpenseCalled, isTrue);
      },
    );

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
      expect(
        imageWidget.evaluate().isNotEmpty || iconWidget.evaluate().isNotEmpty,
        isTrue,
      );

      // Check English text is displayed correctly
      expect(find.text('Ready to start tracking?'), findsOneWidget);
      expect(
        find.text('Add your first expense to get started with this group!'),
        findsOneWidget,
      );
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
      expect(
        find.text('Pronti per iniziare?'),
        findsNothing,
      ); // Enhanced state title
      expect(
        find.text('Nessuna spesa trovata con i filtri selezionati'),
        findsOneWidget,
      ); // Simple filtered state
      expect(
        find.byIcon(Icons.search_off_outlined),
        findsOneWidget,
      ); // Search off icon for filtered state
    });

    testWidgets('Month headers are displayed when expenses span multiple months', (
      tester,
    ) async {
      // Create expenses from different months
      final expensesMultipleMonths = [
        ExpenseDetails(
          id: 'exp1',
          name: 'January expense',
          amount: 25.50,
          category: testCategories[0],
          paidBy: testParticipants[0],
          date: DateTime(2024, 1, 15),
        ),
        ExpenseDetails(
          id: 'exp2',
          name: 'February expense 1',
          amount: 30.00,
          category: testCategories[1],
          paidBy: testParticipants[1],
          date: DateTime(2024, 2, 10),
        ),
        ExpenseDetails(
          id: 'exp3',
          name: 'February expense 2',
          amount: 15.00,
          category: testCategories[0],
          paidBy: testParticipants[0],
          date: DateTime(2024, 2, 20),
        ),
        ExpenseDetails(
          id: 'exp4',
          name: 'March expense',
          amount: 40.00,
          category: testCategories[1],
          paidBy: testParticipants[1],
          date: DateTime(2024, 3, 5),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: FilteredExpenseList(
              expenses: expensesMultipleMonths,
              currency: '€',
              onExpenseTap: (expense) {},
              categories: testCategories,
              participants: testParticipants,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that all expenses are displayed
      expect(find.text('January expense'), findsOneWidget);
      expect(find.text('February expense 1'), findsOneWidget);
      expect(find.text('February expense 2'), findsOneWidget);
      expect(find.text('March expense'), findsOneWidget);

      // Check that month headers are present
      // Note: The exact text will be in Italian (e.g., "marzo 2024", "febbraio 2024", "gennaio 2024")
      // We'll look for text widgets that contain year and month patterns
      final textWidgets = find.byType(Text);
      final List<String> allText = [];
      for (var element in textWidgets.evaluate()) {
        final widget = element.widget as Text;
        final data = widget.data;
        if (data != null) {
          allText.add(data);
        }
      }

      // Check for Italian month names (at least some should be present)
      final hasMonthHeaders = allText.any((text) => 
        text.contains('2024') && 
        (text.contains('gennaio') || text.contains('febbraio') || text.contains('marzo'))
      );
      expect(hasMonthHeaders, isTrue, reason: 'Expected to find month headers with year');
    });

    testWidgets('Single month does not show redundant headers', (
      tester,
    ) async {
      // All expenses from the same month
      final singleMonthExpenses = [
        ExpenseDetails(
          id: 'exp1',
          name: 'Expense 1',
          amount: 25.50,
          category: testCategories[0],
          paidBy: testParticipants[0],
          date: DateTime(2024, 3, 1),
        ),
        ExpenseDetails(
          id: 'exp2',
          name: 'Expense 2',
          amount: 30.00,
          category: testCategories[1],
          paidBy: testParticipants[1],
          date: DateTime(2024, 3, 15),
        ),
        ExpenseDetails(
          id: 'exp3',
          name: 'Expense 3',
          amount: 15.00,
          category: testCategories[0],
          paidBy: testParticipants[0],
          date: DateTime(2024, 3, 28),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: FilteredExpenseList(
              expenses: singleMonthExpenses,
              currency: '€',
              onExpenseTap: (expense) {},
              categories: testCategories,
              participants: testParticipants,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that all expenses are displayed
      expect(find.text('Expense 1'), findsOneWidget);
      expect(find.text('Expense 2'), findsOneWidget);
      expect(find.text('Expense 3'), findsOneWidget);

      // There should still be a month header (one), not redundant multiple headers
      final textWidgets = find.byType(Text);
      final List<String> allText = [];
      for (var element in textWidgets.evaluate()) {
        final widget = element.widget as Text;
        final data = widget.data;
        if (data != null && data.contains('2024')) {
          allText.add(data);
        }
      }

      // Should have exactly one month header with year
      final monthHeadersCount = allText.where((text) => 
        text.contains('marzo 2024')
      ).length;
      expect(monthHeadersCount, equals(1), reason: 'Expected exactly one month header');
    });

    testWidgets('Pagination loads initial 100 expenses', (tester) async {
      // Create more than 100 expenses
      final manyExpenses = List.generate(150, (i) {
        return ExpenseDetails(
          id: 'exp$i',
          name: 'Expense $i',
          amount: 10.0 + i,
          category: testCategories[i % 2],
          paidBy: testParticipants[i % 2],
          date: DateTime.now().subtract(Duration(days: i)),
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: FilteredExpenseList(
              expenses: manyExpenses,
              currency: '\$',
              onExpenseTap: (expense) {},
              categories: testCategories,
              participants: testParticipants,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show "Load more" button since there are 150 expenses
      expect(find.text('Load more expenses'), findsOneWidget);

      // First 100 expenses should be visible
      expect(find.text('Expense 0'), findsOneWidget);
      expect(find.text('Expense 99'), findsOneWidget);

      // Tap load more button
      await tester.tap(find.text('Load more expenses'));
      await tester.pumpAndSettle();

      // After loading more, more expenses should be visible
      // The button should still be there since we have 150 total
      expect(find.text('Expense 120'), findsOneWidget);
    });

    testWidgets('Pagination resets when filter changes', (tester) async {
      // Create more than 100 expenses with different categories
      final manyExpenses = List.generate(150, (i) {
        return ExpenseDetails(
          id: 'exp$i',
          name: 'Expense $i',
          amount: 10.0 + i,
          category: testCategories[i % 2],
          paidBy: testParticipants[i % 2],
          date: DateTime.now().subtract(Duration(days: i)),
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: FilteredExpenseList(
              expenses: manyExpenses,
              currency: '\$',
              onExpenseTap: (expense) {},
              categories: testCategories,
              participants: testParticipants,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open filters
      await tester.tap(find.byIcon(Icons.filter_list_outlined));
      await tester.pumpAndSettle();

      // Select a category filter
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Pagination should reset when filter is applied
      // This would be indicated by showing the first expenses again
      expect(find.text('Expense 0'), findsOneWidget);
    });
  });
}
