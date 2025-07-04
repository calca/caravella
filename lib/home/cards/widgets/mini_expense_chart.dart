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
    final maxExpense = expenses.isEmpty ? 1.0 : expenses.reduce((a, b) => a > b ? a : b);
    final dailyAverage = _calculateDailyAverage();
    
    return SizedBox(
      height: 40,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxExpense == 0 ? 1 : maxExpense,
          minY: 0,
          groupsSpace: 4,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    final day = days[value.toInt()];
                    return Text(
                      day.day.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 8,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 16,
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          // Linea della media usando extraLinesData
          extraLinesData: dailyAverage > 0
              ? ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: dailyAverage,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      strokeWidth: 1.5,
                      dashArray: [4, 4],
                    ),
                  ],
                )
              : null,
          barGroups: List.generate(7, (index) {
            final isToday = index == 6;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: expenses[index],
                  color: isToday
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  width: 8,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
