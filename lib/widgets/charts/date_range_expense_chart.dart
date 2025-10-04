import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DateRangeExpenseChart extends StatelessWidget {
  final List<double> dailyTotals;
  final ThemeData theme;

  const DateRangeExpenseChart({
    super.key,
    required this.dailyTotals,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // We now always render the chart space even if all values are zero so that
    // the date range statistics section is visible when a date range is set.
    // Previously this returned SizedBox.shrink() which hid the whole section.
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
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.25),
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(
                  0.12,
                ),
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
