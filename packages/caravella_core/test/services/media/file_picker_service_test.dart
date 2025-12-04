import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

/// Mock implementation for testing
class MockFilePickerService implements FilePickerService {
  String? mockImagePath;
  String? mockVideoPath;
  String? mockFilePath;
  bool shouldFail = false;

  @override
  Future<String?> pickImage({required ImageSource source}) async {
    if (shouldFail) return null;
    return mockImagePath;
  }

  @override
  Future<String?> pickVideo({required ImageSource source}) async {
    if (shouldFail) return null;
    return mockVideoPath;
  }

  @override
  Future<String?> pickFile({required List<String> extensions}) async {
    if (shouldFail) return null;
    return mockFilePath;
  }
}

void main() {
  group('FilePickerService', () {
    late MockFilePickerService service;

    setUp(() {
      service = MockFilePickerService();
    });

    test('pickImage returns path when successful', () async {
      service.mockImagePath = '/path/to/image.jpg';

      final result = await service.pickImage(source: ImageSource.camera);

      expect(result, '/path/to/image.jpg');
    });

    test('pickImage returns null when failed', () async {
      service.shouldFail = true;

      final result = await service.pickImage(source: ImageSource.gallery);

      expect(result, isNull);
    });

    test('pickVideo returns path when successful', () async {
      service.mockVideoPath = '/path/to/video.mp4';

      final result = await service.pickVideo(source: ImageSource.camera);

      expect(result, '/path/to/video.mp4');
    });

    test('pickVideo returns null when failed', () async {
      service.shouldFail = true;

      final result = await service.pickVideo(source: ImageSource.gallery);

      expect(result, isNull);
    });

    test('pickFile returns path when successful', () async {
      service.mockFilePath = '/path/to/document.pdf';

      final result = await service.pickFile(extensions: ['pdf', 'jpg']);

      expect(result, '/path/to/document.pdf');
    });

    test('pickFile returns null when failed', () async {
      service.shouldFail = true;

      final result = await service.pickFile(extensions: ['pdf']);

      expect(result, isNull);
    });

    test('ImageSource enum has expected values', () {
      expect(ImageSource.values, contains(ImageSource.camera));
      expect(ImageSource.values, contains(ImageSource.gallery));
      expect(ImageSource.values.length, 2);
    });
  });
}
