import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:caravella_core/caravella_core.dart';

/// Platform implementation of [ReceiptScannerService] using Google ML Kit
/// text recognition to extract text from receipt images via on-device OCR.
class ReceiptScannerServiceImpl implements ReceiptScannerService {
  TextRecognizer? _recognizer;

  /// Returns the recognizer, creating it lazily on first use.
  TextRecognizer get _textRecognizer =>
      _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

  /// Extracts text from the image at [imagePath] using on-device Latin-script
  /// OCR provided by Google ML Kit. Returns null if the image contains no
  /// recognizable text or if an error occurs during processing.
  @override
  Future<String?> scanReceiptText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      LoggerService.info(
        'Receipt scan completed: ${recognizedText.blocks.length} block(s) found',
        name: 'receipt_scanner',
      );
      return recognizedText.text.isEmpty ? null : recognizedText.text;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Receipt scan failed',
        name: 'receipt_scanner',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  void dispose() {
    _recognizer?.close();
    _recognizer = null;
  }
}
