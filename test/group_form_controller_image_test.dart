import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:org_app_caravella/manager/group/group_form_controller.dart';
import 'package:org_app_caravella/manager/group/data/group_form_state.dart';
import 'package:org_app_caravella/manager/group/group_edit_mode.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp.createTempSync('controller_test').path;

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
      final source = File(p.join(tempDir.path, 'source.jpg'));
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

    test('removeImage deletes file and clears state', () async {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // create a temporary file to simulate existing saved image
      final tempDir = Directory.systemTemp.createTempSync('caravella_test');
      final saved = File(p.join(tempDir.path, 'saved.jpg'));
      await saved.writeAsString('fake-image-bytes');

      state.setImage(saved.path);
      expect(state.imagePath, isNotNull);

      await controller.removeImage();

      // file should be deleted and state cleared
      expect(state.imagePath, isNull);
      expect(await saved.exists(), isFalse);

      tempDir.deleteSync(recursive: true);
    });
  });
}
