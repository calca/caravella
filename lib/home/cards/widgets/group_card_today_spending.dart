import 'package:flutter/material.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Widget that displays today's spending in a badge format.
class GroupCardTodaySpending extends StatelessWidget {
  final double todaySpending;
  final String currency;
  final ThemeData theme;
  final gen.AppLocalizations localizations;

  const GroupCardTodaySpending({
    super.key,
    required this.todaySpending,
    required this.currency,
    required this.theme,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final backgroundColor = colorScheme.surfaceContainerLow;
    final textColor = colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          CurrencyDisplay(
            value: todaySpending.abs(),
            currency: currency,
            valueFontSize: 16,
            currencyFontSize: 12,
            alignment: MainAxisAlignment.start,
            showDecimals: true,
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(width: 8),
          Text(
            localizations.spent_today.toLowerCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
