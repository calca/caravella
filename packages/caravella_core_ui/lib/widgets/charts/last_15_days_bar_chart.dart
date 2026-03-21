import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// A bar chart showing spending for the last 15 days.
///
/// The current day (last bar) is displayed in dark gray while
/// other days are shown in light gray.
class Last15DaysBarChart extends StatelessWidget {
  /// List of 15 daily totals, from oldest to newest (today is last)
  final List<double> dailyTotals;
  final ThemeData theme;

  const Last15DaysBarChart({
    super.key,
    required this.dailyTotals,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Find max value for scaling
    final maxValue = dailyTotals.fold<double>(
      0,
      (max, total) => total > max ? total : max,
    );

    final darkGray = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.8,
    );
    final lightGray = theme.colorScheme.surfaceContainer.withValues(alpha: 0.6);

    // Today is the last index (14)
    const todayIndex = 14;

    return SizedBox(
      height: 60,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue > 0 ? maxValue * 1.1 : 10,
          minY: 0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: dailyTotals.asMap().entries.map((entry) {
            final index = entry.key;
            final total = entry.value;
            final isToday = index == todayIndex;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: total > 0 ? total : 0.5, // Min height for visibility
                  color: isToday ? darkGray : lightGray,
                  width: 6,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        duration: Duration.zero,
      ),
    );
  }
}
