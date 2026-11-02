import 'package:caravella_core/caravella_core.dart';

/// The kind of marker a word starts with in a fast-input line.
enum FastTokenKind { date, category, payer }

/// The marked word the cursor is in (`@ie|`, `#fo|`, `+An|`): what the
/// suggestions complete.
class FastActiveToken {
  final FastTokenKind kind;

  /// The text after the marker, up to the cursor's word end.
  final String query;

  /// Range of the whole word, marker included, in the line.
  final int start;
  final int end;

  const FastActiveToken(this.kind, this.query, this.start, this.end);
}

/// What a fast-input line says: `coffee 5.50 @yesterday #food +Anna`.
class FastInput {
  /// The words left once the amount and the marked words are taken out.
  final String? name;
  final double? amount;

  /// The `@` date; today when the line has none.
  final DateTime date;

  /// Whether the line has an `@` word.
  final bool hasDate;

  /// An `@` word that isn't a date (`@tomorow`).
  final String? invalidDate;

  /// The group's category named by `#`, or the first one by default.
  final ExpenseCategory? category;

  /// A `#` word that is no category of the group: created on save.
  final String? newCategory;

  /// The participant named by `+`, or the first one (you) by default.
  final ExpenseParticipant? paidBy;

  /// A `+` word that is nobody in the group.
  final String? unknownPayer;

  const FastInput({
    this.name,
    this.amount,
    required this.date,
    this.hasDate = false,
    this.invalidDate,
    this.category,
    this.newCategory,
    this.paidBy,
    this.unknownPayer,
  });

  bool get hasAmount => amount != null && amount! > 0;

  /// Enough to save: an amount, a payer, a category (existing or new) and
  /// no word that couldn't be understood.
  bool get isComplete =>
      hasAmount &&
      paidBy != null &&
      unknownPayer == null &&
      invalidDate == null &&
      (category != null || newCategory != null);
}

/// Reads a one-line expense: free words for the description, a number for
/// the amount (the last one when there are several), `@` for the date
/// (today, yesterday, a weekday, 28/10), `#` for the category and `+` for
/// who paid. Marker words match the group's names ignoring case, accents and
/// spaces, a prefix being enough when only one name fits.
class FastInputParser {
  FastInputParser._();

  static final RegExp _word = RegExp(r'\S+');
  static final RegExp _amount = RegExp(
    r'^[€$£¥]?(\d+(?:[.,]\d{1,2})?)[€$£¥]?$',
  );

  static FastInput parse(
    String text, {
    required List<ExpenseCategory> categories,
    required List<ExpenseParticipant> participants,
    DateTime? now,
  }) {
    final today = _day(now ?? DateTime.now());
    final words = <String>[];
    double? amount;
    int? amountIndex;
    String? dateWord;
    String? categoryWord;
    String? payerWord;

    for (final m in _word.allMatches(text)) {
      final w = m[0]!;
      if (w.length > 1 && w.startsWith('@')) {
        dateWord = w.substring(1);
      } else if (w.length > 1 && w.startsWith('#')) {
        categoryWord = w.substring(1);
      } else if (w.length > 1 && w.startsWith('+')) {
        payerWord = w.substring(1);
      } else if (w == '@' || w == '#' || w == '+') {
        // A marker still being typed.
      } else {
        final a = _amount.firstMatch(w);
        if (a != null) {
          final value = double.tryParse(a[1]!.replaceAll(',', '.'));
          if (value != null) {
            amount = value;
            amountIndex = words.length;
          }
        }
        words.add(w);
      }
    }
    if (amountIndex != null) words.removeAt(amountIndex);

    DateTime date = today;
    String? invalidDate;
    if (dateWord != null) {
      final parsed = parseDate(dateWord, today);
      if (parsed != null) {
        date = parsed;
      } else {
        invalidDate = dateWord;
      }
    }

    ExpenseCategory? category;
    String? newCategory;
    if (categoryWord != null) {
      category = matchOne(categories, categoryWord, (c) => c.name);
      if (category == null) newCategory = _readable(categoryWord);
    } else if (categories.isNotEmpty) {
      category = categories.first;
    }

    ExpenseParticipant? paidBy;
    String? unknownPayer;
    if (payerWord != null) {
      paidBy = matchOne(participants, payerWord, (p) => p.name);
      if (paidBy == null) unknownPayer = payerWord;
    } else if (participants.isNotEmpty) {
      paidBy = participants.first;
    }

    final name = words.join(' ');
    return FastInput(
      name: name.isEmpty ? null : name[0].toUpperCase() + name.substring(1),
      amount: amount,
      date: date,
      hasDate: dateWord != null,
      invalidDate: invalidDate,
      category: category,
      newCategory: newCategory,
      paidBy: paidBy,
      unknownPayer: unknownPayer,
    );
  }

  /// The marked word around [cursor], if any.
  static FastActiveToken? activeToken(String text, int cursor) {
    if (cursor < 0 || cursor > text.length) return null;
    var start = cursor;
    while (start > 0 && !_isSpace(text[start - 1])) {
      start--;
    }
    var end = cursor;
    while (end < text.length && !_isSpace(text[end])) {
      end++;
    }
    if (start == end) return null;
    final kind = switch (text[start]) {
      '@' => FastTokenKind.date,
      '#' => FastTokenKind.category,
      '+' => FastTokenKind.payer,
      _ => null,
    };
    if (kind == null) return null;
    return FastActiveToken(kind, text.substring(start + 1, end), start, end);
  }

