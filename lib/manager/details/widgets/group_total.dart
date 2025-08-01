import 'package:flutter/material.dart';
import '../../../widgets/currency_display.dart';
import '../../../app_localizations.dart';
import '../../../state/locale_notifier.dart';

class GroupTotal extends StatelessWidget {
  final double total;
  final String currency;
  const GroupTotal({super.key, required this.total, required this.currency});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('group_total'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
        ),
        const SizedBox(height: 2),
        CurrencyDisplay(
          value: total,
          currency: currency,
          valueFontSize: 28.0,
          currencyFontSize: 18.0,
          alignment: MainAxisAlignment.start,
          showDecimals: true,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
