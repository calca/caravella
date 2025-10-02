import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';

/// Service to handle voice input and speech recognition
class VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  /// Check if voice recognition is available
  Future<bool> isAvailable() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
      );
    }
    return _isInitialized;
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Start listening for voice input
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final available = await isAvailable();
      if (!available) {
        onError('Voice recognition not available');
        return;
      }
    }

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          _isListening = false;
        }
      },
      localeId: localeId,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: false,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  /// Cancel listening
  Future<void> cancel() async {
    _isListening = false;
    await _speech.cancel();
  }

  /// Get list of available locales for speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await isAvailable();
    }
    return _speech.locales();
  }

  /// Parse voice text to extract expense information
  /// Returns a map with keys: amount, name, category
  static Map<String, dynamic> parseExpenseFromText(String text) {
    final result = <String, dynamic>{};

    // Normalize text
    final normalizedText = text.toLowerCase().trim();

    // Extract amount (look for numbers with currency symbols or keywords)
    // Patterns: "50 euro", "€50", "$50", "50 dollars", "50.50 euros"
    final amountPattern = RegExp(
      r'(\d+(?:[.,]\d{1,2})?)\s*(?:euro|eur|€|dollar|usd|\$|pound|£)?',
      caseSensitive: false,
    );
    final amountMatch = amountPattern.firstMatch(normalizedText);
    if (amountMatch != null) {
      final amountStr = amountMatch.group(1)?.replaceAll(',', '.');
      result['amount'] = double.tryParse(amountStr ?? '0.0');
    }

    // Extract description - try to find "per/for" keywords
    // Patterns: "per cena", "for dinner", "di benzina", "of gas"
    final descPatternIt = RegExp(
      r'(?:per|di|a)\s+(.+?)(?:\s+al|\s+alla|\s+in|\s+da|$)',
      caseSensitive: false,
    );
    final descPatternEn = RegExp(
      r'(?:for|of|at)\s+(.+?)(?:\s+at|\s+in|\s+from|$)',
      caseSensitive: false,
    );

    var descMatch = descPatternIt.firstMatch(normalizedText);
    if (descMatch == null) {
      descMatch = descPatternEn.firstMatch(normalizedText);
    }

    if (descMatch != null) {
      var description = descMatch.group(1)?.trim();
      // Clean up the description by removing currency amounts
      description = description
          ?.replaceAll(amountPattern, '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
      if (description != null && description.isNotEmpty) {
        result['name'] = description;
      }
    }

    // If no description found with patterns, use entire text without amount
    if (!result.containsKey('name')) {
      var description = normalizedText
          .replaceAll(amountPattern, '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
      // Remove common prepositions at the start
      description = description
          .replaceAll(RegExp(r'^(per|for|di|of|a|at)\s+'), '')
          .trim();
      if (description.isNotEmpty) {
        result['name'] = description;
      }
    }

    // Try to detect common categories
    final categoryKeywords = {
      'food': ['cena', 'pranzo', 'colazione', 'ristorante', 'dinner', 'lunch', 'breakfast', 'restaurant', 'cibo', 'food'],
      'transport': ['benzina', 'gas', 'taxi', 'treno', 'train', 'autobus', 'bus', 'metro', 'aereo', 'flight'],
      'accommodation': ['hotel', 'albergo', 'airbnb', 'ostello', 'hostel', 'affitto', 'rent'],
      'entertainment': ['cinema', 'teatro', 'theater', 'museum', 'museo', 'concerto', 'concert'],
      'shopping': ['shopping', 'acquisti', 'negozio', 'shop', 'store'],
    };

    for (final entry in categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (normalizedText.contains(keyword)) {
          result['category'] = entry.key;
          break;
        }
      }
      if (result.containsKey('category')) break;
    }

    return result;
  }
}
