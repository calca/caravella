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

  /// Parse voice text to extract expense information.
  ///
  /// Returns a map with keys:
  ///   - `amount`    (double?)  – monetary value
  ///   - `name`      (String?)  – expense description
  ///   - `category`  (String?)  – detected category keyword
  ///   - `paidBy`    (String?)  – participant name (if detectable)
  ///   - `date`      (DateTime?) – date parsed from relative expressions
  ///
  /// Pass [participantNames] to enable participant-name matching.
  static Map<String, dynamic> parseExpenseFromText(
    String text, {
    List<String> participantNames = const [],
  }) {
    final result = <String, dynamic>{};
    if (text.trim().isEmpty) return result;

    final normalizedText = text.toLowerCase().trim();

    // ── 1. AMOUNT ────────────────────────────────────────────────────────────
    // Matches: "50", "25.50", "35,75", "€50", "$50", "50 euro", "50 dollars", etc.
    final amountPattern = RegExp(
      r'(\d+(?:[.,]\d{1,2})?)\s*(?:euro|eur|€|dollar|dollaro|dollari|usd|\$|pound|£|reais|yuan|元|¥)?',
      caseSensitive: false,
    );
    final amountMatch = amountPattern.firstMatch(normalizedText);
    if (amountMatch != null) {
      final amountStr = amountMatch.group(1)?.replaceAll(',', '.');
      final parsed = double.tryParse(amountStr ?? '');
      if (parsed != null && parsed > 0) {
        result['amount'] = parsed;
      }
    }

    // ── 2. DATE ───────────────────────────────────────────────────────────────
    // Recognises relative expressions in IT + EN.
    final now = DateTime.now();
    DateTime? parsedDate;

    // "ieri" / "yesterday"
    if (_containsAny(normalizedText, ['ieri', 'yesterday'])) {
      parsedDate = now.subtract(const Duration(days: 1));
    }
    // "l'altro ieri" / "day before yesterday"
    else if (_containsAny(normalizedText, [
      "l'altro ieri",
      'altroieri',
      'day before yesterday',
    ])) {
      parsedDate = now.subtract(const Duration(days: 2));
    }
    // "settimana scorsa" / "last week"
    else if (_containsAny(normalizedText, [
      'settimana scorsa',
      'la settimana scorsa',
      'last week',
    ])) {
      parsedDate = now.subtract(const Duration(days: 7));
    }
    // "mese scorso" / "last month"
    else if (_containsAny(normalizedText, [
      'mese scorso',
      'il mese scorso',
      'last month',
    ])) {
      parsedDate = DateTime(now.year, now.month - 1, now.day);
    }
    // Specific day names (Monday-Sunday in IT + EN) → most recent past occurrence
    else {
      final dayNamesIt = [
        'lunedì', 'martedì', 'mercoledì', 'giovedì',
        'venerdì', 'sabato', 'domenica',
      ];
      final dayNamesEn = [
        'monday', 'tuesday', 'wednesday', 'thursday',
        'friday', 'saturday', 'sunday',
      ];
      for (int i = 0; i < dayNamesIt.length; i++) {
        if (normalizedText.contains(dayNamesIt[i]) ||
            normalizedText.contains(dayNamesEn[i])) {
          // ISO weekday: Mon=1 … Sun=7
          final targetWeekday = i + 1;
          int diff = now.weekday - targetWeekday;
          if (diff <= 0) diff += 7; // always go to the past
          parsedDate = now.subtract(Duration(days: diff));
          break;
        }
      }
    }

    if (parsedDate != null) {
      result['date'] = parsedDate;
    }

    // ── 3. PAID-BY (participant name) ────────────────────────────────────────
    // First try structured keywords: "pagato da Mario" / "paid by Mario"
    final paidByPattern = RegExp(
      r'(?:pagato\s+da|pago\s+da|pagata\s+da|paid\s+by|by)\s+([a-z][a-z\s]+?)(?:\s+per|\s+for|\s*$)',
      caseSensitive: false,
    );
    final paidByMatch = paidByPattern.firstMatch(normalizedText);
    if (paidByMatch != null) {
      final name = _capitalise(paidByMatch.group(1)?.trim() ?? '');
      if (name.isNotEmpty) {
        result['paidBy'] = name;
      }
    }

    // If not yet found, try to match known participant names anywhere in text
    if (!result.containsKey('paidBy') && participantNames.isNotEmpty) {
      for (final participantName in participantNames) {
        if (normalizedText.contains(participantName.toLowerCase())) {
          result['paidBy'] = participantName;
          break;
        }
      }
    }

    // ── 4. CATEGORY ──────────────────────────────────────────────────────────
    final categoryKeywords = <String, List<String>>{
      'food': [
        'cena', 'pranzo', 'colazione', 'ristorante', 'pizzeria', 'bar',
        'caffè', 'caffe', 'aperitivo', 'sushi', 'cibo', 'mangiare',
        'dinner', 'lunch', 'breakfast', 'restaurant', 'food', 'groceries',
        'supermercato', 'supermarket', 'pizza', 'gelato', 'fast food',
      ],
      'transport': [
        'benzina', 'carburante', 'gasolio', 'taxi', 'uber', 'treno',
        'autobus', 'bus', 'metro', 'metropolitana', 'aereo', 'volo',
        'parcheggio', 'autostrada', 'pedaggio', 'noleggio auto',
        'gas', 'fuel', 'train', 'flight', 'parking', 'toll', 'car rental',
        'ride', 'ferry', 'traghetto', 'biglietto',
      ],
      'accommodation': [
        'hotel', 'albergo', 'airbnb', 'ostello', 'hostel', 'affitto',
        'appartamento', 'b&b', 'bed and breakfast', 'rent', 'alloggio',
        'camping', 'tenda',
      ],
      'entertainment': [
        'cinema', 'teatro', 'theater', 'museo', 'museum', 'concerto',
        'concert', 'spettacolo', 'show', 'biglietto', 'ticket',
        'parco divertimenti', 'amusement park', 'zoo', 'discoteca', 'club',
        'sport', 'palestra', 'gym', 'piscina', 'swimming pool',
      ],
      'shopping': [
        'shopping', 'acquisti', 'negozio', 'shop', 'store', 'vestiti',
        'abbigliamento', 'clothes', 'scarpe', 'shoes', 'farmacia',
        'pharmacy', 'elettronica', 'electronics', 'libri', 'books',
        'regalo', 'gift', 'souvenir',
      ],
      'health': [
        'medico', 'dottore', 'doctor', 'farmacia', 'pharmacy',
        'medicine', 'medicina', 'ospedale', 'hospital', 'dentista',
        'dentist', 'visita', 'analisi',
      ],
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

    // ── 5. DESCRIPTION (name) ────────────────────────────────────────────────
    // Build a cleaned-up version of the text that strips the parts already
    // consumed (amount tokens, date tokens, paid-by tokens).
    String cleanText = normalizedText;

    // Remove amount token
    cleanText = cleanText.replaceAll(amountPattern, '');

    // Remove date expressions
    for (final expr in [
      'settimana scorsa', 'la settimana scorsa', 'mese scorso', 'il mese scorso',
      "l'altro ieri", 'altroieri', 'yesterday', 'ieri', 'last week', 'last month',
      'day before yesterday',
      'lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica',
      'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
    ]) {
      cleanText = cleanText.replaceAll(expr, '');
    }

    // Remove paid-by expressions
    cleanText = cleanText.replaceAll(paidByPattern, '');

    // Try to extract description using "per/for/di/of" keywords
    final descPatternIt = RegExp(
      r'(?:per|di)\s+(.+?)(?:\s+al|\s+alla|\s+in|\s+da|\s+pagat|\s*$)',
      caseSensitive: false,
    );
    final descPatternEn = RegExp(
      r'(?:for|of)\s+(.+?)(?:\s+at|\s+in|\s+from|\s+paid|\s*$)',
      caseSensitive: false,
    );

    Match? descMatch = descPatternIt.firstMatch(cleanText);
    descMatch ??= descPatternEn.firstMatch(cleanText);

    if (descMatch != null) {
      var description = descMatch.group(1)?.trim() ?? '';
      description = description
          .replaceAll(amountPattern, '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
      if (description.isNotEmpty) {
        result['name'] = _capitalise(description);
      }
    }

    // Fall back: use entire cleaned text
    if (!result.containsKey('name')) {
      var description = cleanText
          .replaceAll(RegExp(r'^(per|for|di|of|a|al|alla|at)\s+'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
      if (description.isNotEmpty) {
        result['name'] = _capitalise(description);
      }
    }

    return result;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static bool _containsAny(String text, List<String> terms) =>
      terms.any((t) => text.contains(t));

  static String _capitalise(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

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
