import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';

void main() {
  group('Notification Change Detection Tests', () {
    test('hasChanges detects notificationEnabled change from false to true', () {
      // Create an original group with notifications disabled
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [
          ExpenseParticipant(name: 'Alice'),
        ],
        categories: [
          ExpenseCategory(name: 'Food'),
        ],
        expenses: [],
        notificationEnabled: false,
      );

      // Create state and controller
      final state = GroupFormState();
      final controller = GroupFormController(
        state,
        GroupEditMode.edit,
      );

      // Load the original group
      controller.load(originalGroup);

      // Verify no changes initially
      expect(controller.hasChanges, false);

      // Change notification enabled state
      state.setNotificationEnabled(true);

      // Verify hasChanges now returns true
      expect(controller.hasChanges, true);
    });

    test('hasChanges detects notificationEnabled change from true to false', () {
      // Create an original group with notifications enabled
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [
          ExpenseParticipant(name: 'Alice'),
        ],
        categories: [
          ExpenseCategory(name: 'Food'),
        ],
        expenses: [],
        notificationEnabled: true,
      );

      // Create state and controller
      final state = GroupFormState();
      final controller = GroupFormController(
        state,
        GroupEditMode.edit,
      );

      // Load the original group
      controller.load(originalGroup);

      // Verify no changes initially
      expect(controller.hasChanges, false);

      // Change notification enabled state
      state.setNotificationEnabled(false);

      // Verify hasChanges now returns true
      expect(controller.hasChanges, true);
    });

    test('hasChanges returns false when notificationEnabled is not changed', () {
      // Create an original group with notifications enabled
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [
          ExpenseParticipant(name: 'Alice'),
        ],
        categories: [
          ExpenseCategory(name: 'Food'),
        ],
        expenses: [],
        notificationEnabled: true,
      );

      // Create state and controller
      final state = GroupFormState();
      final controller = GroupFormController(
        state,
        GroupEditMode.edit,
      );

      // Load the original group
      controller.load(originalGroup);

      // Verify no changes initially
      expect(controller.hasChanges, false);

      // Set notification to same value (no actual change)
      state.setNotificationEnabled(true);

      // Verify hasChanges still returns false
      expect(controller.hasChanges, false);
    });

    test(
      'hasChanges detects notificationEnabled change along with other changes',
      () {
        // Create an original group
        final originalGroup = ExpenseGroup(
          id: 'test-id',
          title: 'Test Trip',
          currency: '€',
          participants: [
            ExpenseParticipant(name: 'Alice'),
          ],
          categories: [
            ExpenseCategory(name: 'Food'),
          ],
          expenses: [],
          notificationEnabled: false,
        );

        // Create state and controller
        final state = GroupFormState();
        final controller = GroupFormController(
          state,
          GroupEditMode.edit,
        );

        // Load the original group
        controller.load(originalGroup);

        // Change both title and notification state
        state.setTitle('Modified Trip');
        state.setNotificationEnabled(true);

        // Verify hasChanges returns true
        expect(controller.hasChanges, true);
      },
    );
  });
}
