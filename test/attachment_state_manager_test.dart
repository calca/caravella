import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/expense/widgets/attachments/attachment_state_manager.dart';

/// Mock file picker service for testing
class MockFilePickerService implements FilePickerService {
  String? mockPickedPath;
  bool shouldFail = false;

  @override
  Future<String?> pickImage({required ImageSource source}) async {
    if (shouldFail) throw Exception('Pick failed');
    return mockPickedPath;
  }

  @override
  Future<String?> pickVideo({required ImageSource source}) async {
    if (shouldFail) throw Exception('Pick failed');
    return mockPickedPath;
  }

  @override
  Future<String?> pickFile({required List<String> extensions}) async {
    if (shouldFail) throw Exception('Pick failed');
    return mockPickedPath;
  }
}

/// Mock image compression service for testing
class MockImageCompressionService implements ImageCompressionService {
  @override
  Future<File> compressImage(
    File file, {
    int quality = 85,
    int maxDimension = 1920,
  }) async {
    return file; // Return as-is for testing
  }

  @override
  bool isCompressibleImage(String filePath) {
    return filePath.endsWith('.jpg') ||
        filePath.endsWith('.jpeg') ||
        filePath.endsWith('.png');
  }
}

void main() {
  group('AttachmentStateManager', () {
    late MockFilePickerService mockFilePicker;
    late MockImageCompressionService mockCompression;

    setUp(() {
      mockFilePicker = MockFilePickerService();
      mockCompression = MockImageCompressionService();
    });

    test('initializes with empty attachments', () {
      final manager = AttachmentStateManager(
        groupId: 'test-group',
        filePickerService: mockFilePicker,
        compressionService: mockCompression,
      );

      expect(manager.attachments, isEmpty);
      expect(manager.count, 0);
      expect(manager.canAddMore, isTrue);
    });

    test('initializes with provided attachments', () {
      final initialAttachments = ['/path/to/file1.jpg', '/path/to/file2.pdf'];
      final manager = AttachmentStateManager(
        groupId: 'test-group',
        filePickerService: mockFilePicker,
        compressionService: mockCompression,
        initialAttachments: initialAttachments,
      );

      expect(manager.attachments, equals(initialAttachments));
      expect(manager.count, 2);
      expect(manager.canAddMore, isTrue);
    });

    test('respects max attachments limit', () {
      final initialAttachments = List.generate(5, (i) => '/path/file$i.jpg');
      final manager = AttachmentStateManager(
        groupId: 'test-group',
        filePickerService: mockFilePicker,
        compressionService: mockCompression,
        initialAttachments: initialAttachments,
      );

      expect(manager.count, 5);
      expect(manager.canAddMore, isFalse);
    });

    test('removeAttachment removes at correct index', () {
      final manager = AttachmentStateManager(
        groupId: 'test-group',
        filePickerService: mockFilePicker,
        compressionService: mockCompression,
        initialAttachments: ['/file1.jpg', '/file2.jpg', '/file3.jpg'],
      );

      manager.removeAttachment(1);

      expect(manager.count, 2);
      expect(manager.attachments, ['/file1.jpg', '/file3.jpg']);
    });

    test('removeAttachment handles invalid index gracefully', () {
      final manager = AttachmentStateManager(
        groupId: 'test-group',
        filePickerService: mockFilePicker,
        compressionService: mockCompression,
        initialAttachments: ['/file1.jpg'],
      );

      manager.removeAttachment(5); // Invalid index

      expect(manager.count, 1);
      expect(manager.attachments, ['/file1.jpg']);
    });

    test('clear removes all attachments', () {
      final manager = AttachmentStateManager(
        groupId: 'test-group',
        filePickerService: mockFilePicker,
        compressionService: mockCompression,
        initialAttachments: ['/file1.jpg', '/file2.jpg'],
      );

      manager.clear();

      expect(manager.attachments, isEmpty);
      expect(manager.count, 0);
      expect(manager.canAddMore, isTrue);
    });

    test('notifies listeners on state changes', () {
      final manager = AttachmentStateManager(
        groupId: 'test-group',
        filePickerService: mockFilePicker,
        compressionService: mockCompression,
        initialAttachments: ['/file1.jpg'],
      );

      var notified = false;
      manager.addListener(() {
        notified = true;
      });

      manager.removeAttachment(0);

      expect(notified, isTrue);
    });

    test('attachments list is unmodifiable', () {
      final manager = AttachmentStateManager(
        groupId: 'test-group',
        filePickerService: mockFilePicker,
        compressionService: mockCompression,
        initialAttachments: ['/file1.jpg'],
      );

      expect(
        () => manager.attachments.add('/file2.jpg'),
        throwsUnsupportedError,
      );
    });
  });
}
