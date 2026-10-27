import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Keeps the five ARB files consistent: same keys, and the typography the
/// app uses (typographic apostrophes, “…” not "...", full-width punctuation
/// in Chinese).
void main() {
  const languages = ['en', 'it', 'es', 'pt', 'zh'];
  final arbs = {
    for (final l in languages)
      l:
          (jsonDecode(File('lib/l10n/app_$l.arb').readAsStringSync())
                  as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v))
            ..removeWhere((k, v) => k.startsWith('@') || v is! String),
  };

  test('every language has the same keys', () {
    final en = arbs['en']!.keys.toSet();
    for (final l in languages.skip(1)) {
      expect(arbs[l]!.keys.toSet().difference(en), isEmpty, reason: l);
      expect(en.difference(arbs[l]!.keys.toSet()), isEmpty, reason: l);
    }
  });

  test('typographic apostrophes and ellipsis', () {
    final straight = RegExp(r"\w'\w");
    for (final l in ['en', 'it', 'es', 'pt']) {
      arbs[l]!.forEach((key, value) {
        // A currency's own spelling.
        if (key == 'currency_UZS') return;
        expect(straight.hasMatch(value), isFalse, reason: '$l $key: $value');
        expect(value.contains('...'), isFalse, reason: '$l $key: $value');
      });
    }
  });

  test('Chinese uses full-width punctuation', () {
    final ascii = RegExp(r'[一-鿿][,:;?!]|[,:;?!] ?[一-鿿]');
    arbs['zh']!.forEach((key, value) {
      expect(ascii.hasMatch(value), isFalse, reason: '$key: $value');
    });
  });
}
