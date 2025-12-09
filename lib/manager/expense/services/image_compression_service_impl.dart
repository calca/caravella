import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:caravella_core/caravella_core.dart';

/// Platform implementation of ImageCompressionService using image package
/// Optimized version that uses isolate for CPU-intensive operations
class ImageCompressionServiceImpl implements ImageCompressionService {
  static final _compressibleExtensions = {'.jpg', '.jpeg', '.png'};

  @override
  Future<File> compressImage(
    File file, {
    int quality = 85,
    int maxDimension = 1920,
  }) async {
    try {
      // Run compression in a separate isolate to avoid blocking UI
      final result = await compute(
        _compressImageIsolate,
        _CompressionParams(
          filePath: file.path,
          quality: quality,
          maxDimension: maxDimension,
        ),
      );

      if (result.success && result.compressedPath != null) {
        return File(result.compressedPath!);
      }

      // If compression fails, return original
      return file;
    } catch (e) {
      LoggerService.warning('Image compression failed: $e');
      // If compression fails, return original file
      return file;
    }
  }

  @override
  bool isCompressibleImage(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return _compressibleExtensions.contains(extension);
  }

  /// Static function that runs in isolate
  /// Must be top-level or static to work with compute()
  static Future<_CompressionResult> _compressImageIsolate(
    _CompressionParams params,
  ) async {
    try {
      final file = File(params.filePath);
      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        return _CompressionResult(success: false);
      }

      // Resize if too large
      final resized =
          image.width > params.maxDimension ||
              image.height > params.maxDimension
          ? img.copyResize(
              image,
              width: image.width > image.height ? params.maxDimension : null,
              height: image.height > image.width ? params.maxDimension : null,
            )
          : image;

      // Compress as JPEG
      final compressed = img.encodeJpg(resized, quality: params.quality);

      // Write back to original file
      await file.writeAsBytes(compressed);

      return _CompressionResult(success: true, compressedPath: params.filePath);
    } catch (e) {
      return _CompressionResult(success: false, error: e.toString());
    }
  }
}

/// Parameters for compression isolate
class _CompressionParams {
  final String filePath;
  final int quality;
  final int maxDimension;

  _CompressionParams({
    required this.filePath,
    required this.quality,
    required this.maxDimension,
  });
}

/// Result from compression isolate
class _CompressionResult {
  final bool success;
  final String? compressedPath;
  final String? error;

  _CompressionResult({required this.success, this.compressedPath, this.error});
}
