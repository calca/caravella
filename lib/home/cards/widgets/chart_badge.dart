import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import 'chart_type.dart';

class ChartBadge extends StatelessWidget {
  final ChartType chartType;
  final ThemeData theme;

  const ChartBadge({
    super.key,
    required this.chartType,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final letter = localizations.get(chartType.getBadgeKey());
    final color = theme.colorScheme.onSurfaceVariant;
    final semanticLabel = localizations.get(chartType.getSemanticLabelKey());
    
    return Semantics(
      label: semanticLabel,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
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