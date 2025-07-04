import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/expense_group.dart';

class MiniExpenseChart extends StatelessWidget {
  final ExpenseGroup group;
  final ThemeData theme;

  const MiniExpenseChart({
    super.key,
    required this.group,
    required this.theme,
  });

  List<double> _getLast7DaysExpenses() {
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    return last7Days.map((day) {
      final dayExpenses = group.expenses.where((expense) {
        final expenseDate = expense.date;
        return expenseDate.year == day.year &&
            expenseDate.month == day.month &&
            expenseDate.day == day.day;
      });

      return dayExpenses.fold<double>(
          0, (sum, expense) => sum + (expense.amount ?? 0));
    }).toList();
  }

  List<DateTime> _getLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });
  }

  double _calculateDailyAverage() {
    final expenses = _getLast7DaysExpenses();
    if (expenses.isEmpty) return 0.0;
    final total = expenses.fold<double>(0, (sum, expense) => sum + expense);
    return total / expenses.length;
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _getLast7DaysExpenses();
    final days = _getLast7Days();
    final maxExpense =
        expenses.isEmpty ? 1.0 : expenses.reduce((a, b) => a > b ? a : b);
    final dailyAverage = _calculateDailyAverage();

    return Container(
      height: 90, // Increased height for better visibility
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxExpense == 0
              ? 1
              : maxExpense * 1.15, // More padding for better proportions
          minY: 0,
          groupsSpace: 12, // More space between bars
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => theme.colorScheme.surface.withValues(alpha: 0.95),
              tooltipBorder: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                width: 1,
              ),
              tooltipMargin: 8,
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = days[groupIndex];
                final amount = expenses[groupIndex];
                return BarTooltipItem(
                  '${day.day}/${day.month}\n',
                  theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: '€${amount.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    final day = days[value.toInt()];
                    final isToday = value.toInt() == 6;
                    final isYesterday = value.toInt() == 5;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: isToday
                            ? BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4),
                              )
                            : null,
                        child: Text(
                          day.day.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.w500,
                            color: isToday
                                ? theme.colorScheme.primary
                                : isYesterday
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 28,
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          // Linea della media più flat
          extraLinesData: dailyAverage > 0
              ? ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: dailyAverage,
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      strokeWidth: 2,
                      dashArray: [6, 4],
                    ),
                  ],
                )
              : null,
          barGroups: List.generate(7, (index) {
            final isToday = index == 6;
            final isYesterday = index == 5;
            final expense = expenses[index];
            final isAboveAverage = expense > dailyAverage && dailyAverage > 0;
            final isHighValue = expense > (maxExpense * 0.7);

            // Colori ancora più flat e subtili
            Color getBarColor() {
              if (isToday) return theme.colorScheme.primary.withValues(alpha: 0.6);
              if (isHighValue) return theme.colorScheme.secondary.withValues(alpha: 0.5);
              if (isAboveAverage) return theme.colorScheme.tertiary.withValues(alpha: 0.5);
              return theme.colorScheme.onSurface.withValues(alpha: 0.25);
            }

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: expense,
                  color: getBarColor(),
                  width: isToday ? 14 : (isYesterday ? 13 : 12),
                  borderRadius: BorderRadius.circular(isToday ? 8 : 6),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxExpense * 1.15,
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.05),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
