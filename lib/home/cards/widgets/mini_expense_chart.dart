import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final expenses = _getLast7DaysExpenses();
    final maxExpense =
        expenses.isEmpty ? 1.0 : expenses.reduce((a, b) => a > b ? a : b);
    final normalizedExpenses =
        expenses.map((e) => maxExpense == 0 ? 0.0 : e / maxExpense).toList();

    return SizedBox(
      height: 40,
      child: Row(
        children: List.generate(7, (index) {
          final height = normalizedExpenses[index] * 30 + 4; // Min 4px height
          final isToday = index == 6;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    height: height,
                    decoration: BoxDecoration(
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ['L', 'M', 'M', 'G', 'V', 'S', 'D'][index],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 8,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
