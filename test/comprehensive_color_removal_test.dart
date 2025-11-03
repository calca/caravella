import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';
import 'package:caravella_core/caravella_core.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('comprehensive_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  group('Comprehensive color removal tests', () {
    test('Color removal works and hasChanges detects the change', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);

      // Create original group with color
      const originalColor = 0xFFE57373;
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Group',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        currency: 'EUR',
        color: originalColor,
        file: null,
      );

      // Load the group
      controller.load(originalGroup);
      expect(state.color, equals(originalColor));
      expect(controller.hasChanges, isFalse, reason: 'No changes initially');

      // Remove the color
      await controller.removeImage();

      // Verify color is removed
      expect(state.color, isNull);
      expect(state.imagePath, isNull);

      // Verify hasChanges detects this as a change
      expect(
        controller.hasChanges,
        isTrue,
        reason: 'Removing color should be detected as a change',
      );

      // Verify the change would be persisted in save
      // (we can't actually call save in this test without full storage setup,
      // but we can verify the logic would work)
      expect(state.color != originalGroup.color, isTrue);
    });

    test('Color removal triggers proper state notifications', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // Track notifications
      var notificationCount = 0;
      state.addListener(() => notificationCount++);

      // Set color
      state.setColor(0xFF42A5F5);
      final notificationsAfterSet = notificationCount;
      expect(notificationsAfterSet, greaterThan(0));

      // Remove color
      await controller.removeImage();
      final notificationsAfterRemove = notificationCount;

      // Should have triggered additional notification due to refresh() call
      expect(
        notificationsAfterRemove,
        greaterThan(notificationsAfterSet),
        reason: 'removeImage should trigger state notification',
      );

      expect(state.color, isNull);
    });

    test(
      'Color removal works with simultaneous image and color state',
      () async {
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.create);

        // Edge case: manually set both (shouldn't happen in normal UI)
        state.color = 0xFF42A5F5;
        state.imagePath = '/test/path.jpg';

        // Both are set
        expect(state.color, isNotNull);
        expect(state.imagePath, isNotNull);

        // Remove background should clear both
        await controller.removeImage();

        expect(state.color, isNull);
        expect(state.imagePath, isNull);
      },
    );

    test('Multiple removeImage calls are safe', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // Set color
      state.setColor(0xFF42A5F5);
      expect(state.color, isNotNull);

      // Remove multiple times
      await controller.removeImage();
      expect(state.color, isNull);

      await controller.removeImage(); // Should be safe
      expect(state.color, isNull);

      await controller.removeImage(); // Should be safe
      expect(state.color, isNull);
    });

    test('Color removal works correctly in create vs edit mode', () async {
      // Test create mode
      final createState = GroupFormState();
      final createController = GroupFormController(
        createState,
        GroupEditMode.create,
      );

      createState.setColor(0xFF42A5F5);
      expect(createController.hasChanges, isTrue);

      await createController.removeImage();
      expect(createState.color, isNull);
      expect(
        createController.hasChanges,
        isFalse,
      ); // No changes in create mode after removal

      // Test edit mode
      final editState = GroupFormState();
      final editController = GroupFormController(editState, GroupEditMode.edit);

      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Group',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        currency: 'EUR',
        color: 0xFFE57373,
        file: null,
      );

      editController.load(originalGroup);
      expect(editController.hasChanges, isFalse);

      await editController.removeImage();
      expect(editState.color, isNull);
      expect(
        editController.hasChanges,
        isTrue,
      ); // Should detect change in edit mode
    });

    test('UI visibility logic for remove button works correctly', () {
      final state = GroupFormState();

      // Helper function mimicking UI logic
      bool shouldShowRemoveButton() {
        return state.imagePath != null || state.color != null;
      }

      // Initially no background
      expect(shouldShowRemoveButton(), isFalse);

      // Set color
      state.setColor(0xFF42A5F5);
      expect(shouldShowRemoveButton(), isTrue);

      // Set image (should clear color due to mutual exclusion)
      state.setImage('/path/test.jpg');
      expect(shouldShowRemoveButton(), isTrue);
      expect(state.color, isNull); // Verify mutual exclusion

      // Clear everything manually (simulating removeImage result)
      state.imagePath = null;
      state.color = null;
      expect(shouldShowRemoveButton(), isFalse);
    });
  });
}
