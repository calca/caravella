import 'dart:io';
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
      .createTempSync('background_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  group('Background removal issues - FIXED', () {
    test('FIXED: Color should be removed when removeImage is called with only color set', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // Set only a color (no image)
      const testColor = 0xFF42A5F5;
      state.setColor(testColor);
      
      expect(state.color, equals(testColor));
      expect(state.imagePath, isNull);

      // Remove background - should clear the color
      await controller.removeImage();

      // Verify color is removed (this was the main issue)
      expect(state.color, isNull, reason: 'Color should be null after removeImage()');
      expect(state.imagePath, isNull);
    });

    test('FIXED: Original color should not reappear when removing image in edit mode', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);

      // Create an original group with a color
      const originalColor = 0xFFE57373;
      final originalGroup = ExpenseGroup(
        id: 'test-group-id',
        title: 'Test Group',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        color: originalColor,
        file: null, // no image initially
      );

      // Load the original group
      controller.load(originalGroup);
      expect(state.color, equals(originalColor));
      expect(state.imagePath, isNull);

      // Simulate user setting an image (this should clear the color)
      final tempDir = Directory.systemTemp.createTempSync('caravella_test');
      final testImage = File('${tempDir.path}/test.jpg');
      await testImage.writeAsString('fake-image-data');
      
      await controller.persistPickedImage(testImage);
      expect(state.imagePath, isNotNull);
      expect(state.color, isNull, reason: 'Color should be cleared when image is set');

      // Now remove the image - the original color should NOT reappear
      await controller.removeImage();
      
      expect(state.imagePath, isNull);
      expect(state.color, isNull, reason: 'Original color should not reappear after image removal');

      // Cleanup
      if (await testImage.exists()) await testImage.delete();
      tempDir.deleteSync(recursive: true);
    });

    test('Background removal works correctly with both image and color scenarios', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // Test 1: Only color set
      const testColor = 0xFF42A5F5;
      state.setColor(testColor);
      expect(state.color, equals(testColor));
      expect(state.imagePath, isNull);

      await controller.removeImage();
      expect(state.color, isNull);
      expect(state.imagePath, isNull);

      // Test 2: Only image set
      final tempDir = Directory.systemTemp.createTempSync('caravella_test');
      final testImage = File('${tempDir.path}/test.jpg');
      await testImage.writeAsString('fake-image-data');
      
      await controller.persistPickedImage(testImage);
      expect(state.imagePath, isNotNull);
      expect(state.color, isNull);

      await controller.removeImage();
      expect(state.imagePath, isNull);
      expect(state.color, isNull);

      // Cleanup
      tempDir.deleteSync(recursive: true);
    });

    test('State consistency: mutual exclusion of image and color still works', () async {
      final state = GroupFormState();
      
      // Setting color should clear image
      state.setImage('/path/to/image.jpg');
      expect(state.imagePath, equals('/path/to/image.jpg'));
      
      state.setColor(0xFF42A5F5);
      expect(state.color, equals(0xFF42A5F5));
      expect(state.imagePath, isNull, reason: 'Setting color should clear image');
      
      // Setting image should clear color
      state.setImage('/path/to/another.jpg');
      expect(state.imagePath, equals('/path/to/another.jpg'));
      expect(state.color, isNull, reason: 'Setting image should clear color');
    });

    test('Direct state manipulation used in fix works correctly', () async {
      final state = GroupFormState();
      
      // Set both (though they're mutually exclusive, let's test the fix)
      state.setColor(0xFF42A5F5);
      state.setImage('/path/test.jpg'); // This clears color
      expect(state.color, isNull);
      expect(state.imagePath, equals('/path/test.jpg'));
      
      // Simulate the fix: direct field assignment
      state.imagePath = null;
      state.color = null;
      state.notifyListeners();
      
      expect(state.imagePath, isNull);
      expect(state.color, isNull);
    });
  });
}