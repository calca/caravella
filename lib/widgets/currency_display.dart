import 'package:flutter/material.dart';

class CurrencyDisplay extends StatelessWidget {
  final double value;
  final String currency;
  final double valueFontSize;
  final double currencyFontSize;
  final MainAxisAlignment alignment;
  final bool showDecimals;
  final Color? color;

  const CurrencyDisplay({
    super.key,
    required this.value,
    required this.currency,
    this.valueFontSize = 54.0,
    this.currencyFontSize = 22.0,
    this.alignment = MainAxisAlignment.end,
    this.showDecimals = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedValue =
        showDecimals ? value.toStringAsFixed(2) : value.truncate().toString();

    return Row(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: showDecimals
              ? _buildValueWithSeparateDecimals(context, formattedValue)
              : Text(
                  formattedValue,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: color ?? Theme.of(context).colorScheme.onSurface,
                        fontSize: valueFontSize,
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

  Widget _buildValueWithSeparateDecimals(BuildContext context, String formattedValue) {
    final parts = formattedValue.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    return RichText(
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      text: TextSpan(
        children: [
          TextSpan(
            text: integerPart,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: color ?? Theme.of(context).colorScheme.onSurface,
                  fontSize: valueFontSize,
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
    );
  }
}
