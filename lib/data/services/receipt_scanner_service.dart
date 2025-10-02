import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Service for scanning receipts using on-device OCR
class ReceiptScannerService {
  static final ReceiptScannerService _instance = ReceiptScannerService._internal();
  factory ReceiptScannerService() => _instance;
  ReceiptScannerService._internal();

  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Scans a receipt image and extracts amount and description
  /// Returns a map with 'amount' (double?) and 'description' (String?)
  Future<Map<String, dynamic>> scanReceipt(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isEmpty) {
        return {'amount': null, 'description': null};
      }

      // Extract amount and description from recognized text
      final result = _parseReceiptText(recognizedText.text);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Parse receipt text to extract amount and description
  Map<String, dynamic> _parseReceiptText(String text) {
    double? amount;
    String? description;

    // Split text into lines for processing
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

    // Try to find amount - look for patterns like:
    // - "TOTALE 12.50" or "TOTAL 12,50"
    // - "€ 12.50" or "EUR 12,50"
    // - Numbers with currency symbols or keywords
    final amountPatterns = [
      RegExp(r'(?:totale|total|subtotal|tot\.?|somma)\s*[:=]?\s*€?\s*([0-9]+[.,][0-9]{2})', caseSensitive: false),
      RegExp(r'€\s*([0-9]+[.,][0-9]{2})'),
      RegExp(r'([0-9]+[.,][0-9]{2})\s*€'),
      RegExp(r'([0-9]+[.,][0-9]{2})\s*eur', caseSensitive: false),
      RegExp(r'\b([0-9]+[.,][0-9]{2})\b'),
    ];

    // Search for amount in lines
    for (final line in lines) {
      for (final pattern in amountPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null && match.groupCount > 0) {
          final amountStr = match.group(1)!.replaceAll(',', '.');
          final parsedAmount = double.tryParse(amountStr);
          if (parsedAmount != null && parsedAmount > 0) {
            amount = parsedAmount;
            break;
          }
        }
      }
      if (amount != null) break;
    }

    // Try to extract description from the first few lines
    // Usually merchant name or item description is at the top
    if (lines.isNotEmpty) {
      // Take first non-empty line that doesn't look like a date or address
      for (final line in lines.take(5)) {
        // Skip lines that are mostly numbers or dates
        if (line.length > 3 && 
            !RegExp(r'^\d{1,2}[/-]\d{1,2}[/-]\d{2,4}').hasMatch(line) &&
            !RegExp(r'^\d+$').hasMatch(line)) {
          description = line;
          break;
        }
      }
    }

    return {
      'amount': amount,
      'description': description,
    };
  }

  /// Dispose of resources
  void dispose() {
    _textRecognizer.close();
  }
}
