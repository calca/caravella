import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:caravella_core/caravella_core.dart';

/// Service to handle voice input and speech recognition.
///
/// Supports all 5 app locales: IT, EN, ES, PT, ZH.
class VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  /// Check if voice recognition is available
  Future<bool> isAvailable() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) => LoggerService.warning(
          'Speech recognition error: $error',
          name: 'voice_input',
        ),
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
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        partialResults: false,
      ),
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

  // ───────────────────────────────────────────────────────────────────────────
  // SMART PARSER
  // Supports all 5 app locales: IT, EN, ES, PT, ZH
  // ───────────────────────────────────────────────────────────────────────────

  /// Parse voice text to extract expense information.
  ///
  /// Returns a map with keys:
  ///   - `amount`    (double?)   – monetary value
  ///   - `name`      (String?)   – expense description
  ///   - `category`  (String?)   – detected category keyword
  ///   - `paidBy`    (String?)   – participant name (if detectable)
  ///   - `date`      (DateTime?) – date parsed from relative expressions
  ///
  /// Pass [participantNames] to enable fuzzy participant-name matching.
  static Map<String, dynamic> parseExpenseFromText(
    String text, {
    List<String> participantNames = const [],
  }) {
    final result = <String, dynamic>{};
    if (text.trim().isEmpty) return result;

    final t = text.toLowerCase().trim();

    // ── 1. AMOUNT ────────────────────────────────────────────────────────────
    // Handles: "50", "25.50", "35,75", "€50", "$50", "50 euro", "50 dollars",
    // "50 reais", "50 pesos", "50 yuan", "50元", etc.
    final amountPattern = RegExp(
      r'(\d+(?:[.,]\d{1,2})?)\s*'
      r'(?:euro|eur|€|dollar|dollaro|dollari|usd|\$|pound|£|'
      r'real|reais|r\$|peso|pesos|yuan|rmb|元|¥|kr|chf|cad|aud)?',
      caseSensitive: false,
    );
    final amountMatch = amountPattern.firstMatch(t);
    if (amountMatch != null) {
      final amountStr = amountMatch.group(1)?.replaceAll(',', '.');
      final parsed = double.tryParse(amountStr ?? '');
      if (parsed != null && parsed > 0) {
        result['amount'] = parsed;
      }
    }

    // ── 2. DATE ───────────────────────────────────────────────────────────────
    // IT, EN, ES, PT, ZH relative date expressions
    final now = DateTime.now();
    DateTime? parsedDate;

    // Yesterday expressions
    if (_containsAny(t, [
      'ieri', // IT
      'yesterday', // EN
      'ayer', // ES
      'ontem', // PT
      '昨天', '昨日', // ZH
    ])) {
      parsedDate = now.subtract(const Duration(days: 1));
    }
    // Day-before-yesterday
    else if (_containsAny(t, [
      "l'altro ieri", 'altroieri', // IT
      'day before yesterday', // EN
      'anteayer', // ES
      'anteontem', // PT
      '前天', // ZH
    ])) {
      parsedDate = now.subtract(const Duration(days: 2));
    }
    // Last week
    else if (_containsAny(t, [
      'settimana scorsa', 'la settimana scorsa', // IT
      'last week', // EN
      'la semana pasada', 'semana pasada', // ES
      'semana passada', 'na semana passada', // PT
      '上周', '上週', '上个星期', '上個星期', // ZH
    ])) {
      parsedDate = now.subtract(const Duration(days: 7));
    }
    // Last month
    else if (_containsAny(t, [
      'mese scorso', 'il mese scorso', // IT
      'last month', // EN
      'el mes pasado', 'mes pasado', // ES
      'mês passado', 'no mês passado', // PT
      '上个月', '上個月', // ZH
    ])) {
      parsedDate = DateTime(now.year, now.month - 1, now.day);
    }
    // Named day of week (Mon=1 … Sun=7) → most recent past occurrence
    else {
      // Each inner list = [Mon, Tue, Wed, Thu, Fri, Sat, Sun] for that locale
      final dayGroups = [
        // IT
        [
          'lunedì',
          'martedì',
          'mercoledì',
          'giovedì',
          'venerdì',
          'sabato',
          'domenica',
        ],
        // EN
        [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
          'sunday',
        ],
        // ES
        [
          'lunes',
          'martes',
          'miércoles',
          'jueves',
          'viernes',
          'sábado',
          'domingo',
        ],
        // PT
        [
          'segunda-feira',
          'terça-feira',
          'quarta-feira',
          'quinta-feira',
          'sexta-feira',
          'sábado',
          'domingo',
        ],
        // ZH
        [
          '周一',
          '周二',
          '周三',
          '周四',
          '周五',
          '周六',
          '周日',
          '星期一',
          '星期二',
          '星期三',
          '星期四',
          '星期五',
          '星期六',
          '星期日',
        ],
      ];

      outer:
      for (final group in dayGroups) {
        // ZH group has 14 entries (two naming conventions); map indices 7-13 → 0-6
        for (int i = 0; i < group.length; i++) {
          if (t.contains(group[i])) {
            final targetWeekday = (i % 7) + 1; // ISO Mon=1..Sun=7
            int diff = now.weekday - targetWeekday;
            if (diff <= 0) diff += 7;
            parsedDate = now.subtract(Duration(days: diff));
            break outer;
          }
        }
      }
    }

    if (parsedDate != null) result['date'] = parsedDate;

    // ── 3. PAID-BY (participant name) ────────────────────────────────────────
    // Structured keyword patterns for all 5 locales
    final paidByPattern = RegExp(
      r'(?:'
      r'pagato\s+da|pagata\s+da|pago\s+da|' // IT
      r'paid\s+by|' // EN
      r'pagado\s+por|pagada\s+por|' // ES
      r'pago\s+por|paga\s+por|' // PT
      r'由\s*|付款人\s*[:：]?\s*' // ZH
      r')\s*([a-z\u00c0-\u024f\u4e00-\u9fff][a-z\u00c0-\u024f\u4e00-\u9fff\s]+?)'
      r'(?:\s+(?:per|para|por|for|de|di)|\s*$)',
      caseSensitive: false,
    );
    final paidByMatch = paidByPattern.firstMatch(t);
    if (paidByMatch != null) {
      final name = _capitalise(paidByMatch.group(1)?.trim() ?? '');
      if (name.isNotEmpty) result['paidBy'] = name;
    }

    // Fallback: try to match known participant names anywhere in text
    if (!result.containsKey('paidBy') && participantNames.isNotEmpty) {
      for (final pName in participantNames) {
        if (t.contains(pName.toLowerCase())) {
          result['paidBy'] = pName;
          break;
        }
      }
    }

    // ── 4. CATEGORY ──────────────────────────────────────────────────────────
    // Keywords for IT, EN, ES, PT, ZH combined
    final categoryKeywords = <String, List<String>>{
      'food': [
        // IT
        'cena', 'pranzo', 'colazione', 'ristorante', 'pizzeria', 'bar',
        'caffè', 'caffe', 'aperitivo', 'sushi', 'cibo', 'mangiare',
        'supermercato', 'gelato', 'pizza',
        // EN
        'dinner', 'lunch', 'breakfast', 'restaurant', 'food', 'groceries',
        'supermarket', 'fast food', 'snack',
        // ES
        'cena', 'almuerzo', 'desayuno', 'restaurante', 'comida',
        'supermercado', 'café',
        // PT
        'jantar', 'almoço', 'café da manhã', 'restaurante', 'comida',
        'supermercado', 'mercado',
        // ZH
        '晚餐', '午餐', '早餐', '餐厅', '食物', '超市', '咖啡',
      ],
      'transport': [
        // IT
        'benzina', 'carburante', 'gasolio', 'taxi', 'uber', 'treno',
        'autobus', 'bus', 'metro', 'metropolitana', 'aereo', 'volo',
        'parcheggio', 'autostrada', 'pedaggio', 'traghetto', 'biglietto',
        // EN
        'gas', 'fuel', 'train', 'flight', 'parking', 'toll',
        'car rental', 'ride', 'ferry', 'ticket', 'subway',
        // ES
        'gasolina', 'combustible', 'autobús', 'avión', 'vuelo',
        'estacionamiento', 'peaje', 'transporte',
        // PT
        'gasolina', 'combustível', 'ônibus', 'avião', 'voo',
        'estacionamento', 'pedágio', 'transporte', 'metrô',
        // ZH
        '出租车', '地铁', '公交', '火车', '飞机', '停车', '加油',
        '交通', '票',
      ],
      'accommodation': [
        // IT/EN
        'hotel', 'albergo', 'airbnb', 'ostello', 'hostel', 'affitto',
        'appartamento', 'b&b', 'bed and breakfast', 'rent', 'alloggio',
        'camping', 'tenda',
        // ES
        'hospedaje', 'alojamiento', 'apartamento', 'alquiler',
        // PT
        'hospedagem', 'alojamento', 'apartamento', 'aluguel',
        // ZH
        '酒店', '旅馆', '民宿', '住宿', '租金',
      ],
      'entertainment': [
        // IT/EN
        'cinema', 'teatro', 'theater', 'museo', 'museum', 'concerto',
        'concert', 'spettacolo', 'show', 'zoo', 'discoteca', 'club',
        'palestra', 'gym', 'piscina', 'swimming pool', 'sport',
        // ES
        'cine', 'teatro', 'museo', 'concierto', 'espectáculo',
        'discoteca', 'deporte',
        // PT
        'cinema', 'teatro', 'museu', 'show', 'concerto',
        'discoteca', 'esporte',
        // ZH
        '电影', '剧院', '博物馆', '演唱会', '音乐会', '健身', '游泳',
        '娱乐',
      ],
      'shopping': [
        // IT/EN
        'shopping', 'acquisti', 'negozio', 'shop', 'store', 'vestiti',
        'abbigliamento', 'clothes', 'scarpe', 'shoes', 'elettronica',
        'electronics', 'libri', 'books', 'regalo', 'gift', 'souvenir',
        // ES
        'compras', 'tienda', 'ropa', 'zapatos', 'electrónica', 'libros',
        'regalo',
        // PT
        'compras', 'loja', 'roupas', 'sapatos', 'eletrônicos', 'livros',
        'presente',
        // ZH
        '购物', '商店', '衣服', '鞋子', '电子', '书', '礼物',
      ],
      'health': [
        // IT/EN
        'medico', 'dottore', 'doctor', 'farmacia', 'pharmacy',
        'medicine', 'medicina', 'ospedale', 'hospital', 'dentista',
        'dentist', 'visita', 'analisi',
        // ES
        'médico', 'farmacia', 'medicina', 'hospital', 'dentista',
        'consulta',
        // PT
        'médico', 'farmácia', 'remédio', 'hospital', 'dentista',
        'consulta',
        // ZH
        '医生', '药店', '药', '医院', '牙医', '诊所', '检查',
      ],
    };

    for (final entry in categoryKeywords.entries) {
      if (entry.value.any((kw) => t.contains(kw))) {
        result['category'] = entry.key;
        break;
      }
    }

    // ── 5. DESCRIPTION (name) ────────────────────────────────────────────────
    // Strip consumed tokens before extracting description
    String cleanText = t.replaceAll(amountPattern, '');

    // Strip all date tokens
    for (final expr in [
      // IT
      'settimana scorsa',
      'la settimana scorsa',
      'mese scorso',
      'il mese scorso',
      "l'altro ieri", 'altroieri', 'ieri',
      'lunedì',
      'martedì',
      'mercoledì',
      'giovedì',
      'venerdì',
      'sabato',
      'domenica',
      // EN
      'day before yesterday', 'yesterday', 'last week', 'last month',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
      // ES
      'anteayer', 'ayer', 'semana pasada', 'la semana pasada',
      'mes pasado', 'el mes pasado',
      'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
      // PT
      'anteontem', 'ontem', 'semana passada', 'na semana passada',
      'mês passado', 'no mês passado',
      'segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira',
      'sexta-feira',
      // ZH
      '前天', '昨天', '昨日', '上周', '上週', '上个星期', '上個星期',
      '上个月', '上個月',
      '周一', '周二', '周三', '周四', '周五', '周六', '周日',
      '星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日',
    ]) {
      cleanText = cleanText.replaceAll(expr, '');
    }

    // Strip paid-by expression
    cleanText = cleanText.replaceAll(paidByPattern, '');

    // Description-lead keywords per locale: IT "per/di", EN "for/of",
    // ES "para/de", PT "para/de", ZH "为/为了/用于"
    final descPattern = RegExp(
      r'(?:per|di|for|of|para|de|为了?|用于)\s+(.+?)'
      r'(?:\s+(?:al|alla|in|da|at|from|en|no|a|em|付|支付)|\s*$)',
      caseSensitive: false,
    );

    Match? descMatch = descPattern.firstMatch(cleanText);

    if (descMatch != null) {
      var desc = descMatch.group(1)?.trim() ?? '';
      desc = desc
          .replaceAll(amountPattern, '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
      if (desc.isNotEmpty) result['name'] = _capitalise(desc);
    }

    // Fallback: entire cleaned text without leading prepositions
    if (!result.containsKey('name')) {
      var desc = cleanText
          .replaceAll(
            RegExp(r'^(per|for|di|of|a|al|alla|at|para|de|为了?|用于)\s+'),
            '',
          )
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
      if (desc.isNotEmpty) result['name'] = _capitalise(desc);
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
