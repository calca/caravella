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
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              barWidth: 2,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.18),
              ),
            ),
          ],
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
