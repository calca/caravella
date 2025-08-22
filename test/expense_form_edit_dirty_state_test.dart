import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/expense_category.dart';
import 'package:org_app_caravella/data/expense_details.dart';
import 'package:org_app_caravella/data/expense_participant.dart';

void main() {
  group('Expense Form Edit Dirty State Detection', () {
    late ExpenseDetails originalExpense;
    late List<ExpenseParticipant> participants;
    late List<ExpenseCategory> categories;

    setUp(() {
      participants = [
        ExpenseParticipant(name: 'Alice'),
        ExpenseParticipant(name: 'Bob'),
      ];
      
      categories = [
        ExpenseCategory(name: 'Food', id: 'food-1', createdAt: DateTime.now()),
        ExpenseCategory(name: 'Transport', id: 'transport-1', createdAt: DateTime.now()),
      ];

      originalExpense = ExpenseDetails(
        name: 'Test Expense',
        amount: 25.50,
        paidBy: participants.first,
        category: categories.first,
        date: DateTime(2024, 1, 15),
        note: 'Test note',
      );
    });

    test('should detect no changes when form values match original expense', () {
      // Simulate the _hasActualChanges logic
      bool hasChanges({
        required String? currentName,
        required double? currentAmount,
        required ExpenseParticipant? currentPaidBy,
        required ExpenseCategory? currentCategory,
        required DateTime? currentDate,
        required String? currentNote,
      }) {
        return currentCategory?.id != originalExpense.category.id ||
            currentAmount != originalExpense.amount ||
            currentPaidBy?.name != originalExpense.paidBy.name ||
            currentDate != originalExpense.date ||
            (currentName ?? '').trim() != (originalExpense.name ?? '') ||
            (currentNote ?? '').trim() != (originalExpense.note ?? '');
      }

      // Test with exact same values - should be false (no changes)
      expect(hasChanges(
        currentName: originalExpense.name,
        currentAmount: originalExpense.amount,
        currentPaidBy: originalExpense.paidBy,
        currentCategory: originalExpense.category,
        currentDate: originalExpense.date,
        currentNote: originalExpense.note,
      ), false, reason: 'No changes should be detected when all values match original');
    });

    test('should detect changes when form values differ from original expense', () {
      // Simulate the _hasActualChanges logic
      bool hasChanges({
        required String? currentName,
        required double? currentAmount,
        required ExpenseParticipant? currentPaidBy,
        required ExpenseCategory? currentCategory,
        required DateTime? currentDate,
        required String? currentNote,
      }) {
        return currentCategory?.id != originalExpense.category.id ||
            currentAmount != originalExpense.amount ||
            currentPaidBy?.name != originalExpense.paidBy.name ||
            currentDate != originalExpense.date ||
            (currentName ?? '').trim() != (originalExpense.name ?? '') ||
            (currentNote ?? '').trim() != (originalExpense.note ?? '');
      }

      // Test name change
      expect(hasChanges(
        currentName: 'Modified Expense',
        currentAmount: originalExpense.amount,
        currentPaidBy: originalExpense.paidBy,
        currentCategory: originalExpense.category,
        currentDate: originalExpense.date,
        currentNote: originalExpense.note,
      ), true, reason: 'Changes should be detected when name is modified');

      // Test amount change
      expect(hasChanges(
        currentName: originalExpense.name,
        currentAmount: 30.00,
        currentPaidBy: originalExpense.paidBy,
        currentCategory: originalExpense.category,
        currentDate: originalExpense.date,
        currentNote: originalExpense.note,
      ), true, reason: 'Changes should be detected when amount is modified');

      // Test participant change
      expect(hasChanges(
        currentName: originalExpense.name,
        currentAmount: originalExpense.amount,
        currentPaidBy: participants[1], // Bob instead of Alice
        currentCategory: originalExpense.category,
        currentDate: originalExpense.date,
        currentNote: originalExpense.note,
      ), true, reason: 'Changes should be detected when paid by is modified');

      // Test category change
      expect(hasChanges(
        currentName: originalExpense.name,
        currentAmount: originalExpense.amount,
        currentPaidBy: originalExpense.paidBy,
        currentCategory: categories[1], // Transport instead of Food
        currentDate: originalExpense.date,
        currentNote: originalExpense.note,
      ), true, reason: 'Changes should be detected when category is modified');

      // Test date change
      expect(hasChanges(
        currentName: originalExpense.name,
        currentAmount: originalExpense.amount,
        currentPaidBy: originalExpense.paidBy,
        currentCategory: originalExpense.category,
        currentDate: DateTime(2024, 1, 16),
        currentNote: originalExpense.note,
      ), true, reason: 'Changes should be detected when date is modified');

      // Test note change
      expect(hasChanges(
        currentName: originalExpense.name,
        currentAmount: originalExpense.amount,
        currentPaidBy: originalExpense.paidBy,
        currentCategory: originalExpense.category,
        currentDate: originalExpense.date,
        currentNote: 'Modified note',
      ), true, reason: 'Changes should be detected when note is modified');
    });

    test('should handle whitespace trimming correctly', () {
      // Simulate the _hasActualChanges logic
      bool hasChanges({
        required String? currentName,
        required String? currentNote,
      }) {
        return (currentName ?? '').trim() != (originalExpense.name ?? '') ||
            (currentNote ?? '').trim() != (originalExpense.note ?? '');
      }

      // Test with whitespace that should be ignored
      expect(hasChanges(
        currentName: '  Test Expense  ',  // Same content with whitespace
        currentNote: '  Test note  ',    // Same content with whitespace
      ), false, reason: 'Whitespace should be trimmed when comparing');

      // Test actual content change
      expect(hasChanges(
        currentName: '  Different Expense  ',
        currentNote: originalExpense.note,
      ), true, reason: 'Actual content changes should be detected after trimming');
    });

    test('should handle null values correctly', () {
      // Create expense with null name and note
      final expenseWithNulls = ExpenseDetails(
        amount: 25.50,
        paidBy: participants.first,
        category: categories.first,
        date: DateTime(2024, 1, 15),
        name: null,
        note: null,
      );

      // Simulate the _hasActualChanges logic for null handling
      bool hasChanges({
        required String? currentName,
        required String? currentNote,
      }) {
        return (currentName ?? '').trim() != (expenseWithNulls.name ?? '') ||
            (currentNote ?? '').trim() != (expenseWithNulls.note ?? '');
      }

      // Empty strings should equal null
      expect(hasChanges(
        currentName: '',
        currentNote: '',
      ), false, reason: 'Empty strings should be equivalent to null values');

      // Non-empty strings should differ from null
      expect(hasChanges(
        currentName: 'Some name',
        currentNote: null,
      ), true, reason: 'Non-empty string should differ from null');
    });
  });
}