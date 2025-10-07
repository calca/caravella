import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/services/voice_input_service.dart';

void main() {
  group('VoiceInputService parsing tests', () {
    test('Parse amount in Italian with euro', () {
      final result = VoiceInputService.parseExpenseFromText('50 euro per cena');
      expect(result['amount'], equals(50.0));
    });

    test('Parse amount with decimal in English', () {
      final result = VoiceInputService.parseExpenseFromText('25.50 dollars for lunch');
      expect(result['amount'], equals(25.50));
    });

    test('Parse amount with comma as decimal separator', () {
      final result = VoiceInputService.parseExpenseFromText('35,75 euro per pranzo');
      expect(result['amount'], equals(35.75));
    });

    test('Parse description in Italian', () {
      final result = VoiceInputService.parseExpenseFromText('50 euro per cena al ristorante');
      expect(result['name'], isNotNull);
      expect(result['name'], contains('cena'));
    });

    test('Parse description in English', () {
      final result = VoiceInputService.parseExpenseFromText('30 dollars for dinner at restaurant');
      expect(result['name'], isNotNull);
      expect(result['name'], contains('dinner'));
    });

    test('Detect food category from Italian keywords', () {
      final result = VoiceInputService.parseExpenseFromText('45 euro per cena');
      expect(result['category'], equals('food'));
    });

    test('Detect transport category from English keywords', () {
      final result = VoiceInputService.parseExpenseFromText('60 dollars for gas');
      expect(result['category'], equals('transport'));
    });

    test('Detect accommodation category', () {
      final result = VoiceInputService.parseExpenseFromText('100 euro per hotel');
      expect(result['category'], equals('accommodation'));
    });

    test('Parse complex expense with all fields', () {
      final result = VoiceInputService.parseExpenseFromText('75.50 euro per cena al ristorante');
      expect(result['amount'], equals(75.50));
      expect(result['name'], isNotNull);
      expect(result['category'], equals('food'));
    });

    test('Handle expense without category keyword', () {
      final result = VoiceInputService.parseExpenseFromText('20 euro per regalo');
      expect(result['amount'], equals(20.0));
      expect(result['name'], isNotNull);
      expect(result['category'], isNull);
    });

    test('Parse amount without currency symbol', () {
      final result = VoiceInputService.parseExpenseFromText('15 per caffè');
      expect(result['amount'], equals(15.0));
    });

    test('Parse expense with currency symbol before amount', () {
      final result = VoiceInputService.parseExpenseFromText('€30 for lunch');
      expect(result['amount'], equals(30.0));
    });

    test('Handle empty text', () {
      final result = VoiceInputService.parseExpenseFromText('');
      expect(result['amount'], isNull);
      expect(result['name'], isNull);
    });

    test('Handle text without numbers', () {
      final result = VoiceInputService.parseExpenseFromText('cena al ristorante');
      expect(result['amount'], isNull);
      expect(result['name'], isNotNull);
      expect(result['category'], equals('food'));
    });
  });
}
