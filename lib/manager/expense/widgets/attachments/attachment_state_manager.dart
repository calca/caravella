import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:caravella_core/caravella_core.dart';
import '../../services/file_picker_service_impl.dart';
import '../../services/image_compression_service_impl.dart';

/// Attachment source types
enum AttachmentSource { camera, gallery, files }

/// Camera media types
enum CameraMediaType { photo, video }

/// State manager for attachment operations
/// Handles file picking, compression, and storage using service abstractions
class AttachmentStateManager extends ChangeNotifier {
  final String groupId;
  final FilePickerService _filePickerService;
  final ImageCompressionService _compressionService;
  final List<String> _attachments = [];
  final int maxAttachments;

  AttachmentStateManager({
    required this.groupId,
    FilePickerService? filePickerService,
    ImageCompressionService? compressionService,
    this.maxAttachments = 5,
    List<String>? initialAttachments,
  }) : _filePickerService = filePickerService ?? FilePickerServiceImpl(),
       _compressionService =
           compressionService ?? ImageCompressionServiceImpl() {
    if (initialAttachments != null) {
      _attachments.addAll(initialAttachments);
    }
  }

  List<String> get attachments => List.unmodifiable(_attachments);

  bool get canAddMore => _attachments.length < maxAttachments;

  int get count => _attachments.length;

  /// Add attachment from the specified source
  Future<String?> addAttachment(
    AttachmentSource source, {
    CameraMediaType? cameraMediaType,
  }) async {
    if (!canAddMore) {
      return null;
    }

    String? filePath;

    try {
      switch (source) {
        case AttachmentSource.camera:
          if (cameraMediaType == CameraMediaType.photo) {
            filePath = await _filePickerService.pickImage(
              source: ImageSource.camera,
            );
          } else if (cameraMediaType == CameraMediaType.video) {
            filePath = await _filePickerService.pickVideo(
              source: ImageSource.camera,
            );
          }
          break;

        case AttachmentSource.gallery:
          filePath = await _filePickerService.pickImage(
            source: ImageSource.gallery,
          );
          break;

        case AttachmentSource.files:
          filePath = await _filePickerService.pickFile(
            extensions: ['jpg', 'jpeg', 'png', 'pdf', 'mp4', 'mov'],
          );
          break;
      }

      if (filePath != null) {
        final savedPath = await _saveAttachment(filePath);
        _attachments.add(savedPath);
        notifyListeners();
        return savedPath;
      }
    } catch (e) {
      // Error handling delegated to caller
      rethrow;
    }

    return null;
  }

  /// Remove attachment at the specified index
  void removeAttachment(int index) {
    if (index >= 0 && index < _attachments.length) {
      _attachments.removeAt(index);
      notifyListeners();
    }
  }

  /// Save attachment to app storage and compress if needed
  Future<String> _saveAttachment(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${directory.path}/attachments/$groupId');

    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(sourcePath)}';
    final targetPath = '${attachmentsDir.path}/$fileName';

    // Compress images if applicable
    if (_compressionService.isCompressibleImage(sourcePath)) {
      try {
        final sourceFile = File(sourcePath);
        final compressed = await _compressionService.compressImage(
          sourceFile,
          quality: 85,
          maxDimension: 1920,
        );

        // Copy compressed file to target location
        await compressed.copy(targetPath);
        return targetPath;
      } catch (e) {
        // If compression fails, fall back to simple copy
        await File(sourcePath).copy(targetPath);
        return targetPath;
      }
    }

    // For non-images (PDF, video), just copy
    await File(sourcePath).copy(targetPath);
    return targetPath;
  }

  /// Clear all attachments
  void clear() {
    _attachments.clear();
    notifyListeners();
  }
}
