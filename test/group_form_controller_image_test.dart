import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('controller_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Provide a fake implementation for path_provider used in controller
  PathProviderPlatform.instance = _FakePathProvider();

  group('GroupFormController image handling', () {
    test('persistPickedImage copies file and sets state.imagePath', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // create a temporary file to act as picked image
      final tempDir = Directory.systemTemp.createTempSync('caravella_test');
      final source = File('${tempDir.path}/source.jpg');
      await source.writeAsString('fake-image-bytes');

      final result = await controller.persistPickedImage(source);

      expect(result, isNotNull);
      expect(state.imagePath, isNotNull);

      final saved = File(state.imagePath!);
      expect(await saved.exists(), isTrue);

      // cleanup
      await saved.delete();
      tempDir.deleteSync(recursive: true);
    });

    test('removeImage deletes file and clears state completely', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // create a temporary file to simulate existing saved image
      final tempDir = Directory.systemTemp.createTempSync('caravella_test');
      final saved = File('${tempDir.path}/saved.jpg');
      await saved.writeAsString('fake-image-bytes');

      state.setImage(saved.path);
      expect(state.imagePath, isNotNull);

      await controller.removeImage();

      // file should be deleted and state cleared
      expect(state.imagePath, isNull);
      expect(await saved.exists(), isFalse);

      tempDir.deleteSync(recursive: true);
    });

    test('removeImage clears color when only color is set', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // Set only a color (no image)
      const testColor = 0xFF42A5F5;
      state.setColor(testColor);
      expect(state.color, equals(testColor));
      expect(state.imagePath, isNull);

      // Remove background - should clear the color
      await controller.removeImage();

      // Verify both image and color are cleared
      expect(state.imagePath, isNull);
      expect(state.color, isNull);
    });

    test('removeImage clears both image and color completely', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // Set a color first
      state.setColor(0xFF42A5F5);
      expect(state.color, isNotNull);

      // Create and set an image (this should clear the color)
      final tempDir = Directory.systemTemp.createTempSync('caravella_test');
      final source = File('${tempDir.path}/saved.jpg');
      await source.writeAsString('fake-image-bytes');

      final copiedPath = await controller.persistPickedImage(source);
      expect(state.imagePath, isNotNull);
      expect(state.color, isNull, reason: 'Setting image should clear color');

      // Now remove everything
      await controller.removeImage();

      // Both should be cleared and the copied file should be deleted
      expect(state.imagePath, isNull);
      expect(state.color, isNull);
      if (copiedPath != null) {
        expect(await File(copiedPath).exists(), isFalse);
      }

      tempDir.deleteSync(recursive: true);
    });
  });
}
