import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/expense/components/expense_form_config.dart';

void main() {
  group('Archived Group Read-Only Behavior', () {
    test('ExpenseFormConfig should accept isReadOnly parameter', () {
      final config = ExpenseFormConfig(
        participants: [],
        categories: [],
        groupId: 'test-group',
        onExpenseAdded: (_) {},
        onCategoryAdded: (_) {},
        autoLocationEnabled: false,
        isReadOnly: true,
      );

      expect(config.isReadOnly, true);
    });

    test('ExpenseFormConfig.create should accept isReadOnly parameter', () {
      final config = ExpenseFormConfig.create(
        participants: [],
        categories: [],
        groupId: 'test-group',
        onExpenseAdded: (_) {},
        onCategoryAdded: (_) {},
        autoLocationEnabled: false,
        isReadOnly: true,
      );

      expect(config.isReadOnly, true);
    });

    test('ExpenseFormConfig.edit should accept isReadOnly parameter', () {
      final participant = ExpenseParticipant(name: 'Test', id: '1');
      final config = ExpenseFormConfig.edit(
        initialExpense: ExpenseDetails(
          id: 'test-expense',
          name: 'Test Expense',
          amount: 100.0,
          paidBy: participant,
          category: ExpenseCategory(name: 'Test', id: '1'),
          date: DateTime.now(),
        ),
        participants: [],
        categories: [],
        groupId: 'test-group',
        onExpenseAdded: (_) {},
        onCategoryAdded: (_) {},
        autoLocationEnabled: false,
        isReadOnly: true,
      );

      expect(config.isReadOnly, true);
    });

    test('ExpenseFormConfig should default isReadOnly to false', () {
      final config = ExpenseFormConfig(
        participants: [],
        categories: [],
        groupId: 'test-group',
        onExpenseAdded: (_) {},
        onCategoryAdded: (_) {},
        autoLocationEnabled: false,
      );

      expect(config.isReadOnly, false);
    });

    test('ExpenseGroup archived field should be accessible', () {
      final group = ExpenseGroup(
        title: 'Test Group',
        expenses: [],
        participants: [],
        currency: '€',
        archived: true,
      );

      expect(group.archived, true);
    });

    test('ExpenseGroup should default archived to false', () {
      final group = ExpenseGroup(
        title: 'Test Group',
        expenses: [],
        participants: [],
        currency: '€',
      );

      expect(group.archived, false);
    });

    test('ExpenseGroup copyWith should preserve archived status', () {
      final group = ExpenseGroup(
        title: 'Test Group',
        expenses: [],
        participants: [],
        currency: '€',
        archived: true,
      );

      final updated = group.copyWith(title: 'Updated Group');

      expect(updated.archived, true);
      expect(updated.title, 'Updated Group');
    });

    test('ExpenseGroup copyWith should allow changing archived status', () {
      final group = ExpenseGroup(
        title: 'Test Group',
        expenses: [],
        participants: [],
        currency: '€',
        archived: false,
      );

      final archived = group.copyWith(archived: true);

      expect(archived.archived, true);
    });
  });
}
