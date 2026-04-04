import 'package:image_picker/image_picker.dart' as picker;
import 'package:file_picker/file_picker.dart';
import 'package:caravella_core/caravella_core.dart';

/// Platform implementation of FilePickerService using image_picker and file_picker packages
class FilePickerServiceImpl implements FilePickerService {
  final picker.ImagePicker _imagePicker;

  FilePickerServiceImpl({picker.ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? picker.ImagePicker();

  @override
  Future<String?> pickImage({
    required ImageSource source,
    bool preferFrontCamera = false,
  }) async {
    try {
      final pickerSource = _toImagePickerSource(source);
      final file = await _imagePicker.pickImage(
        source: pickerSource,
        preferredCameraDevice: preferFrontCamera
            ? picker.CameraDevice.front
            : picker.CameraDevice.rear,
      );
      return file?.path;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> pickVideo({
    required ImageSource source,
    bool preferFrontCamera = false,
  }) async {
    try {
      final pickerSource = _toImagePickerSource(source);
      final file = await _imagePicker.pickVideo(
        source: pickerSource,
        preferredCameraDevice: preferFrontCamera
            ? picker.CameraDevice.front
            : picker.CameraDevice.rear,
      );
      return file?.path;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> pickFile({required List<String> extensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );
      return result?.files.single.path;
    } catch (e) {
      return null;
    }
  }

  picker.ImageSource _toImagePickerSource(ImageSource source) {
    switch (source) {
      case ImageSource.camera:
        return picker.ImageSource.camera;
      case ImageSource.gallery:
        return picker.ImageSource.gallery;
    }
  }
}
