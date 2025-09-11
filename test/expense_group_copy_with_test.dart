import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_details.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';

void main() {
  group('ExpenseGroup copyWith behavior', () {
    test('copyWith preserves expenses when not specified', () {
      final originalGroup = ExpenseGroup(
        id: 'test-1',
        title: 'Original Title',
        expenses: [
          ExpenseDetails(
            id: 'expense-1',
            name: 'Hotel',
            amount: 200.0,
            paidBy: ExpenseParticipant(name: 'Alice'),
            category: ExpenseCategory(name: 'accommodation'),
            date: DateTime.now(),
          ),
        ],
        participants: [
          ExpenseParticipant(name: 'Alice'),
          ExpenseParticipant(name: 'Bob'),
        ],
        categories: [ExpenseCategory(name: 'accommodation')],
        currency: 'EUR',
        pinned: false,
      );

      final updatedGroup = originalGroup.copyWith(
        title: 'Updated Title',
        pinned: true,
      );

      expect(updatedGroup.title, equals('Updated Title'));
      expect(updatedGroup.pinned, isTrue);
      expect(updatedGroup.expenses.length, equals(1));
      expect(updatedGroup.expenses[0].name, equals('Hotel'));
      expect(updatedGroup.expenses[0].amount, equals(200.0));
      expect(updatedGroup.participants.length, equals(2));
      expect(updatedGroup.categories.length, equals(1));
      expect(updatedGroup.currency, equals('EUR'));
    });

    test('copyWith can explicitly update expenses', () {
      final originalGroup = ExpenseGroup(
        title: 'Test Group',
        expenses: [
          ExpenseDetails(
            id: 'expense-1',
            name: 'Old Expense',
            amount: 100.0,
            paidBy: ExpenseParticipant(name: 'Alice'),
            category: ExpenseCategory(name: 'food'),
            date: DateTime.now(),
          ),
        ],
        participants: const [],
        categories: const [],
        currency: 'EUR',
      );

      final updatedGroup = originalGroup.copyWith(
        expenses: [
          ExpenseDetails(
            id: 'expense-2',
            name: 'New Expense',
            amount: 150.0,
            paidBy: ExpenseParticipant(name: 'Bob'),
            category: ExpenseCategory(name: 'transport'),
            date: DateTime.now(),
          ),
        ],
      );

      expect(updatedGroup.expenses, hasLength(1));
      expect(updatedGroup.expenses.first.name, 'New Expense');
      expect(updatedGroup.expenses.first.amount, 150.0);
    });

    test('copyWith with empty expenses list', () {
      final originalGroup = ExpenseGroup(
        title: 'Another Group',
        expenses: [
          ExpenseDetails(
            id: 'expense-1',
            name: 'Will be removed',
            amount: 100.0,
            paidBy: ExpenseParticipant(name: 'Alice'),
            category: ExpenseCategory(name: 'food'),
            date: DateTime.now(),
          ),
        ],
        participants: const [],
        categories: const [],
        currency: 'EUR',
      );

      final updatedGroup = originalGroup.copyWith(expenses: []);

      expect(updatedGroup.expenses, isEmpty);
    });
  });
}
