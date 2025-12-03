import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:caravella_core/caravella_core.dart';

/// Platform implementation of ImageCompressionService using image package
class ImageCompressionServiceImpl implements ImageCompressionService {
  static final _compressibleExtensions = {'.jpg', '.jpeg', '.png'};

  @override
  Future<File> compressImage(
    File file, {
    int quality = 85,
    int maxDimension = 1920,
  }) async {
    try {
      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        // Cannot decode, return original
        return file;
      }

      // Resize if too large
      final resized = image.width > maxDimension || image.height > maxDimension
          ? img.copyResize(
              image,
              width: image.width > image.height ? maxDimension : null,
              height: image.height > image.width ? maxDimension : null,
            )
          : image;

      // Compress as JPEG
      final compressed = img.encodeJpg(resized, quality: quality);

      // Write back to original file
      await file.writeAsBytes(compressed);

      return file;
    } catch (e) {
      // If compression fails, return original file
      return file;
    }
  }

  @override
  bool isCompressibleImage(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return _compressibleExtensions.contains(extension);
  }
}
