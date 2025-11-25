import 'package:flutter/material.dart';
import 'chart_type.dart';

class ChartBadge extends StatelessWidget {
  final ChartType chartType;
  final ThemeData theme;
  final String badgeText;
  final String semanticLabel;

  const ChartBadge({
    super.key,
    required this.chartType,
    required this.theme,
    required this.badgeText,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = theme.colorScheme.onSurfaceVariant;

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
            badgeText,
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
