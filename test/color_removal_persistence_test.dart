import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('persistence_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  group('Color removal persistence issue reproduction', () {
    test('CRITICAL: Verify color removal is included in save data', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);

      // Create original group with a red background color
      const originalColor = 0xFFE57373;
      final originalGroup = ExpenseGroup(
        id: 'persistence-test-id',
        title: 'Test Trip',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        currency: 'EUR',
        color: originalColor,
        file: null,
      );

      // Load the group (simulates opening edit form)
      controller.load(originalGroup);

      // Verify initial state
      expect(state.color, equals(originalColor));
      expect(state.originalGroup?.color, equals(originalColor));
      expect(controller.hasChanges, isFalse);

      // User removes the background color
      await controller.removeImage();

      // Verify the color is removed from state
      expect(state.color, isNull, reason: 'Color should be null after removal');
      expect(
        controller.hasChanges,
        isTrue,
        reason: 'Should detect color removal as change',
      );

      // Simulate what happens during save - create the updated group
      final now = DateTime.now();
      final updatedGroup = (state.originalGroup ?? ExpenseGroup.empty())
          .copyWith(
            id: state.id,
            title: state.title.trim(),
            participants: state.participants.map((e) => e.copyWith()).toList(),
            categories: state.categories.map((e) => e.copyWith()).toList(),
            startDate: state.startDate,
            endDate: state.endDate,
            currency:
                state.currency['symbol'] ?? state.currency['code'] ?? 'EUR',
            file: state.imagePath,
            color: state.color, // This is the critical line - should be null
            timestamp: state.originalGroup?.timestamp ?? now,
          );

      // Verify the group to be saved has null color
      expect(
        updatedGroup.color,
        isNull,
        reason: 'Updated group should have null color to persist the removal',
      );

      // Verify this is different from the original
      expect(
        updatedGroup.color != originalGroup.color,
        isTrue,
        reason: 'Updated group should be different from original',
      );

      debugPrint('Original group color: ${originalGroup.color}');
      debugPrint('Updated group color: ${updatedGroup.color}');
      debugPrint('State color after removal: ${state.color}');
      debugPrint('Has changes: ${controller.hasChanges}');
    });

    test(
      'EDGE CASE: Verify color removal persists after multiple operations',
      () async {
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);

        const originalColor = 0xFFE57373;
        final originalGroup = ExpenseGroup(
          id: 'edge-case-test',
          title: 'Edge Case Trip',
          participants: [ExpenseParticipant(name: 'Bob')],
          categories: [ExpenseCategory(name: 'Transport')],
          expenses: [],
          currency: 'EUR',
          color: originalColor,
          file: null,
        );

        controller.load(originalGroup);
        expect(state.color, equals(originalColor));

        // User sets an image (should clear color due to mutual exclusion)
        state.setImage('/fake/path/image.jpg');
        expect(state.color, isNull);
        expect(state.imagePath, equals('/fake/path/image.jpg'));

        // User then removes the background entirely
        await controller.removeImage();
        expect(state.color, isNull);
        expect(state.imagePath, isNull);

        // Verify hasChanges still detects this as different from original
        expect(controller.hasChanges, isTrue);

        // Create save data
        final updatedGroup = originalGroup.copyWith(
          color: state.color,
          file: state.imagePath,
        );

        expect(updatedGroup.color, isNull);
        expect(updatedGroup.file, isNull);
        expect(updatedGroup.color != originalGroup.color, isTrue);
      },
    );

    test(
      'STATE CONSISTENCY: Verify state remains consistent through UI operations',
      () async {
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.create);

        // Track state changes
        final List<String> stateChanges = [];
        state.addListener(() {
          stateChanges.add(
            'color: ${state.color}, imagePath: ${state.imagePath}',
          );
        });

        // Set color
        state.setColor(0xFF42A5F5);
        expect(
          stateChanges.last,
          contains('color: 1109735157'),
        ); // 0xFF42A5F5 as int

        // Remove background
        await controller.removeImage();
        expect(stateChanges.last, contains('color: null, imagePath: null'));

        // Verify final state
        expect(state.color, isNull);
        expect(state.imagePath, isNull);

        debugPrint('State change history: ${stateChanges.join(' -> ')}');
      },
    );

    test(
      'REGRESSION: Ensure original color does not reappear after removal',
      () async {
        final state = GroupFormState();
        final controller = GroupFormController(state, GroupEditMode.edit);

        const originalColor = 0xFFE57373;
        final originalGroup = ExpenseGroup(
          id: 'regression-test',
          title: 'Regression Test',
          participants: [ExpenseParticipant(name: 'Charlie')],
          categories: [ExpenseCategory(name: 'Lodging')],
          expenses: [],
          currency: 'EUR',
          color: originalColor,
          file: null,
        );

        // Load group
        controller.load(originalGroup);
        expect(state.color, equals(originalColor));

        // Remove color
        await controller.removeImage();
        expect(state.color, isNull);

        // Simulate any potential state refresh or reload
        state.refresh();
        expect(
          state.color,
          isNull,
          reason: 'Color should remain null after refresh',
        );

        // Verify originalGroup is not modified
        expect(state.originalGroup?.color, equals(originalColor));
        expect(state.color != state.originalGroup?.color, isTrue);
      },
    );
  });
}