  /// The items whose name fits [query] best: equal first, then starting
  /// with it, then containing it.
  static List<T> suggest<T>(
    List<T> items,
    String query,
    String Function(T) nameOf,
  ) {
    final q = key(query);
    if (q.isEmpty) return List.of(items);
    final equal = <T>[], prefix = <T>[], inside = <T>[];
    for (final item in items) {
      final k = key(nameOf(item));
      if (k == q) {
        equal.add(item);
      } else if (k.startsWith(q)) {
        prefix.add(item);
      } else if (k.contains(q)) {
        inside.add(item);
      }
    }
    return [...equal, ...prefix, ...inside];
  }

  /// The one item [word] names: an equal name, or the only one starting
  /// with it.
  static T? matchOne<T>(List<T> items, String word, String Function(T) nameOf) {
    final q = key(word);
    if (q.isEmpty) return null;
    for (final item in items) {
      if (key(nameOf(item)) == q) return item;
    }
    final prefix = items.where((i) => key(nameOf(i)).startsWith(q)).toList();
    return prefix.length == 1 ? prefix.first : null;
  }

  /// A name as a marker word: no spaces (`Cibo e bevande` → `CiboEBevande`).
  static String tokenFor(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join();

  /// Lower case, no accents, no spaces, `_` or `-`: how names are compared.
  static String key(String s) {
    final lower = s.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');
    final b = StringBuffer();
    for (final ch in lower.split('')) {
      b.write(_accents[ch] ?? ch);
    }
    return b.toString();
  }

  /// An `@` word as a day: today/yesterday words, a weekday (the last one,
  /// today included), or day/month[/year].
  static DateTime? parseDate(String word, DateTime today) {
    final w = key(word.replaceAll('.', '')).replaceAll("'", '');
    if (w.isEmpty) return null;
    if (_todayWords.contains(w)) return today;
    if (_yesterdayWords.contains(w)) {
      return today.subtract(const Duration(days: 1));
    }
    if (_dayBeforeWords.contains(w)) {
      return today.subtract(const Duration(days: 2));
    }
    final weekday = _weekday(w);
    if (weekday != null) {
      final back = (today.weekday - weekday) % 7;
      return today.subtract(Duration(days: back));
    }
    final m = RegExp(
      r'^(\d{1,2})[/\-](\d{1,2})(?:[/\-](\d{2}|\d{4}))?$',
    ).firstMatch(word);
    if (m != null) {
      final d = int.parse(m[1]!), mo = int.parse(m[2]!);
      var y = m[3] == null ? today.year : int.parse(m[3]!);
      if (y < 100) y += 2000;
      if (mo < 1 || mo > 12 || d < 1) return null;
      final date = DateTime(y, mo, d);
      // DateTime rolls 31/2 over into March: not a real day.
      if (date.month != mo) return null;
      return date;
    }
    return null;
  }

  static int? _weekday(String w) {
    for (final entry in _weekdays.entries) {
      for (final name in entry.value) {
        if (w == name) return entry.key;
        // An abbreviation of at least 3 letters, or a whole name
        // (lunedì, monday, martes, quarta…).
        if (name.length >= 3 && w.length >= 3 && name.startsWith(w)) {
          return entry.key;
        }
      }
    }
    return null;
  }

  static String _readable(String word) {
    final s = word.replaceAll('_', ' ').trim();
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }

  static bool _isSpace(String ch) => ch.trim().isEmpty;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static const _todayWords = {'oggi', 'today', 'hoy', 'hoje', '今天'};
  static const _yesterdayWords = {'ieri', 'yesterday', 'ayer', 'ontem', '昨天'};
  static const _dayBeforeWords = {
    'altroieri',
    'laltroieri',
    'avantieri',
    'anteayer',
    'anteontem',
    '前天',
  };

  /// Full weekday names (any of them, or 3+ leading letters, picks the day),
  /// IT · EN · ES · PT · ZH, accents already removed.
  static const _weekdays = <int, List<String>>{
    DateTime.monday: ['lunedi', 'monday', 'lunes', 'segunda', '周一', '星期一'],
    DateTime.tuesday: ['martedi', 'tuesday', 'martes', 'terca', '周二', '星期二'],
    DateTime.wednesday: [
      'mercoledi',
      'wednesday',
      'miercoles',
      'quarta',
      '周三',
      '星期三',
    ],
    DateTime.thursday: ['giovedi', 'thursday', 'jueves', 'quinta', '周四', '星期四'],
    DateTime.friday: ['venerdi', 'friday', 'viernes', 'sexta', '周五', '星期五'],
    DateTime.saturday: ['sabato', 'saturday', 'sabado', '周六', '星期六'],
    DateTime.sunday: ['domenica', 'sunday', 'domingo', '周日', '星期日', '星期天'],
  };

  static const _accents = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', //
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', //
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', //
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', //
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', //
    'ç': 'c', 'ñ': 'n',
  };
}
