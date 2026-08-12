import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/expense/state/expense_form_state.dart';

void main() {
  group('ExpenseFormState.initial default selection', () {
    test('defaults paidBy and category to the first list entry', () {
      final alice = ExpenseParticipant(id: 'p1', name: 'Alice');
      final bob = ExpenseParticipant(id: 'p2', name: 'Bob');
      final food = ExpenseCategory(id: 'c1', name: 'Food');
      final transport = ExpenseCategory(id: 'c2', name: 'Transport');

      final state = ExpenseFormState.initial(
        participants: [alice, bob],
        categories: [food, transport],
      );

      expect(state.paidBy, alice);
      expect(state.category, food);
    });

    test(
      'combined with last-used ordering, creation defaults to the most '
      'recently used participant and category',
      () {
        final alice = ExpenseParticipant(id: 'p1', name: 'Alice');
        final bob = ExpenseParticipant(id: 'p2', name: 'Bob');
        final food = ExpenseCategory(id: 'c1', name: 'Food');
        final transport = ExpenseCategory(id: 'c2', name: 'Transport');

        final group = ExpenseGroup(
          title: 'Trip',
          currency: '€',
          participants: [alice, bob],
          categories: [food, transport],
          expenses: [
            ExpenseDetails(
              category: food,
              amount: 10,
              paidBy: alice,
              date: DateTime(2024, 1, 1),
            ),
            ExpenseDetails(
              category: transport,
              amount: 5,
              paidBy: bob,
              date: DateTime(2024, 1, 10),
            ),
          ],
        );

        final state = ExpenseFormState.initial(
          participants: group.getParticipantsByLastUsed(),
          categories: group.getCategoriesByLastUsed(),
        );

        // Bob paid most recently (Jan 10) and Transport was the most
        // recently used category (also Jan 10), so both should be
        // pre-selected by default when creating a new expense.
        expect(state.paidBy, bob);
        expect(state.category, transport);
      },
    );

    test('with no participants or categories, selection stays null', () {
      final state = ExpenseFormState.initial(
        participants: const [],
        categories: const [],
      );

      expect(state.paidBy, isNull);
      expect(state.category, isNull);
    });
  });
}
