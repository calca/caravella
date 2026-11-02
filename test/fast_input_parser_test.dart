import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/expense/fast_input/fast_input_parser.dart';

void main() {
  final food = ExpenseCategory(id: 'f', name: 'Cibo');
  final transport = ExpenseCategory(id: 't', name: 'Trasporti');
  final drinks = ExpenseCategory(id: 'd', name: 'Cibo e bevande');
  final me = ExpenseParticipant(id: 'g', name: 'Gianluigi');
  final anna = ExpenseParticipant(id: 'a', name: 'Anna');
  final annaMaria = ExpenseParticipant(id: 'am', name: 'Anna Maria');
  // Monday 2 November 2026.
  final now = DateTime(2026, 11, 2, 10, 30);

  FastInput parse(String text) => FastInputParser.parse(
    text,
    categories: [food, transport, drinks],
    participants: [me, anna, annaMaria],
    now: now,
  );

  group('parse', () {
    test('the issue example', () {
      final r = parse('coffee 5.50 @yesterday #cibo');
      expect(r.name, 'Coffee');
      expect(r.amount, 5.5);
      expect(r.date, DateTime(2026, 11, 1));
      expect(r.category, food);
      expect(r.paidBy, me);
      expect(r.isComplete, isTrue);
    });

    test('comma decimals, currency signs and the last number', () {
      expect(parse('caffè 5,50').amount, 5.5);
      expect(parse('taxi €12').amount, 12);
      expect(parse('taxi 12€').amount, 12);
      final r = parse('2 pizze 18');
      expect(r.amount, 18);
      expect(r.name, '2 pizze');
    });

    test('defaults: today, the first category, the first participant', () {
      final r = parse('pane 3');
      expect(r.date, DateTime(2026, 11, 2));
      expect(r.hasDate, isFalse);
      expect(r.category, food);
      expect(r.paidBy, me);
    });

    test('+ picks the payer, ignoring case, accents and spaces', () {
      expect(parse('pane 3 +anna').paidBy, anna);
      expect(parse('pane 3 +AnnaMaria').paidBy, annaMaria);
      expect(parse('pane 3 +gian').paidBy, me);
    });

    test('an ambiguous or unknown payer is not guessed', () {
      // "Ann" starts both Anna and Anna Maria, but Anna is not equal to it.
      final r = parse('pane 3 +ann');
      expect(r.paidBy, isNull);
      expect(r.unknownPayer, 'ann');
      expect(r.isComplete, isFalse);
      expect(parse('pane 3 +Luca').unknownPayer, 'Luca');
    });

    test('# picks the category; an unknown one is new', () {
      expect(parse('bus 2 #tras').category, transport);
      expect(parse('vino 9 #ciboebevande').category, drinks);
      final r = parse('cena 40 #ristoranti');
      expect(r.category, isNull);
      expect(r.newCategory, 'Ristoranti');
      expect(r.isComplete, isTrue);
    });

    test('no amount, no save', () {
      final r = parse('cena al porto');
      expect(r.amount, isNull);
      expect(r.name, 'Cena al porto');
      expect(r.isComplete, isFalse);
    });

    test('a marker alone is ignored while typing', () {
      final r = parse('pane 3 #');
      expect(r.category, food);
      expect(r.name, 'Pane');
    });

    test('an @ word that is no date', () {
      final r = parse('pane 3 @domani');
      expect(r.invalidDate, 'domani');
      expect(r.isComplete, isFalse);
    });
  });

  group('parseDate', () {
    final today = DateTime(2026, 11, 2); // Monday

    test('today and yesterday words in every language', () {
      for (final w in ['oggi', 'today', 'hoy', 'hoje', '今天']) {
        expect(FastInputParser.parseDate(w, today), today, reason: w);
      }
      for (final w in ['ieri', 'Yesterday', 'ayer', 'ontem', '昨天']) {
        expect(
          FastInputParser.parseDate(w, today),
          DateTime(2026, 11, 1),
          reason: w,
        );
      }
      expect(
        FastInputParser.parseDate("l'altroieri", today),
        DateTime(2026, 10, 31),
      );
    });

    test('weekdays go back to the last one, today included', () {
      expect(FastInputParser.parseDate('lun', today), today);
      expect(FastInputParser.parseDate('sab', today), DateTime(2026, 10, 31));
      expect(
        FastInputParser.parseDate('venerdì', today),
        DateTime(2026, 10, 30),
      );
      expect(FastInputParser.parseDate('sáb.', today), DateTime(2026, 10, 31));
      expect(FastInputParser.parseDate('tue', today), DateTime(2026, 10, 27));
      expect(FastInputParser.parseDate('周六', today), DateTime(2026, 10, 31));
    });

    test('day/month, with an optional year', () {
      expect(FastInputParser.parseDate('28/10', today), DateTime(2026, 10, 28));
      expect(FastInputParser.parseDate('3-1-25', today), DateTime(2025, 1, 3));
      expect(FastInputParser.parseDate('31/2', today), isNull);
      expect(FastInputParser.parseDate('domani', today), isNull);
    });
  });

  group('activeToken', () {
    test('the marked word around the cursor', () {
      final t = FastInputParser.activeToken('benzina 62 #tr', 14)!;
      expect(t.kind, FastTokenKind.category);
      expect(t.query, 'tr');
      expect((t.start, t.end), (11, 14));
      expect(FastInputParser.activeToken('x +', 3)!.kind, FastTokenKind.payer);
      expect(FastInputParser.activeToken('benzina 62', 10), isNull);
      expect(FastInputParser.activeToken('a ', 2), isNull);
    });
  });

  group('suggest', () {
    test('equal, then prefix, then contains', () {
      final s = FastInputParser.suggest(
        [drinks, transport, food],
        'cibo',
        (c) => c.name,
      );
      expect(s, [food, drinks]);
    });
  });

  test('tokenFor joins words', () {
    expect(FastInputParser.tokenFor('Cibo e bevande'), 'CiboEBevande');
    expect(FastInputParser.tokenFor('Anna'), 'Anna');
  });
}
