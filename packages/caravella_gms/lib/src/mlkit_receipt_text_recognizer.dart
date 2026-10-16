import 'package:caravella_core/caravella_core.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// [ReceiptTextRecognizer] backed by on-device ML Kit text recognition
/// (Latin script).
class MlKitReceiptTextRecognizer implements ReceiptTextRecognizer {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  Future<String> recognizeText(String imagePath) async {
    final recognizedText = await _textRecognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );
    return recognizedText.text;
  }

  @override
  Future<void> close() => _textRecognizer.close();
}
