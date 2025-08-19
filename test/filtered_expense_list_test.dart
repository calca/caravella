import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:org_app_caravella/manager/details/widgets/filtered_expense_list.dart';
import 'package:org_app_caravella/data/expense_details.dart';
import 'package:org_app_caravella/data/expense_category.dart';
import 'package:org_app_caravella/data/expense_participant.dart';

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

    testWidgets('FilteredExpenseList displays expenses correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
      expect(find.text('Cerca per nome o nota...'), findsNothing);

      // Tap the filter toggle button
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Now filters should be visible
      expect(find.text('Cerca per nome o nota...'), findsOneWidget);
      expect(find.text('Categoria'), findsOneWidget);
      expect(find.text('Pagato da'), findsOneWidget);
    });
  });
}