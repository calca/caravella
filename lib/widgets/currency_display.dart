import 'package:flutter/material.dart';

class CurrencyDisplay extends StatelessWidget {
  final double value;
  final String currency;
  final double valueFontSize;
  final double currencyFontSize;

  const CurrencyDisplay({
    super.key,
    required this.value,
    required this.currency,
    this.valueFontSize = 54.0,
    this.currencyFontSize = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value.truncate().toString(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: valueFontSize,
              ),
        ),
        const SizedBox(width: 4),
        Text(
          currency,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: currencyFontSize,
              ),
        ),
      ],
    );
  }
}
