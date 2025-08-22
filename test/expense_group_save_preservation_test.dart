import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/model/expense_details.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
import 'package:org_app_caravella/manager/group/group_form_controller.dart';
import 'package:org_app_caravella/manager/group/data/group_form_state.dart';
import 'package:org_app_caravella/manager/group/group_edit_mode.dart';

void main() {
  group('ExpenseGroup Save Preservation Tests', () {
    test('should preserve expenses when saving group modifications', () async {
      // Arrange: Create a group with existing expenses
      final originalGroup = ExpenseGroup(
        title: 'Original Trip',
        expenses: [
          ExpenseDetails(
            id: '1',
            name: 'Hotel',
            amount: 100.0,
            paidBy: ExpenseParticipant(name: 'Alice'),
            category: ExpenseCategory(
              name: 'Accommodation',
              id: 'cat1',
              createdAt: DateTime.now(),
            ),
            date: DateTime.now(),
          ),
          ExpenseDetails(
            id: '2',
            name: 'Dinner',
            amount: 50.0,
            paidBy: ExpenseParticipant(name: 'Bob'),
            category: ExpenseCategory(
              name: 'Food',
              id: 'cat2',
              createdAt: DateTime.now(),
            ),
            date: DateTime.now(),
          ),
        ],
        participants: [
          ExpenseParticipant(name: 'Alice'),
          ExpenseParticipant(name: 'Bob'),
        ],
        currency: 'EUR',
        categories: [
          ExpenseCategory(
            name: 'Accommodation',
            id: 'cat1',
            createdAt: DateTime.now(),
          ),
          ExpenseCategory(name: 'Food', id: 'cat2', createdAt: DateTime.now()),
        ],
      );

      // Create controller and load the group
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);
      controller.load(originalGroup);

      // Act: Modify the group title (simulating a user edit)
      state.setTitle('Modified Trip');

      // Save the group
      final savedGroup = await controller.save();

      // Assert: Expenses should be preserved
      expect(
        savedGroup.expenses.length,
        equals(2),
        reason: 'All original expenses should be preserved',
      );
      expect(savedGroup.expenses[0].name, equals('Hotel'));
      expect(savedGroup.expenses[1].name, equals('Dinner'));
      expect(savedGroup.title, equals('Modified Trip'));
    });

    test(
      'should preserve expenses when modifying participants and categories',
      () async {
        // Arrange: Create a group with existing expenses
        final originalGroup = ExpenseGroup(
          title: 'Test Trip',
          expenses: [
            ExpenseDetails(
              id: '1',
              name: 'Bus ticket',
              amount: 25.0,
              paidBy: ExpenseParticipant(name: 'Charlie'),
              category: ExpenseCategory(
                name: 'Transport',
                id: 'cat1',
                createdAt: DateTime.now(),
              ),
              date: DateTime.now(),
            ),
          ],
          participants: [ExpenseParticipant(name: 'Charlie')],
          currency: 'EUR',
          categories: [
            ExpenseCategory(
              name: 'Transport',
              id: 'cat1',
              createdAt: DateTime.now(),
            ),
          ],
        );

        // Create controller and load the group
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);
        controller.load(originalGroup);

        // Act: Add a new participant and category
        state.addParticipant(ExpenseParticipant(name: 'Diana'));
        state.addCategory(
          ExpenseCategory(
            name: 'Entertainment',
            id: 'cat2',
            createdAt: DateTime.now(),
          ),
        );

        // Save the group
        final savedGroup = await controller.save();

        // Assert: Expenses should be preserved along with the new changes
        expect(
          savedGroup.expenses.length,
          equals(1),
          reason: 'Original expense should be preserved',
        );
        expect(savedGroup.expenses[0].name, equals('Bus ticket'));
        expect(
          savedGroup.participants.length,
          equals(2),
          reason: 'New participant should be added',
        );
        expect(
          savedGroup.categories.length,
          equals(2),
          reason: 'New category should be added',
        );
      },
    );

    test('should handle empty expenses list correctly', () async {
      // Arrange: Create a group with no expenses
      final originalGroup = ExpenseGroup(
        title: 'Empty Trip',
        expenses: [],
        participants: [ExpenseParticipant(name: 'Eve')],
        currency: 'EUR',
        categories: [],
      );

      // Create controller and load the group
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);
      controller.load(originalGroup);

      // Act: Modify the group
      state.setTitle('Modified Empty Trip');

      // Save the group
      final savedGroup = await controller.save();

      // Assert: Empty expenses list should remain empty
      expect(
        savedGroup.expenses.length,
        equals(0),
        reason: 'Empty expenses list should remain empty',
      );
      expect(savedGroup.title, equals('Modified Empty Trip'));
    });
  });
}
