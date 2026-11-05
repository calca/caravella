import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('localized text uses the decimal separator of the language', () {
    String format(Locale? locale) =>
        CurrencyDisplay.formatLocalizedText(22.333, '€', locale);

    expect(format(const Locale('it')), '22,33 €');
    expect(format(const Locale('en')), '22.33 €');
    expect(format(null), '22.33 €');
  });

  test('plain text keeps the dot, for exports', () {
    expect(CurrencyDisplay.formatCurrencyText(22.333, '€'), '22.33 €');
  });
}
