import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';

/// Test to verify that when editing a group, new participants and categories
/// are properly saved and persisted.
void main() {
  group('Group Edit - Add Participants and Categories', () {
    test(
      'should save new participants when editing an existing group',
      () async {
        // Arrange: Create an existing group with one participant
        final originalGroup = ExpenseGroup(
          title: 'Test Trip',
          expenses: [],
          participants: [
            ExpenseParticipant(name: 'Alice', id: 'p1'),
          ],
          currency: 'EUR',
          categories: [
            ExpenseCategory(name: 'Food', id: 'c1'),
          ],
        );

        // Create controller in edit mode and load the group
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);
        controller.load(originalGroup);

        // Verify initial state
        expect(state.participants.length, equals(1));
        expect(state.participants[0].name, equals('Alice'));
        expect(state.originalGroup, isNotNull);

        // Act: Add a new participant (simulating user action)
        state.addParticipant(ExpenseParticipant(name: 'Bob'));

        // Verify state updated
        expect(state.participants.length, equals(2));
        expect(state.participants[1].name, equals('Bob'));

        // Save the group
        final savedGroup = await controller.save();

        // Assert: The saved group should have both participants
        expect(
          savedGroup.participants.length,
          equals(2),
          reason: 'Saved group should have both original and new participant',
        );
        expect(savedGroup.participants[0].name, equals('Alice'));
        expect(savedGroup.participants[1].name, equals('Bob'));
      },
    );

    test(
      'should save new categories when editing an existing group',
      () async {
        // Arrange: Create an existing group with one category
        final originalGroup = ExpenseGroup(
          title: 'Test Trip',
          expenses: [],
          participants: [
            ExpenseParticipant(name: 'Alice', id: 'p1'),
          ],
          currency: 'EUR',
          categories: [
            ExpenseCategory(name: 'Food', id: 'c1'),
          ],
        );

        // Create controller in edit mode and load the group
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);
        controller.load(originalGroup);

        // Verify initial state
        expect(state.categories.length, equals(1));
        expect(state.categories[0].name, equals('Food'));

        // Act: Add a new category (simulating user action)
        state.addCategory(ExpenseCategory(name: 'Transport'));

        // Verify state updated
        expect(state.categories.length, equals(2));
        expect(state.categories[1].name, equals('Transport'));

        // Save the group
        final savedGroup = await controller.save();

        // Assert: The saved group should have both categories
        expect(
          savedGroup.categories.length,
          equals(2),
          reason: 'Saved group should have both original and new category',
        );
        expect(savedGroup.categories[0].name, equals('Food'));
        expect(savedGroup.categories[1].name, equals('Transport'));
      },
    );

    test(
      'should save both new participants and categories together',
      () async {
        // Arrange: Create an existing group
        final originalGroup = ExpenseGroup(
          title: 'Test Trip',
          expenses: [],
          participants: [
            ExpenseParticipant(name: 'Alice', id: 'p1'),
          ],
          currency: 'EUR',
          categories: [
            ExpenseCategory(name: 'Food', id: 'c1'),
          ],
        );

        // Create controller in edit mode and load the group
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);
        controller.load(originalGroup);

        // Act: Add both new participant and category
        state.addParticipant(ExpenseParticipant(name: 'Bob'));
        state.addCategory(ExpenseCategory(name: 'Transport'));

        // Save the group
        final savedGroup = await controller.save();

        // Assert: The saved group should have all participants and categories
        expect(savedGroup.participants.length, equals(2));
        expect(savedGroup.participants[0].name, equals('Alice'));
        expect(savedGroup.participants[1].name, equals('Bob'));
        
        expect(savedGroup.categories.length, equals(2));
        expect(savedGroup.categories[0].name, equals('Food'));
        expect(savedGroup.categories[1].name, equals('Transport'));
      },
    );
  });
}
