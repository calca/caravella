import 'package:flutter/material.dart';
import '../../../widgets/currency_display.dart';

class GroupTotal extends StatelessWidget {
  final double total;
  final String currency;
  const GroupTotal({super.key, required this.total, required this.currency});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Totale',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontSize: 20,
              ),
        ),
        const SizedBox(height: 4),
        CurrencyDisplay(
          value: total,
          currency: currency,
          valueFontSize: 22.0,
          currencyFontSize: 18.0,
          alignment: MainAxisAlignment.start,
          showDecimals: true,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.normal,
        ),
      ],
    );
  }
}
