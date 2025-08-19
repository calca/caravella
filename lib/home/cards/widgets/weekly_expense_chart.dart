import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
          lineTouchData: const LineTouchData(
            enabled: false,
          ),
        ),
      ),
    );
  }
}
