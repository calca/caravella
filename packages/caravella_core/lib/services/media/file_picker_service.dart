/// Service abstraction for file picking operations
/// Isolates platform dependencies (image_picker, file_picker) for better testability
abstract class FilePickerService {
  /// Pick an image from the specified source (camera or gallery)
  /// Returns the file path if successful, null if cancelled or failed
  Future<String?> pickImage({required ImageSource source});

  /// Pick a video from the specified source (camera or gallery)
  /// Returns the file path if successful, null if cancelled or failed
  Future<String?> pickVideo({required ImageSource source});

  /// Pick any file with the specified extensions
  /// Returns the file path if successful, null if cancelled or failed
  Future<String?> pickFile({required List<String> extensions});
}

/// Source for picking images/videos
enum ImageSource { camera, gallery }
