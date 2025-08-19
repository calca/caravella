import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app_localizations.dart';
import 'chart_type.dart';

class WeeklyExpenseChart extends StatelessWidget {
  final List<double> dailyTotals;
  final ThemeData theme;

  const WeeklyExpenseChart({
    super.key,
    required this.dailyTotals,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hasExpenses = dailyTotals.any((v) => v > 0);
    if (!hasExpenses) {
      return const SizedBox.shrink();
    }
    
    final localizations = AppLocalizations.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildChartBadge(localizations),
        const SizedBox(width: 12),
        Expanded(child: _buildChart()),
      ],
    );
  }
  
  Widget _buildChartBadge(AppLocalizations localizations) {
    const chartType = ChartType.weekly;
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
  
  Widget _buildChart() {
    final spots = List.generate(7, (i) => FlSpot(i.toDouble(), dailyTotals[i]));
    return SizedBox(
      height: 40,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
              ),
            ),
          ],
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
