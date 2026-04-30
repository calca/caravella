/// Service abstraction for receipt scanning operations using OCR
/// Isolates platform dependencies (google_mlkit_text_recognition) for better testability
abstract class ReceiptScannerService {
  /// Scan a receipt image and extract all recognized text
  ///
  /// [imagePath] - The absolute path to the image file to scan
  ///
  /// Returns the full extracted text, or null if scanning fails or is unsupported
  Future<String?> scanReceiptText(String imagePath);

  /// Release underlying OCR resources
  void dispose();
}
