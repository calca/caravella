import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:caravella_core/caravella_core.dart';
import '../../services/file_picker_service_impl.dart';
import '../../services/image_compression_service_impl.dart';

/// Attachment source types
enum AttachmentSource { camera, gallery, files }

/// Camera media types
enum CameraMediaType { photo, video }

/// Processing state for attachment operations
enum AttachmentProcessingState { idle, picking, compressing, saving }

/// State manager for attachment operations
/// Handles file picking, compression, and storage using service abstractions
/// Optimized version with progress tracking
class AttachmentStateManager extends ChangeNotifier {
  final String groupId;
  final String groupName;
  final FilePickerService _filePickerService;
  final ImageCompressionService _compressionService;
  final List<String> _attachments = [];
  final int maxAttachments;

  AttachmentProcessingState _processingState = AttachmentProcessingState.idle;

  AttachmentStateManager({
    required this.groupId,
    required this.groupName,
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
  AttachmentProcessingState get processingState => _processingState;
  bool get isProcessing => _processingState != AttachmentProcessingState.idle;

  /// Add attachment from the specified source with progress tracking
  Future<String?> addAttachment(
    AttachmentSource source, {
    CameraMediaType? cameraMediaType,
  }) async {
    if (!canAddMore || isProcessing) {
      return null;
    }

    String? filePath;

    try {
      // Step 1: Pick file
      _updateProcessingState(AttachmentProcessingState.picking);

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
        // Step 2: Save (and potentially compress)
        final savedPath = await _saveAttachment(filePath);
        _attachments.add(savedPath);
        _updateProcessingState(AttachmentProcessingState.idle);
        notifyListeners();
        return savedPath;
      } else {
        _updateProcessingState(AttachmentProcessingState.idle);
      }
    } catch (e) {
      _updateProcessingState(AttachmentProcessingState.idle);
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
  /// This now runs compression in a separate isolate (non-blocking)
  Future<String> _saveAttachment(String sourcePath) async {
    final targetPath = await AttachmentsStorageService.getAttachmentPath(
      groupName,
      path.basename(sourcePath),
    );

    // Check if we need to compress
    if (_compressionService.isCompressibleImage(sourcePath)) {
      try {
        // Step 3: Compress (runs in isolate, non-blocking)
        _updateProcessingState(AttachmentProcessingState.compressing);

        final sourceFile = File(sourcePath);
        final compressed = await _compressionService.compressImage(
          sourceFile,
          quality: 85,
          maxDimension: 1920,
        );

        // Step 4: Copy to final location
        _updateProcessingState(AttachmentProcessingState.saving);
        await compressed.copy(targetPath);

        return targetPath;
      } catch (e) {
        LoggerService.warning('Compression failed, falling back to copy: $e');
        // If compression fails, fall back to simple copy
        _updateProcessingState(AttachmentProcessingState.saving);
        await File(sourcePath).copy(targetPath);
        return targetPath;
      }
    }

    // For non-images (PDF, video), just copy
    _updateProcessingState(AttachmentProcessingState.saving);
    await File(sourcePath).copy(targetPath);
    return targetPath;
  }

  void _updateProcessingState(AttachmentProcessingState newState) {
    if (_processingState != newState) {
      _processingState = newState;
      notifyListeners();
    }
  }

  /// Clear all attachments
  void clear() {
    _attachments.clear();
    notifyListeners();
  }
}
