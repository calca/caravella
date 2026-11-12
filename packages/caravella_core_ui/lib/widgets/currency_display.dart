import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

class CurrencyDisplay extends StatelessWidget {
  final double value;
  final String currency;
  final double valueFontSize;
  final double currencyFontSize;
  final MainAxisAlignment alignment;
  final bool showDecimals;
  final Color? color;
  final FontWeight? fontWeight;

  const CurrencyDisplay({
    super.key,
    required this.value,
    required this.currency,
    this.valueFontSize = 54.0,
    this.currencyFontSize = 22.0,
    this.alignment = MainAxisAlignment.end,
    this.showDecimals = false,
    this.color,
    this.fontWeight,
  });

  /// Formats a currency value as plain text for use in semantic labels,
  /// exports, or other text-only contexts.
  ///
  /// Example: `CurrencyDisplay.formatCurrencyText(123.45, 'EUR')` returns "123.45 EUR"
  static String formatCurrencyText(
    double value,
    String currency, {
    bool showDecimals = true,
  }) {
    final formattedValue = showDecimals
        ? value.toStringAsFixed(2)
        : value.truncate().toString();
    return '$formattedValue $currency';
  }

  /// Like [formatCurrencyText], with the decimal separator of [locale]: for
  /// amounts written in text on screen ("22,33 €" in Italian). Exports keep
  /// [formatCurrencyText], whose format doesn't depend on the language.
  static String formatLocalizedText(
    double value,
    String currency,
    Locale? locale,
  ) {
    final amount = value
        .toStringAsFixed(2)
        .replaceAll('.', _decimalSeparator(locale));
    return '$amount $currency';
  }

  /// An exchange rate as text: up to four decimals, no trailing zeros
  /// ("11,63", "0,0865", "10"), with the decimal separator of [locale].
  static String formatRate(double rate, Locale? locale) {
    var text = rate.toStringAsFixed(4);
    text = text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
    return text.replaceAll('.', _decimalSeparator(locale));
  }

  /// "1 € = 11,63 kr": one unit of [from] in [to], at [rate].
  static String formatRateLine(
    String from,
    double rate,
    String to,
    Locale? locale,
  ) => '1 $from = ${formatRate(rate, locale)} $to';

  static String _decimalSeparator(Locale? locale) {
    if (locale == null) return '.';
    try {
      return NumberFormat.decimalPattern(locale.toString()).symbols.DECIMAL_SEP;
    } catch (_) {
      // Fallback to dot if locale detection fails
      return '.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final decimalSeparator = _decimalSeparator(
      Localizations.maybeLocaleOf(context),
    );

    final String formattedValue = showDecimals
        ? value.toStringAsFixed(2).replaceAll('.', decimalSeparator)
        : value.truncate().toString();

    return Row(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: showDecimals
              ? _buildValueWithSeparateDecimals(
                  context,
                  formattedValue,
                  decimalSeparator,
                )
              : Text(
                  formattedValue,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: color ?? Theme.of(context).colorScheme.onSurface,
                    fontSize: valueFontSize,
                    fontWeight: fontWeight,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
        ),
        const SizedBox(width: 4),
        Text(
          currency,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: color ?? Theme.of(context).colorScheme.onSurface,
            fontSize: currencyFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildValueWithSeparateDecimals(
    BuildContext context,
    String formattedValue,
    String decimalSeparator,
  ) {
    final parts = formattedValue.split(decimalSeparator);
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '$decimalSeparator${parts[1]}' : '';

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: integerPart,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: color ?? Theme.of(context).colorScheme.onSurface,
              fontSize: valueFontSize,
              fontWeight: fontWeight,
            ),
          ),
          if (decimalPart.isNotEmpty)
            TextSpan(
              text: decimalPart,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: color ?? Theme.of(context).colorScheme.onSurface,
                fontSize: currencyFontSize,
              ),
            ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
