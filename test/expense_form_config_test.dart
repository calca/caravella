import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/expense/components/expense_form_config.dart';
import 'package:io_caravella_egm/manager/expense/state/expense_form_state.dart';

void main() {
  group('ExpenseFormConfig', () {
    final mockParticipants = [
      ExpenseParticipant(id: '1', name: 'Alice'),
      ExpenseParticipant(id: '2', name: 'Bob'),
    ];

    final mockCategories = [
      ExpenseCategory(id: 'cat1', name: 'Food', createdAt: DateTime(2024)),
      ExpenseCategory(id: 'cat2', name: 'Transport', createdAt: DateTime(2024)),
    ];

    test('create factory creates config for new expense', () {
      final config = ExpenseFormConfig.create(
        participants: mockParticipants,
        categories: mockCategories,
        groupId: 'group123',
        onExpenseAdded: (_) {},
        onCategoryAdded: (_) {},
        autoLocationEnabled: true,
      );

      expect(config.isCreateMode, true);
      expect(config.isEditMode, false);
      expect(config.initialExpense, isNull);
      expect(config.participants, mockParticipants);
      expect(config.categories, mockCategories);
      expect(config.groupId, 'group123');
      expect(config.autoLocationEnabled, true);
      expect(config.fullEdit, false);
      expect(config.showGroupHeader, true);
      expect(config.showActionsRow, true);
      expect(config.hasDeleteAction, false);
    });

    test('edit factory creates config for existing expense', () {
      final expense = ExpenseDetails(
        id: 'exp1',
        name: 'Test Expense',
        amount: 50.0,
        paidBy: mockParticipants[0],
        category: mockCategories[0],
        date: DateTime(2024, 1, 1),
      );

      final config = ExpenseFormConfig.edit(
        initialExpense: expense,
        participants: mockParticipants,
        categories: mockCategories,
        groupId: 'group123',
        onExpenseAdded: (_) {},
        onCategoryAdded: (_) {},
        autoLocationEnabled: true,
        onDelete: () {},
      );

      expect(config.isEditMode, true);
      expect(config.isCreateMode, false);
      expect(config.initialExpense, expense);
      expect(config.fullEdit, true);
      expect(config.showGroupHeader, false);
      expect(config.hasDeleteAction, true);
      expect(config.shouldAutoClose, true);
    });

    test('config with all optional parameters', () {
      final config = ExpenseFormConfig.create(
        participants: mockParticipants,
        categories: mockCategories,
        groupId: 'group123',
        onExpenseAdded: (_) {},
        onCategoryAdded: (_) {},
        autoLocationEnabled: false,
        groupTitle: 'Trip to Rome',
        currency: 'EUR',
        tripStartDate: DateTime(2024, 1, 1),
        tripEndDate: DateTime(2024, 1, 7),
        newlyAddedCategory: 'cat1',
        fullEdit: true,
        showGroupHeader: false,
        showActionsRow: false,
      );

      expect(config.groupTitle, 'Trip to Rome');
      expect(config.currency, 'EUR');
      expect(config.tripStartDate, DateTime(2024, 1, 1));
      expect(config.tripEndDate, DateTime(2024, 1, 7));
      expect(config.newlyAddedCategory, 'cat1');
      expect(config.fullEdit, true);
      expect(config.showGroupHeader, false);
      expect(config.showActionsRow, false);
    });

    test('config with callbacks', () {
      var expenseAdded = false;
      var categoryAdded = false;
      var expanded = false;
      var validityChanged = false;
      var saveCallbackChanged = false;

      final config = ExpenseFormConfig.create(
        participants: mockParticipants,
        categories: mockCategories,
        groupId: 'group123',
        onExpenseAdded: (_) => expenseAdded = true,
        onCategoryAdded: (_) => categoryAdded = true,
        autoLocationEnabled: true,
        onExpand: (_) => expanded = true,
        onFormValidityChanged: (_) => validityChanged = true,
        onSaveCallbackChanged: (_) => saveCallbackChanged = true,
      );

      // Test callbacks
      config.onExpenseAdded(
        ExpenseDetails(
          amount: 10,
          paidBy: mockParticipants[0],
          category: mockCategories[0],
          date: DateTime.now(),
        ),
      );
      expect(expenseAdded, true);

      config.onCategoryAdded('New Category');
      expect(categoryAdded, true);

      config.onExpand?.call(
        ExpenseFormState.initial(
          participants: mockParticipants,
          categories: mockCategories,
        ),
      );
      expect(expanded, true);

      config.onFormValidityChanged?.call(true);
      expect(validityChanged, true);

      config.onSaveCallbackChanged?.call(() {});
      expect(saveCallbackChanged, true);
    });

    test('hasDeleteAction returns true only when onDelete is provided', () {
      final configWithDelete = ExpenseFormConfig(
        participants: mockParticipants,
        categories: mockCategories,
        groupId: 'group123',
        onExpenseAdded: (_) {},
        onCategoryAdded: (_) {},
        autoLocationEnabled: true,
        onDelete: () {},
      );

      final configWithoutDelete = ExpenseFormConfig(
        participants: mockParticipants,
        categories: mockCategories,
        groupId: 'group123',
        onExpenseAdded: (_) {},
        onCategoryAdded: (_) {},
        autoLocationEnabled: true,
      );

      expect(configWithDelete.hasDeleteAction, true);
      expect(configWithoutDelete.hasDeleteAction, false);
    });
  });
}
