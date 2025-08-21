import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/expense_group.dart';
import 'package:org_app_caravella/data/expense_details.dart';
import 'package:org_app_caravella/data/expense_participant.dart';
import 'package:org_app_caravella/data/expense_category.dart';

void main() {
  group('ExpenseGroup copyWith behavior', () {
    test('copyWith preserves expenses when not specified', () {
      // Create a group with expenses (simulating existing data)
      final originalGroup = ExpenseGroup(
        id: 'test-1',
        title: 'Original Title', 
        expenses: [
          ExpenseDetails(
            id: 'expense-1',
            title: 'Hotel',
            amount: 200.0,
            paidBy: 'Alice',
            splitBetween: ['Alice', 'Bob'],
            category: 'accommodation',
            timestamp: DateTime.now(),
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

      // Update only metadata (title, pinned status) without specifying expenses
      final updatedGroup = originalGroup.copyWith(
        title: 'Updated Title',
        pinned: true,
        // Note: NOT specifying expenses parameter
      );

      // Verify metadata was updated
      expect(updatedGroup.title, equals('Updated Title'));
      expect(updatedGroup.pinned, isTrue);
      
      // Most importantly: verify expenses were preserved
      expect(updatedGroup.expenses.length, equals(1));
      expect(updatedGroup.expenses[0].title, equals('Hotel'));
      expect(updatedGroup.expenses[0].amount, equals(200.0));
      
      // Verify other fields were preserved
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
            title: 'Old Expense',
            amount: 100.0,
            paidBy: 'Alice',
            splitBetween: ['Alice'],
            category: 'food',
            timestamp: DateTime.now(),
          ),
        ],
        participants: [],
        categories: [],
        currency: 'EUR',
      );

      // Explicitly update expenses
      final updatedGroup = originalGroup.copyWith(
        expenses: [
          ExpenseDetails(
            id: 'expense-2',
            title: 'New Expense',
            amount: 150.0,
            paidBy: 'Bob',
            splitBetween: ['Bob'],
            category: 'transport',
            timestamp: DateTime.now(),
          ),
        ],
      );

      // Verify expenses were updated
      expect(updatedGroup.expenses.length, equals(1));
      expect(updatedGroup.expenses[0].title, equals('New Expense'));
      expect(updatedGroup.expenses[0].amount, equals(150.0));
    });

    test('copyWith with empty expenses list', () {
      final originalGroup = ExpenseGroup(
        title: 'Test Group',
        expenses: [
          ExpenseDetails(
            id: 'expense-1',
            title: 'Will be removed',
            amount: 100.0,
            paidBy: 'Alice',
            splitBetween: ['Alice'],
            category: 'food',
            timestamp: DateTime.now(),
          ),
        ],
        participants: [],
        categories: [],
        currency: 'EUR',
      );

      // Explicitly set expenses to empty list
      final updatedGroup = originalGroup.copyWith(
        expenses: [],
      );

      // Verify expenses were cleared
      expect(updatedGroup.expenses.length, equals(0));
    });
  });
}