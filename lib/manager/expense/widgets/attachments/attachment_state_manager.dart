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
  // Compression thresholds
  static const int _minFileSizeForCompression = 200 * 1024; // 200 KB
  static const int _maxFileSizeForCompression = 50 * 1024 * 1024; // 50 MB

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
      LoggerService.debug(
        'Cannot add attachment: canAddMore=$canAddMore, isProcessing=$isProcessing',
        name: 'attachment',
      );
      return null;
    }

    String? filePath;

    try {
      // Step 1: Pick file
      _updateProcessingState(AttachmentProcessingState.picking);
      LoggerService.debug(
        'Starting file picking from $source',
        name: 'attachment',
      );

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
        LoggerService.debug('File picked: $filePath', name: 'attachment');
        // Step 2: Save (and potentially compress)
        final savedPath = await _saveAttachment(filePath);
        _attachments.add(savedPath);
        _updateProcessingState(AttachmentProcessingState.idle);
        notifyListeners();
        LoggerService.info(
          'Attachment added successfully: $savedPath',
          name: 'attachment',
        );
        return savedPath;
      } else {
        LoggerService.debug('File picking cancelled', name: 'attachment');
        _updateProcessingState(AttachmentProcessingState.idle);
      }
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to add attachment from $source',
        name: 'attachment',
        error: e,
        stackTrace: stackTrace,
      );
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
    try {
      LoggerService.debug('Saving attachment: $sourcePath', name: 'attachment');

      final targetPath = await AttachmentsStorageService.getAttachmentPath(
        groupName,
        groupId,
        path.basename(sourcePath),
      );

      // Check if we need to compress
      if (_compressionService.isCompressibleImage(sourcePath)) {
        try {
          // Check file size before compression
          final sourceFile = File(sourcePath);
          final fileSizeInBytes = await sourceFile.length();
          final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

          LoggerService.debug(
            'Image file size: ${fileSizeInMB.toStringAsFixed(2)} MB',
            name: 'attachment',
          );

          // Skip compression for very small files (< 200KB) or very large files (> 50MB)
          if (fileSizeInBytes < _minFileSizeForCompression) {
            LoggerService.debug(
              'Skipping compression for small file',
              name: 'attachment',
            );
            _updateProcessingState(AttachmentProcessingState.saving);
            await sourceFile.copy(targetPath);
            LoggerService.info(
              'Small image saved without compression: $targetPath',
              name: 'attachment',
            );
            return targetPath;
          }

          if (fileSizeInBytes > _maxFileSizeForCompression) {
            LoggerService.warning(
              'Image file too large (${fileSizeInMB.toStringAsFixed(2)} MB), skipping compression',
              name: 'attachment',
            );
            _updateProcessingState(AttachmentProcessingState.saving);
            await sourceFile.copy(targetPath);
            LoggerService.info(
              'Large image saved without compression: $targetPath',
              name: 'attachment',
            );
            return targetPath;
          }

          // Step 3: Compress (runs in isolate, non-blocking)
          _updateProcessingState(AttachmentProcessingState.compressing);
          LoggerService.debug(
            'Compressing image: $sourcePath',
            name: 'attachment',
          );

          final compressed = await _compressionService.compressImage(
            sourceFile,
            quality: 85,
            maxDimension: 1920,
          );

          // Step 4: Copy to final location
          _updateProcessingState(AttachmentProcessingState.saving);
          LoggerService.debug(
            'Copying compressed image to: $targetPath',
            name: 'attachment',
          );
          await compressed.copy(targetPath);

          LoggerService.info(
            'Image compressed and saved: $targetPath',
            name: 'attachment',
          );
          return targetPath;
        } catch (e) {
          LoggerService.warning(
            'Compression failed, falling back to copy: $e',
            name: 'attachment',
          );
          // If compression fails, fall back to simple copy
          _updateProcessingState(AttachmentProcessingState.saving);
          await File(sourcePath).copy(targetPath);
          LoggerService.info(
            'Image saved without compression: $targetPath',
            name: 'attachment',
          );
          return targetPath;
        }
      }

      // For non-images (PDF, video), just copy
      _updateProcessingState(AttachmentProcessingState.saving);
      LoggerService.debug(
        'Copying non-image file to: $targetPath',
        name: 'attachment',
      );
      await File(sourcePath).copy(targetPath);
      LoggerService.info('File saved: $targetPath', name: 'attachment');
      return targetPath;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to save attachment',
        name: 'attachment',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
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
