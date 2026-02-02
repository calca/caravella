import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

class GroupTotal extends StatelessWidget {
  final double total;
  final String currency;
  final String? title;
  final CrossAxisAlignment alignment;
  const GroupTotal({
    super.key,
    required this.total,
    required this.currency,
    this.title,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final displayTitle = title ?? gloc.group_total;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          displayTitle,
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
          alignment: alignment == CrossAxisAlignment.center
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          showDecimals: true,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
