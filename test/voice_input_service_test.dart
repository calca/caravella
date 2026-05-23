import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/services/voice_input_service.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helper to call with no participant names (most tests don't need them)
  // ---------------------------------------------------------------------------
  Map<String, dynamic> parse(String text, {List<String> names = const []}) =>
      VoiceInputService.parseExpenseFromText(text, participantNames: names);

  // ── AMOUNT ──────────────────────────────────────────────────────────────────
  group('Amount parsing', () {
    test('integer with "euro" keyword (IT)', () {
      expect(parse('50 euro per cena')['amount'], equals(50.0));
    });

    test('decimal with "dollars" keyword (EN)', () {
      expect(parse('25.50 dollars for lunch')['amount'], equals(25.50));
    });

    test('comma decimal separator (IT)', () {
      expect(parse('35,75 euro per pranzo')['amount'], equals(35.75));
    });

    test('currency symbol before amount', () {
      expect(parse('€30 for lunch')['amount'], equals(30.0));
    });

    test('integer without currency symbol', () {
      expect(parse('15 per caffè')['amount'], equals(15.0));
    });

    test('reais (PT)', () {
      expect(parse('50 reais para o jantar')['amount'], equals(50.0));
    });

    test('pesos (ES)', () {
      expect(parse('200 pesos para la cena')['amount'], equals(200.0));
    });

    test('yuan / 元 (ZH)', () {
      expect(parse('80元晚餐')['amount'], equals(80.0));
    });

    test('empty text returns null', () {
      expect(parse('')['amount'], isNull);
    });
  });

  // ── CATEGORY ─────────────────────────────────────────────────────────────────
  group('Category detection', () {
    // IT
    test('cena → food (IT)', () {
      expect(parse('45 euro per cena')['category'], equals('food'));
    });
    test('benzina → transport (IT)', () {
      expect(parse('60 euro benzina')['category'], equals('transport'));
    });
    test('hotel → accommodation', () {
      expect(parse('100 euro per hotel')['category'], equals('accommodation'));
    });
    test('cinema → entertainment', () {
      expect(parse('12 euro cinema')['category'], equals('entertainment'));
    });
    test('farmacia → health (IT)', () {
      expect(parse('8 euro farmacia')['category'], equals('health'));
    });

    // EN
    test('gas → transport (EN)', () {
      expect(parse('60 dollars for gas')['category'], equals('transport'));
    });
    test('dinner → food (EN)', () {
      expect(parse('30 dollars for dinner')['category'], equals('food'));
    });

    // ES
    test('gasolina → transport (ES)', () {
      expect(parse('60 euros gasolina')['category'], equals('transport'));
    });
    test('restaurante → food (ES)', () {
      expect(parse('50 euros restaurante')['category'], equals('food'));
    });

    // PT
    test('jantar → food (PT)', () {
      expect(parse('50 reais jantar')['category'], equals('food'));
    });
    test('gasolina → transport (PT)', () {
      expect(parse('100 reais gasolina')['category'], equals('transport'));
    });

    // ZH
    test('晚餐 → food (ZH)', () {
      expect(parse('50元 晚餐')['category'], equals('food'));
    });
    test('地铁 → transport (ZH)', () {
      expect(parse('5元 地铁')['category'], equals('transport'));
    });
    test('酒店 → accommodation (ZH)', () {
      expect(parse('300元 酒店')['category'], equals('accommodation'));
    });

    test('no category keyword', () {
      expect(parse('20 euro per Marco')['category'], isNull);
    });
  });

  // ── DESCRIPTION ──────────────────────────────────────────────────────────────
  group('Description extraction', () {
    test('IT "per" keyword', () {
      final r = parse('50 euro per cena al ristorante');
      expect(r['name'], isNotNull);
      expect((r['name'] as String).toLowerCase(), contains('cena'));
    });

    test('EN "for" keyword', () {
      final r = parse('30 dollars for dinner at restaurant');
      expect(r['name'], isNotNull);
      expect((r['name'] as String).toLowerCase(), contains('dinner'));
    });

    test('ES "para" keyword', () {
      final r = parse('50 euros para la cena en el restaurante');
      expect(r['name'], isNotNull);
      expect((r['name'] as String).toLowerCase(), contains('cena'));
    });

    test('PT "para" keyword', () {
      final r = parse('50 reais para o jantar');
      expect(r['name'], isNotNull);
      expect((r['name'] as String).toLowerCase(), contains('jantar'));
    });

    test('no keywords → fallback to whole text', () {
      final r = parse('cena al ristorante');
      expect(r['name'], isNotNull);
    });

    test('empty text has no name', () {
      expect(parse('')['name'], isNull);
    });
  });

  // ── DATE ─────────────────────────────────────────────────────────────────────
  group('Date extraction', () {
    final now = DateTime.now();

    test('ieri → yesterday (IT)', () {
      final date = parse('50 euro ieri')['date'] as DateTime?;
      expect(date, isNotNull);
      expect(date!.day, equals(now.subtract(const Duration(days: 1)).day));
    });

    test('yesterday → yesterday (EN)', () {
      final date = parse('50 dollars yesterday')['date'] as DateTime?;
      expect(date, isNotNull);
      expect(date!.day, equals(now.subtract(const Duration(days: 1)).day));
    });

    test('ayer → yesterday (ES)', () {
      final date = parse('50 euros ayer')['date'] as DateTime?;
      expect(date, isNotNull);
      expect(date!.day, equals(now.subtract(const Duration(days: 1)).day));
    });

    test('ontem → yesterday (PT)', () {
      final date = parse('50 reais ontem')['date'] as DateTime?;
      expect(date, isNotNull);
      expect(date!.day, equals(now.subtract(const Duration(days: 1)).day));
    });

    test('昨天 → yesterday (ZH)', () {
      final date = parse('50元 昨天')['date'] as DateTime?;
      expect(date, isNotNull);
      expect(date!.day, equals(now.subtract(const Duration(days: 1)).day));
    });

    test('last week → 7 days ago (EN)', () {
      final date = parse('50 dollars last week')['date'] as DateTime?;
      expect(date, isNotNull);
      expect(date!.day, equals(now.subtract(const Duration(days: 7)).day));
    });

    test('settimana scorsa → 7 days ago (IT)', () {
      final date = parse('50 euro settimana scorsa')['date'] as DateTime?;
      expect(date, isNotNull);
      expect(date!.day, equals(now.subtract(const Duration(days: 7)).day));
    });

    test('semana pasada → 7 days ago (ES)', () {
      final date = parse('50 euros la semana pasada')['date'] as DateTime?;
      expect(date, isNotNull);
      expect(date!.day, equals(now.subtract(const Duration(days: 7)).day));
    });

    test('no date expression → date is null', () {
      expect(parse('50 euro per cena')['date'], isNull);
    });
  });

  // ── PAID-BY ──────────────────────────────────────────────────────────────────
  group('PaidBy extraction', () {
    test('IT "pagato da" structured keyword', () {
      final r = parse('50 euro pagato da Marco');
      expect(r['paidBy'], equals('Marco'));
    });

    test('EN "paid by" structured keyword', () {
      final r = parse('30 dollars paid by Sara');
      expect(r['paidBy'], equals('Sara'));
    });

    test('ES "pagado por" structured keyword', () {
      final r = parse('50 euros pagado por Carlos');
      expect(r['paidBy'], equals('Carlos'));
    });

    test('PT "pago por" structured keyword', () {
      final r = parse('50 reais pago por João');
      expect(r['paidBy'], equals('João'));
    });

    test('fuzzy name match from participant list', () {
      final r = parse('50 euro cena Marco', names: ['Marco', 'Sara']);
      expect(r['paidBy'], equals('Marco'));
    });

    test('no paidBy if not present', () {
      expect(parse('50 euro per cena')['paidBy'], isNull);
    });
  });
}
