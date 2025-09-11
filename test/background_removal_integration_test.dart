import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';

/// Integration test verifying the complete background removal workflow
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Background removal integration tests', () {
    test(
      'Complete workflow: Edit group with color -> add image -> remove -> verify clean state',
      () async {
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);

        // Scenario: User is editing an existing group that has a red background color
        final originalGroup = ExpenseGroup(
          id: 'workflow-test',
          title: 'Trip to Italy',
          participants: [
            ExpenseParticipant(name: 'Alice'),
            ExpenseParticipant(name: 'Bob'),
          ],
          categories: [
            ExpenseCategory(name: 'Food'),
            ExpenseCategory(name: 'Transport'),
          ],
          expenses: [],
          currency: 'EUR',
          color: 0xFFE57373, // Red color
          file: null, // No image
        );

        // Load the group (simulates opening the edit form)
        controller.load(originalGroup);
        expect(state.color, equals(0xFFE57373));
        expect(state.imagePath, isNull);

        // User decides to add an image instead of using the color
        // (In real app, this would go through persistPickedImage, but we'll simulate the end result)
        state.setImage('/fake/path/to/image.jpg');
        expect(state.imagePath, equals('/fake/path/to/image.jpg'));
        expect(state.color, isNull, reason: 'Setting image should clear color');

        // User changes their mind and removes the background entirely
        await controller.removeImage();

        // Verify the background is completely clear (this was the bug)
        expect(state.imagePath, isNull);
        expect(state.color, isNull);

        // Verify the original group data is still intact for comparison
        expect(
          state.originalGroup?.color,
          equals(0xFFE57373),
          reason: 'Original group should not be modified',
        );

        // Verify hasChanges correctly detects the background change
        expect(
          controller.hasChanges,
          isTrue,
          reason:
              'Controller should detect background was removed from original',
        );
      },
    );

    test('UI state consistency: removal option availability', () {
      final state = GroupFormState();

      // Initially no background - removal should not be available
      expect(state.imagePath, isNull);
      expect(state.color, isNull);
      bool shouldShowRemoval = state.imagePath != null || state.color != null;
      expect(shouldShowRemoval, isFalse);

      // Set color - removal should be available
      state.setColor(0xFF42A5F5);
      shouldShowRemoval = state.imagePath != null || state.color != null;
      expect(shouldShowRemoval, isTrue);

      // Set image (clears color) - removal should still be available
      state.setImage('/path/to/image.jpg');
      shouldShowRemoval = state.imagePath != null || state.color != null;
      expect(shouldShowRemoval, isTrue);

      // Clear everything - removal should not be available
      state.imagePath = null;
      state.color = null;
      shouldShowRemoval = state.imagePath != null || state.color != null;
      expect(shouldShowRemoval, isFalse);
    });

    test('Edge case: Direct state manipulation consistency', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // Edge case: Manually set both (bypassing setter logic)
      state.imagePath = '/path/to/image.jpg';
      state.color = 0xFF42A5F5;

      // Both are set (this shouldn't happen in normal UI flow, but test the fix handles it)
      expect(state.imagePath, isNotNull);
      expect(state.color, isNotNull);

      // Remove background - should clear both regardless
      await controller.removeImage();

      expect(state.imagePath, isNull);
      expect(state.color, isNull);
    });
  });
}
