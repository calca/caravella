import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/widgets/currency_display.dart';

void main() {
  group('CurrencyDisplay.formatCurrencyText', () {
    test('formats with two decimals by default', () {
      expect(CurrencyDisplay.formatCurrencyText(123.4, 'EUR'), '123.40 EUR');
    });

    test('rounds to two decimals', () {
      expect(CurrencyDisplay.formatCurrencyText(1.005, 'USD'), '1.00 USD');
      expect(CurrencyDisplay.formatCurrencyText(1.999, 'USD'), '2.00 USD');
    });

    test('truncates instead of rounding when showDecimals is false', () {
      expect(
        CurrencyDisplay.formatCurrencyText(123.99, 'EUR', showDecimals: false),
        '123 EUR',
      );
    });

    test('handles zero and negative values', () {
      expect(CurrencyDisplay.formatCurrencyText(0, 'EUR'), '0.00 EUR');
      expect(CurrencyDisplay.formatCurrencyText(-42.5, 'EUR'), '-42.50 EUR');
    });

    test('preserves the given currency code verbatim', () {
      expect(CurrencyDisplay.formatCurrencyText(10, 'GBP'), '10.00 GBP');
    });
  });

  group('CurrencyDisplay widget', () {
    testWidgets('renders the integer part and currency code', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrencyDisplay(value: 42.5, currency: 'EUR'),
          ),
        ),
      );

      expect(find.textContaining('42'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
    });

    testWidgets('shows separated decimals when showDecimals is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrencyDisplay(
              value: 42.5,
              currency: 'EUR',
              showDecimals: true,
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });
  });
}
