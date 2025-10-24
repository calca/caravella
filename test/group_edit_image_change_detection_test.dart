import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';

void main() {
  group('Group Edit Image Change Detection Tests', () {
    test('hasChanges detects image path change in edit mode', () {
      // Create a state and controller
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit, null);

      // Create an original group with no image
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        file: null, // No image initially
        color: null,
      );

      // Load the group into the controller
      controller.load(originalGroup);

      // Initially no changes
      expect(controller.hasChanges, false, reason: 'No changes initially');

      // Change the image path
      state.setImage('/path/to/new/image.jpg');

      // Should detect the change
      expect(
        controller.hasChanges,
        true,
        reason: 'Should detect image path change',
      );
    });

    test('hasChanges detects image removal in edit mode', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit, null);

      // Create an original group WITH an image
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        file: '/path/to/existing/image.jpg',
        color: null,
      );

      controller.load(originalGroup);

      // Initially no changes
      expect(controller.hasChanges, false, reason: 'No changes initially');

      // Remove the image
      state.setImage(null);

      // Should detect the change
      expect(
        controller.hasChanges,
        true,
        reason: 'Should detect image removal',
      );
    });

    test('hasChanges detects color change in edit mode', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit, null);

      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        file: null,
        color: 0xFFFF0000, // Red
      );

      controller.load(originalGroup);

      // Initially no changes
      expect(controller.hasChanges, false, reason: 'No changes initially');

      // Change the color
      state.setColor(0xFF0000FF); // Blue

      // Should detect the change
      expect(
        controller.hasChanges,
        true,
        reason: 'Should detect color change',
      );
    });

    test('hasChanges detects switching from color to image', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit, null);

      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        file: null,
        color: 0xFFFF0000, // Red
      );

      controller.load(originalGroup);

      // Change from color to image
      state.setImage('/path/to/new/image.jpg');

      // Should detect the change
      expect(
        controller.hasChanges,
        true,
        reason: 'Should detect change from color to image',
      );
    });

    test('hasChanges detects switching from image to color', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit, null);

      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        file: '/path/to/existing/image.jpg',
        color: null,
      );

      controller.load(originalGroup);

      // Change from image to color
      state.setColor(0xFFFF0000); // Red

      // Should detect the change
      expect(
        controller.hasChanges,
        true,
        reason: 'Should detect change from image to color',
      );
    });

    test('setImage clears color when image is set', () {
      final state = GroupFormState();

      // Set a color first
      state.setColor(0xFFFF0000);
      expect(state.color, 0xFFFF0000);
      expect(state.imagePath, null);

      // Set an image
      state.setImage('/path/to/image.jpg');

      // Color should be cleared
      expect(state.imagePath, '/path/to/image.jpg');
      expect(state.color, null, reason: 'Color should be cleared when image is set');
    });

    test('setColor clears image when color is set', () {
      final state = GroupFormState();

      // Set an image first
      state.setImage('/path/to/image.jpg');
      expect(state.imagePath, '/path/to/image.jpg');
      expect(state.color, null);

      // Set a color
      state.setColor(0xFFFF0000);

      // Image should be cleared
      expect(state.color, 0xFFFF0000);
      expect(state.imagePath, null, reason: 'Image should be cleared when color is set');
    });
  });
}
