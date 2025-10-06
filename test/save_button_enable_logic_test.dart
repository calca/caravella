import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';

void main() {
  group('Save button enable logic', () {
    test('hasChanges should be false in edit mode when no changes made', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);

      // Set up a valid original group
      final originalGroup = ExpenseGroup(
        id: 'test-group',
        title: 'Original Title',
        expenses: const [],
        participants: [ExpenseParticipant(name: 'John', id: 'p1')],
        categories: [ExpenseCategory(name: 'Food', id: 'c1')],
        startDate: null,
        endDate: null,
        currency: 'EUR',
        file: null,
        color: null,
        timestamp: DateTime.now(),
      );

      // Load the group (simulates opening edit page)
      controller.load(originalGroup);

      // Verify form is valid but hasChanges is false
      expect(state.isValid, isTrue, reason: 'Form should be valid');
      expect(
        controller.hasChanges,
        isFalse,
        reason: 'No changes made yet, hasChanges should be false',
      );
    });

    test('hasChanges should be true in edit mode when title is modified', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);

      final originalGroup = ExpenseGroup(
        id: 'test-group',
        title: 'Original Title',
        expenses: const [],
        participants: [ExpenseParticipant(name: 'John', id: 'p1')],
        categories: [ExpenseCategory(name: 'Food', id: 'c1')],
        startDate: null,
        endDate: null,
        currency: 'EUR',
        file: null,
        color: null,
        timestamp: DateTime.now(),
      );

      controller.load(originalGroup);

      // Modify the title
      state.setTitle('Modified Title');

      // Verify hasChanges is now true
      expect(state.isValid, isTrue, reason: 'Form should still be valid');
      expect(
        controller.hasChanges,
        isTrue,
        reason: 'Title changed, hasChanges should be true',
      );
    });

    test(
      'hasChanges should be true in edit mode when participant is added',
      () {
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);

        final originalGroup = ExpenseGroup(
          id: 'test-group',
          title: 'Test Group',
          expenses: const [],
          participants: [ExpenseParticipant(name: 'John', id: 'p1')],
          categories: [ExpenseCategory(name: 'Food', id: 'c1')],
          startDate: null,
          endDate: null,
          currency: 'EUR',
          file: null,
          color: null,
          timestamp: DateTime.now(),
        );

        controller.load(originalGroup);

        // Add a new participant
        state.addParticipant(ExpenseParticipant(name: 'Jane', id: 'p2'));

        // Verify hasChanges is true
        expect(state.isValid, isTrue);
        expect(
          controller.hasChanges,
          isTrue,
          reason: 'Participant added, hasChanges should be true',
        );
      },
    );

    test('hasChanges should be true in edit mode when category is added', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);

      final originalGroup = ExpenseGroup(
        id: 'test-group',
        title: 'Test Group',
        expenses: const [],
        participants: [ExpenseParticipant(name: 'John', id: 'p1')],
        categories: [ExpenseCategory(name: 'Food', id: 'c1')],
        startDate: null,
        endDate: null,
        currency: 'EUR',
        file: null,
        color: null,
        timestamp: DateTime.now(),
      );

      controller.load(originalGroup);

      // Add a new category
      state.addCategory(ExpenseCategory(name: 'Transport', id: 'c2'));

      // Verify hasChanges is true
      expect(state.isValid, isTrue);
      expect(
        controller.hasChanges,
        isTrue,
        reason: 'Category added, hasChanges should be true',
      );
    });

    test('hasChanges should be true in edit mode when dates are modified', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);

      final originalGroup = ExpenseGroup(
        id: 'test-group',
        title: 'Test Group',
        expenses: const [],
        participants: [ExpenseParticipant(name: 'John', id: 'p1')],
        categories: [ExpenseCategory(name: 'Food', id: 'c1')],
        startDate: null,
        endDate: null,
        currency: 'EUR',
        file: null,
        color: null,
        timestamp: DateTime.now(),
      );

      controller.load(originalGroup);

      // Add dates
      state.setDates(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 5));

      // Verify hasChanges is true
      expect(state.isValid, isTrue);
      expect(
        controller.hasChanges,
        isTrue,
        reason: 'Dates changed, hasChanges should be true',
      );
    });

    test('hasChanges should be true in edit mode when color is changed', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);

      final originalGroup = ExpenseGroup(
        id: 'test-group',
        title: 'Test Group',
        expenses: const [],
        participants: [ExpenseParticipant(name: 'John', id: 'p1')],
        categories: [ExpenseCategory(name: 'Food', id: 'c1')],
        startDate: null,
        endDate: null,
        currency: 'EUR',
        file: null,
        color: 0xFF000000,
        timestamp: DateTime.now(),
      );

      controller.load(originalGroup);

      // Change color
      state.setColor(0xFFFFFFFF);

      // Verify hasChanges is true
      expect(state.isValid, isTrue);
      expect(
        controller.hasChanges,
        isTrue,
        reason: 'Color changed, hasChanges should be true',
      );
    });

    test('hasChanges should be false in create mode with empty form', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // In create mode with empty form
      expect(state.isValid, isFalse, reason: 'Empty form is invalid');
      expect(
        controller.hasChanges,
        isFalse,
        reason: 'In create mode, empty form has no changes',
      );
    });

    test('hasChanges should be true in create mode when user adds data', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // Add minimal data for valid form
      state.setTitle('New Group');
      state.addParticipant(ExpenseParticipant(name: 'John', id: 'p1'));
      state.addCategory(ExpenseCategory(name: 'Food', id: 'c1'));

      // In create mode, any data means changes
      expect(state.isValid, isTrue);
      expect(
        controller.hasChanges,
        isTrue,
        reason: 'In create mode, form with data has changes',
      );
    });

    test(
      'Save button logic: should be disabled when valid but no changes in edit mode',
      () {
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);

        final originalGroup = ExpenseGroup(
          id: 'test-group',
          title: 'Test Group',
          expenses: const [],
          participants: [ExpenseParticipant(name: 'John', id: 'p1')],
          categories: [ExpenseCategory(name: 'Food', id: 'c1')],
          startDate: null,
          endDate: null,
          currency: 'EUR',
          file: null,
          color: null,
          timestamp: DateTime.now(),
        );

        controller.load(originalGroup);

        // Compute button enabled state: isValid && !isSaving && hasChanges
        final shouldBeEnabled =
            state.isValid && !state.isSaving && controller.hasChanges;

        expect(state.isValid, isTrue);
        expect(controller.hasChanges, isFalse);
        expect(
          shouldBeEnabled,
          isFalse,
          reason:
              'Save button should be disabled when form is valid but no changes',
        );
      },
    );

    test(
      'Save button logic: should be enabled when valid and has changes in edit mode',
      () {
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);

        final originalGroup = ExpenseGroup(
          id: 'test-group',
          title: 'Test Group',
          expenses: const [],
          participants: [ExpenseParticipant(name: 'John', id: 'p1')],
          categories: [ExpenseCategory(name: 'Food', id: 'c1')],
          startDate: null,
          endDate: null,
          currency: 'EUR',
          file: null,
          color: null,
          timestamp: DateTime.now(),
        );

        controller.load(originalGroup);
        state.setTitle('Modified Title');

        // Compute button enabled state: isValid && !isSaving && hasChanges
        final shouldBeEnabled =
            state.isValid && !state.isSaving && controller.hasChanges;

        expect(state.isValid, isTrue);
        expect(controller.hasChanges, isTrue);
        expect(
          shouldBeEnabled,
          isTrue,
          reason: 'Save button should be enabled when valid and has changes',
        );
      },
    );
  });
}
