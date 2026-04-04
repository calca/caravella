import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

/// Mock implementation for testing
class MockImageCompressionService implements ImageCompressionService {
  bool shouldFailCompression = false;
  int? lastQuality;
  int? lastMaxDimension;

  @override
  Future<File> compressImage(
    File file, {
    int quality = 85,
    int maxDimension = 1920,
  }) async {
    lastQuality = quality;
    lastMaxDimension = maxDimension;

    if (shouldFailCompression) {
      return file; // Return original on failure
    }

    // In real implementation, this would compress the image
    return file;
  }

  @override
  bool isCompressibleImage(String filePath) {
    final extension = filePath.toLowerCase();
    return extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png');
  }
}

void main() {
  group('ImageCompressionService', () {
    late MockImageCompressionService service;

    setUp(() {
      service = MockImageCompressionService();
    });

    test('compressImage accepts quality parameter', () async {
      final file = File('/path/to/test.jpg');

      await service.compressImage(file, quality: 90);

      expect(service.lastQuality, 90);
    });

    test('compressImage accepts maxDimension parameter', () async {
      final file = File('/path/to/test.jpg');

      await service.compressImage(file, maxDimension: 2048);

      expect(service.lastMaxDimension, 2048);
    });

    test('compressImage uses default quality when not specified', () async {
      final file = File('/path/to/test.jpg');

      await service.compressImage(file);

      expect(service.lastQuality, 85);
    });

    test(
      'compressImage uses default maxDimension when not specified',
      () async {
        final file = File('/path/to/test.jpg');

        await service.compressImage(file);

        expect(service.lastMaxDimension, 1920);
      },
    );

    test('compressImage returns file when successful', () async {
      final file = File('/path/to/test.jpg');

      final result = await service.compressImage(file);

      expect(result, isA<File>());
    });

    test('compressImage returns original file on failure', () async {
      final file = File('/path/to/test.jpg');
      service.shouldFailCompression = true;

      final result = await service.compressImage(file);

      expect(result, file);
    });

    test('isCompressibleImage returns true for JPEG files', () {
      expect(service.isCompressibleImage('/path/to/image.jpg'), isTrue);
      expect(service.isCompressibleImage('/path/to/image.jpeg'), isTrue);
      expect(service.isCompressibleImage('/path/to/IMAGE.JPG'), isTrue);
    });

    test('isCompressibleImage returns true for PNG files', () {
      expect(service.isCompressibleImage('/path/to/image.png'), isTrue);
      expect(service.isCompressibleImage('/path/to/IMAGE.PNG'), isTrue);
    });

    test('isCompressibleImage returns false for non-image files', () {
      expect(service.isCompressibleImage('/path/to/document.pdf'), isFalse);
      expect(service.isCompressibleImage('/path/to/video.mp4'), isFalse);
      expect(service.isCompressibleImage('/path/to/text.txt'), isFalse);
    });
  });
}
