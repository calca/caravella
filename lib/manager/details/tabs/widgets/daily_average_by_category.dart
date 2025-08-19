import 'package:flutter/material.dart';
import '../../../../data/expense_group.dart';
import '../../../../data/expense_category.dart';
import '../../../../app_localizations.dart';
import '../../../../widgets/currency_display.dart';

class DailyAverageByCategoryWidget extends StatelessWidget {
  final ExpenseGroup trip;
  final AppLocalizations loc;

  const DailyAverageByCategoryWidget({
    super.key,
    required this.trip,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final averages = _calculateDailyAveragesByCategory();
    
    if (averages.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by average value descending
    final sortedEntries = averages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('daily_average_by_category'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        ...sortedEntries.map((entry) => _buildCategoryRow(context, entry)),
      ],
    );
  }

  Widget _buildCategoryRow(BuildContext context, MapEntry<ExpenseCategory, double> entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              entry.key.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CurrencyDisplay(
                  value: entry.value,
                  currency: trip.currency,
                  valueFontSize: 14,
                  currencyFontSize: 12,
                  showDecimals: true,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                Text(
                  loc.get('per_day'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<ExpenseCategory, double> _calculateDailyAveragesByCategory() {
    if (trip.expenses.isEmpty) {
      return {};
    }

    // Calculate the date range according to the requirements
    final dateRange = _calculateDateRange();
    final totalDays = dateRange.end.difference(dateRange.start).inDays + 1;

    if (totalDays <= 0) {
      return {};
    }

    final Map<ExpenseCategory, double> categoryTotals = {};
    
    // Calculate totals for known categories
    for (final category in trip.categories) {
      final total = trip.expenses
          .where((e) => e.category.id == category.id)
          .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
      if (total > 0) {
        categoryTotals[category] = total / totalDays;
      }
    }

    // Add uncategorized expenses (expenses with categories not in the trip's categories list)
    final uncategorizedTotal = trip.expenses
        .where((e) => !trip.categories.any((c) => c.id == e.category.id))
        .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));

    if (uncategorizedTotal > 0) {
      // Create a placeholder category for uncategorized expenses
      final uncategorized = ExpenseCategory(
        name: loc.get('uncategorized'),
        id: 'uncategorized',
        createdAt: DateTime(2000),
      );
      categoryTotals[uncategorized] = uncategorizedTotal / totalDays;
    }

    return categoryTotals;
  }

  ({DateTime start, DateTime end}) _calculateDateRange() {
    final now = DateTime.now();
    
    // If the group has no dates, use first expense date to current date
    if (trip.startDate == null || trip.endDate == null) {
      if (trip.expenses.isEmpty) {
        // If no expenses and no dates, use current month
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0);
        return (start: firstDay, end: lastDay);
      }
      
      // Find the first expense date
      final sortedExpenses = [...trip.expenses]
        ..sort((a, b) => a.date.compareTo(b.date));
      final firstExpenseDate = sortedExpenses.first.date;
      
      return (
        start: DateTime(firstExpenseDate.year, firstExpenseDate.month, firstExpenseDate.day),
        end: DateTime(now.year, now.month, now.day)
      );
    }
    
    // If group has dates, use start date to min(end date, current date)
    final startDate = DateTime(trip.startDate!.year, trip.startDate!.month, trip.startDate!.day);
    final endDate = DateTime(trip.endDate!.year, trip.endDate!.month, trip.endDate!.day);
    final currentDate = DateTime(now.year, now.month, now.day);
    
    final effectiveEndDate = endDate.isBefore(currentDate) ? endDate : currentDate;
    
    return (start: startDate, end: effectiveEndDate);
  }
}