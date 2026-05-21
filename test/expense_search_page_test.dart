import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/manager/details/pages/expense_search_page.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';

void main() {
  group('ExpenseSearchPage Tests', () {
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
          date: DateTime(2024, 3, 15),
          note: 'Delicious pizza',
          location: ExpenseLocation(
            latitude: 41.9028,
            longitude: 12.4964,
            name: 'Rome',
          ),
          attachments: ['photo.jpg'],
        ),
        ExpenseDetails(
          id: 'exp2',
          name: 'Bus ticket',
          amount: 5.00,
          category: testCategories[1],
          paidBy: testParticipants[1],
          date: DateTime(2024, 3, 14),
          note: 'City transport',
        ),
        ExpenseDetails(
          id: 'exp3',
          name: 'Groceries',
          amount: 42.00,
          category: testCategories[0],
          paidBy: testParticipants[0],
          date: DateTime(2024, 3, 13),
          note: 'Weekly shopping',
        ),
      ];
    });

    Widget buildSearchPage({List<ExpenseDetails>? expenses}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ExpenseSearchPage(
          expenses: expenses ?? testExpenses,
          categories: testCategories,
          participants: testParticipants,
          currency: '€',
          groupName: 'Test group',
          onExpenseTap: (_) {},
        ),
      );
    }

    testWidgets('displays search page with all expenses', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      expect(find.text('Search in Test group'), findsOneWidget);

      // Verify all expenses are listed
      expect(find.text('Pizza dinner'), findsOneWidget);
      expect(find.text('Bus ticket'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('search input filters by expense name', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      // Type in search box
      await tester.enterText(
        find.byType(TextField),
        'Pizza',
      );
      await tester.pumpAndSettle();

      // Only Pizza dinner should be visible
      expect(find.text('Pizza dinner'), findsOneWidget);
      expect(find.text('Bus ticket'), findsNothing);
      expect(find.text('Groceries'), findsNothing);
    });

    testWidgets('search input filters by note', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'transport');
      await tester.pumpAndSettle();

      expect(find.text('Bus ticket'), findsOneWidget);
      expect(find.text('Pizza dinner'), findsNothing);
    });

    testWidgets('search input filters by category name', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Transport');
      await tester.pumpAndSettle();

      // Bus ticket is in Transport category
      expect(find.text('Bus ticket'), findsOneWidget);
      expect(find.text('Pizza dinner'), findsNothing);
    });

    testWidgets('search input filters by participant name', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Bob');
      await tester.pumpAndSettle();

      // Bob paid for Bus ticket
      expect(find.text('Bus ticket'), findsOneWidget);
      expect(find.text('Pizza dinner'), findsNothing);
    });

    testWidgets('displays filter chips for categories and participants',
        (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      // Category chips
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);

      // Participant chips
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      // Special filter chips
      expect(find.text('Has attachment'), findsOneWidget);
      expect(find.text('Has location'), findsOneWidget);
    });

    testWidgets('category chip filters expenses', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      // Tap Food category chip
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Only Food expenses should be shown (Pizza dinner and Groceries)
      expect(find.text('Pizza dinner'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Bus ticket'), findsNothing);
    });

    testWidgets('participant chip filters expenses', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      // Tap Bob participant chip
      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();

      // Only Bob's expenses should be shown
      expect(find.text('Bus ticket'), findsOneWidget);
      expect(find.text('Pizza dinner'), findsNothing);
      expect(find.text('Groceries'), findsNothing);
    });

    testWidgets('has attachment filter works', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      // Tap "Has attachment" chip
      await tester.tap(find.text('Has attachment'));
      await tester.pumpAndSettle();

      // Only Pizza dinner has an attachment
      expect(find.text('Pizza dinner'), findsOneWidget);
      expect(find.text('Bus ticket'), findsNothing);
      expect(find.text('Groceries'), findsNothing);
    });

    testWidgets('has location filter works', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      // Tap "Has location" chip
      await tester.tap(find.text('Has location'));
      await tester.pumpAndSettle();

      // Only Pizza dinner has a location
      expect(find.text('Pizza dinner'), findsOneWidget);
      expect(find.text('Bus ticket'), findsNothing);
      expect(find.text('Groceries'), findsNothing);
    });

    testWidgets('date filter chips are displayed', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
      expect(find.text('Select period'), findsOneWidget);
    });

    testWidgets('today chip filters expenses', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 12);
      final todayExpenses = [
        ExpenseDetails(
          id: 'today',
          name: 'Today expense',
          amount: 10.00,
          category: testCategories[0],
          paidBy: testParticipants[0],
          date: today,
        ),
        ExpenseDetails(
          id: 'yesterday',
          name: 'Yesterday expense',
          amount: 20.00,
          category: testCategories[1],
          paidBy: testParticipants[1],
          date: today.subtract(const Duration(days: 1)),
        ),
      ];

      await tester.pumpWidget(buildSearchPage(expenses: todayExpenses));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.text('Today expense'), findsOneWidget);
      expect(find.text('Yesterday expense'), findsNothing);
    });

    testWidgets('this month chip filters expenses', (tester) async {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 10);
      final lastMonth = DateTime(now.year, now.month, 1).subtract(
        const Duration(days: 1),
      );
      final monthExpenses = [
        ExpenseDetails(
          id: 'current-month',
          name: 'Current month expense',
          amount: 12.00,
          category: testCategories[0],
          paidBy: testParticipants[0],
          date: thisMonth,
        ),
        ExpenseDetails(
          id: 'last-month',
          name: 'Last month expense',
          amount: 8.00,
          category: testCategories[1],
          paidBy: testParticipants[1],
          date: lastMonth,
        ),
      ];

      await tester.pumpWidget(buildSearchPage(expenses: monthExpenses));
      await tester.pumpAndSettle();

      await tester.tap(find.text('This month'));
      await tester.pumpAndSettle();

      expect(find.text('Current month expense'), findsOneWidget);
      expect(find.text('Last month expense'), findsNothing);
    });

    testWidgets('clear button resets all filters', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      // Apply a search filter
      await tester.enterText(find.byType(TextField), 'Pizza');
      await tester.pumpAndSettle();

      expect(find.byTooltip('Clear'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear'));
      await tester.pumpAndSettle();

      // All expenses should be shown again
      expect(find.text('Pizza dinner'), findsOneWidget);
      expect(find.text('Bus ticket'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('empty state shows when no results match', (tester) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      // Search for something that doesn't exist
      await tester.enterText(find.byType(TextField), 'xyznonexistent');
      await tester.pumpAndSettle();

      // Empty state should be shown
      expect(find.text('No expenses found'), findsOneWidget);
      expect(
        find.text('Try different search terms or adjust filters'),
        findsOneWidget,
      );
    });

    testWidgets('empty expense list shows initial empty state', (
      tester,
    ) async {
      await tester.pumpWidget(buildSearchPage(expenses: []));
      await tester.pumpAndSettle();

      // Should show the search page title as placeholder
      expect(find.text('Search expenses'), findsAtLeast(1));
    });

    testWidgets('toggling category chip off restores all expenses', (
      tester,
    ) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      // Tap Food to filter
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      expect(find.text('Bus ticket'), findsNothing);

      // Tap Food again to deselect
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      expect(find.text('Bus ticket'), findsOneWidget);
    });

    testWidgets('range chip opens reusable period selector', (
      tester,
    ) async {
      await tester.pumpWidget(buildSearchPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select period'));
      await tester.pumpAndSettle();

      expect(find.text('Suggested duration'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });
  });
}
