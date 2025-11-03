import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'chart_type.dart';

class ChartBadge extends StatelessWidget {
  final ChartType chartType;
  final ThemeData theme;

  const ChartBadge({super.key, required this.chartType, required this.theme});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // Direct getters from generated localization based on enum
    final letter = switch (chartType) {
      ChartType.weekly => localizations.weeklyChartBadge,
      ChartType.monthly => localizations.monthlyChartBadge,
    };
    final color = theme.colorScheme.onSurfaceVariant;
    final semanticLabel = switch (chartType) {
      ChartType.weekly => localizations.weeklyExpensesChart,
      ChartType.monthly => localizations.monthlyExpensesChart,
    };

    return Semantics(
      label: semanticLabel,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            letter,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: color,
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
