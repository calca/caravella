import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';
import 'package:caravella_core/caravella_core.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('ui_color_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  setUpAll(() {
    // Force use of JSON backend for all tests
    ExpenseGroupRepositoryFactory.reset();
    ExpenseGroupRepositoryFactory.getRepository(useJsonBackend: true);
  });

  group('UI Color Removal Bug Investigation - FIXED', () {
    setUp(() {
      // Clear any cached data before each test
      ExpenseGroupStorageV2.clearCache();
    });

    test(
      'FIXED: ExpenseGroup.copyWith now handles explicit null colors correctly',
      () async {
        // Test the root cause: ExpenseGroup.copyWith with null color
        const originalColor = 0xFFE57373;
        final originalGroup = ExpenseGroup(
          id: 'test-copyWith',
          title: 'Test',
          participants: [ExpenseParticipant(name: 'Alice')],
          categories: [ExpenseCategory(name: 'Food')],
          expenses: [],
          currency: 'EUR',
          color: originalColor,
        );

        // This should now work correctly - explicit null should be preserved
        final groupWithNullColor = originalGroup.copyWith(color: null);

        expect(
          groupWithNullColor.color,
          isNull,
          reason: 'copyWith(color: null) should set color to null',
        );
        expect(
          originalGroup.color,
          equals(originalColor),
          reason: 'Original should be unchanged',
        );

        // Test that not providing color parameter preserves existing value
        final groupWithoutColorParam = originalGroup.copyWith(
          title: 'New Title',
        );
        expect(
          groupWithoutColorParam.color,
          equals(originalColor),
          reason:
              'Not providing color parameter should preserve existing color',
        );

        debugPrint('✓ ExpenseGroup.copyWith fix verified');
      },
    );

    test(
      'FIXED: Color removal now persists correctly on app restart',
      () async {
        // Step 1: Create a group with a background color
        const originalColor = 0xFFE57373; // Red color
        final originalGroup = ExpenseGroup(
          id: 'bug-test-group',
          title: 'Test Group with Color',
          participants: [ExpenseParticipant(name: 'Alice')],
          categories: [ExpenseCategory(name: 'Food')],
          expenses: [],
          currency: 'EUR',
          color: originalColor,
          file: null,
        );

        // Save the group to storage (simulates creating a group)
        await ExpenseGroupStorageV2.addExpenseGroup(originalGroup);

        // Verify it was saved correctly
        final savedGroup = await ExpenseGroupStorageV2.getTripById(
          'bug-test-group',
        );
        expect(savedGroup, isNotNull);
        expect(savedGroup!.color, equals(originalColor));

        // Step 2: Simulate user opening edit form and removing color
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);

        // Load the group (this simulates opening the edit page)
        controller.load(savedGroup);

        // Verify initial state matches saved data
        expect(state.color, equals(originalColor));
        expect(state.originalGroup?.color, equals(originalColor));

        // User removes the background color
        await controller.removeImage();

        // Verify state is updated in memory
        expect(
          state.color,
          isNull,
          reason: 'Color should be null after removal',
        );
        expect(controller.hasChanges, isTrue, reason: 'Should detect changes');

        // Step 3: Simulate user saving the changes
        final updatedGroup = await controller.save();

        // Verify the saved group has null color
        expect(
          updatedGroup.color,
          isNull,
          reason: 'Saved group should have null color',
        );

        // Step 4: Simulate app restart - load group from storage again
        ExpenseGroupStorageV2.forceReload(); // Force fresh read from storage
        final reloadedGroup = await ExpenseGroupStorageV2.getTripById(
          'bug-test-group',
        );

        // THIS SHOULD NOW WORK:
        // The reloaded group should have null color after the fix
        expect(reloadedGroup, isNotNull);
        expect(
          reloadedGroup!.color,
          isNull,
          reason: 'FIXED: Reloaded group now has null color after restart',
        );

        debugPrint('Original color: $originalColor');
        debugPrint('Color after removal: ${state.color}');
        debugPrint('Color in saved group: ${updatedGroup.color}');
        debugPrint('Color after app restart: ${reloadedGroup.color}');
        debugPrint('✓ Color removal persistence fix verified');
      },
    );

    test(
      'UI State Consistency: Verify state notifications work correctly',
      () async {
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.create);

        // Track state change notifications
        int notificationCount = 0;
        state.addListener(() {
          notificationCount++;
          debugPrint(
            'State notification #$notificationCount: color=${state.color}, image=${state.imagePath}',
          );
        });

        // Set a color
        const testColor = 0xFF42A5F5;
        state.setColor(testColor);
        expect(notificationCount, greaterThan(0));
        expect(state.color, equals(testColor));

        final notificationsBefore = notificationCount;

        // Remove background
        await controller.removeImage();

        // Verify notification was sent
        expect(
          notificationCount,
          greaterThan(notificationsBefore),
          reason: 'removeImage() should trigger state notification',
        );
        expect(state.color, isNull);
        expect(state.imagePath, isNull);

        debugPrint('✓ UI state notifications working correctly');
      },
    );

    test(
      'Storage Layer Verification: Ensure updateGroupMetadata works correctly',
      () async {
        // Create and save original group
        const originalColor = 0xFFE57373;
        final originalGroup = ExpenseGroup(
          id: 'storage-test-group',
          title: 'Storage Test',
          participants: [ExpenseParticipant(name: 'Bob')],
          categories: [ExpenseCategory(name: 'Transport')],
          expenses: [],
          currency: 'EUR',
          color: originalColor,
          file: null,
        );

        await ExpenseGroupStorageV2.addExpenseGroup(originalGroup);

        // Verify original was saved
        var loaded = await ExpenseGroupStorageV2.getTripById(
          'storage-test-group',
        );
        expect(loaded?.color, equals(originalColor));

        // Create updated version with null color using the fixed copyWith
        final updatedGroup = originalGroup.copyWith(color: null);

        // Verify the copyWith fix worked
        expect(
          updatedGroup.color,
          isNull,
          reason: 'copyWith(color: null) should work',
        );

        // Use the same method that GroupFormController.save() uses
        await ExpenseGroupStorageV2.updateGroupMetadata(updatedGroup);

        // Force reload and verify the update persisted
        ExpenseGroupStorageV2.forceReload();
        loaded = await ExpenseGroupStorageV2.getTripById('storage-test-group');

        expect(
          loaded?.color,
          isNull,
          reason: 'updateGroupMetadata should persist null color',
        );

        debugPrint('Original group color: ${originalGroup.color}');
        debugPrint('Updated group color: ${updatedGroup.color}');
        debugPrint('Reloaded group color: ${loaded?.color}');
        debugPrint('✓ Storage layer fix verified');
      },
    );

    test('Edge case: File removal also works correctly', () async {
      const originalColor = 0xFF42A5F5;
      final originalGroup = ExpenseGroup(
        id: 'file-test-group',
        title: 'File Test',
        participants: [ExpenseParticipant(name: 'Charlie')],
        categories: [ExpenseCategory(name: 'Lodging')],
        expenses: [],
        currency: 'EUR',
        color: originalColor,
        file: '/path/to/image.jpg',
      );

      // Test that both file and color can be set to null
      final updatedGroup = originalGroup.copyWith(file: null, color: null);

      expect(updatedGroup.file, isNull);
      expect(updatedGroup.color, isNull);
      expect(originalGroup.file, equals('/path/to/image.jpg'));
      expect(originalGroup.color, equals(originalColor));

      debugPrint('✓ File and color removal both work correctly');
    });
  });
}
