import 'dart:io';

/// Service abstraction for image compression operations
/// Isolates image processing logic for better testability and reusability
abstract class ImageCompressionService {
  /// Compress an image file to reduce storage size
  ///
  /// [file] - The source image file to compress
  /// [quality] - JPEG compression quality (0-100, default 85)
  /// [maxDimension] - Maximum width/height in pixels (default 1920)
  ///
  /// Returns the compressed file (may be the same as input if compression fails)
  Future<File> compressImage(
    File file, {
    int quality = 85,
    int maxDimension = 1920,
  });

  /// Check if a file extension represents an image that can be compressed
  bool isCompressibleImage(String filePath);
}
