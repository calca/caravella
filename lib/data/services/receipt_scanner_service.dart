import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:caravella_core/caravella_core.dart';

/// Platform implementation of [ReceiptScannerService] using Google ML Kit
/// text recognition to extract text from receipt images via on-device OCR.
class ReceiptScannerServiceImpl implements ReceiptScannerService {
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  Future<String?> scanReceiptText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _recognizer.processImage(inputImage);
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
    _recognizer.close();
  }
}
