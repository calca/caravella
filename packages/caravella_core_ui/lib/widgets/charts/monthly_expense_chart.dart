import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_badge.dart';
import 'chart_type.dart';

class MonthlyExpenseChart extends StatelessWidget {
  final List<double> dailyTotals;
  final ThemeData theme;
  final String badgeText;
  final String semanticLabel;

  const MonthlyExpenseChart({
    super.key,
    required this.dailyTotals,
    required this.theme,
    required this.badgeText,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasExpenses = dailyTotals.any((v) => v > 0);
    if (!hasExpenses) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildChart()),
        const SizedBox(width: 12),
        ChartBadge(
          chartType: ChartType.monthly,
          theme: theme,
          badgeText: badgeText,
          semanticLabel: semanticLabel,
        ),
      ],
    );
  }

  Widget _buildChart() {
    final spots = List.generate(
      dailyTotals.length,
      (i) => FlSpot(i.toDouble(), dailyTotals[i]),
    );
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
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
          ],
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
