import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/details/pages/tabs/usecase/daily_totals_utils.dart';
import '../../home_constants.dart';

/// Displays statistics and charts for a group card.
///
/// Shows either date-range based statistics (for short trips) or
/// default weekly/monthly charts based on the group's characteristics.
class GroupCardStats extends StatelessWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;

  const GroupCardStats({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
  });

  /// Calculate daily average spending for the group
  double _calculateDailyAverage(ExpenseGroup group) {
    if (group.expenses.isEmpty) return 0.0;

    final now = DateTime.now();
    DateTime startDate, endDate;

    if (group.startDate != null && group.endDate != null) {
      startDate = group.startDate!;
      endDate = group.endDate!.isBefore(now) ? group.endDate! : now;
    } else {
      // If no dates, use first expense to now
      final sortedExpenses = [...group.expenses]
        ..sort((a, b) => a.date.compareTo(b.date));
      startDate = sortedExpenses.first.date;
      endDate = now;
    }

    final days = endDate.difference(startDate).inDays + 1;
    if (days <= 0) return 0.0;

    final totalSpent = group.expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.amount ?? 0),
    );

    return totalSpent / days;
  }

  /// Calculate today's total spending
  double _calculateTodaySpending(ExpenseGroup group) {
    if (group.expenses.isEmpty) return 0.0;
    final now = DateTime.now();
    return group.expenses
        .where(
          (e) =>
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day,
        )
        .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should show date range chart for groups with dates < 1 month
    if (shouldShowDateRangeChart(group)) {
      return _buildDateRangeStatistics();
    }

    // Default behavior: show weekly + monthly charts
    return _buildDefaultStatistics(context);
  }

  Widget _buildExtraInfo() {
    final dailyAverage = _calculateDailyAverage(group);
    final todaySpending = _calculateTodaySpending(group);
    final textColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: HomeLayoutConstants.mutedTextAlpha,
    );

    return Column(
      children: [
        // Daily average
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${localizations.daily_average}: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontSize: 14,
              ),
            ),
            CurrencyDisplay(
              value: dailyAverage,
              currency: group.currency,
              valueFontSize: 14,
              currencyFontSize: 12,
              alignment: MainAxisAlignment.end,
              showDecimals: true,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Today's spending
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${localizations.spent_today}: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontSize: 14,
              ),
            ),
            CurrencyDisplay(
              value: todaySpending,
              currency: group.currency,
              valueFontSize: 14,
              currencyFontSize: 12,
              alignment: MainAxisAlignment.end,
              showDecimals: true,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        const SizedBox(height: HomeLayoutConstants.sectionSpacing),
      ],
    );
  }

  Widget _buildDateRangeStatistics() {
    // Use adaptive method that handles both groups with and without dates
    final dailyTotals = buildAdaptiveDateRangeSeries(group);

    return Column(
      children: [
        // Extra info for short duration trips
        _buildExtraInfo(),
        DateRangeExpenseChart(
          dailyTotals: dailyTotals,
          theme: theme,
          badgeText: localizations.dateRangeChartBadge,
          semanticLabel: localizations.dateRangeExpensesChart,
        ),
      ],
    );
  }

  Widget _buildDefaultStatistics(BuildContext context) {
    // Weekly and monthly series via shared helpers
    final dailyTotals = buildWeeklySeries(group);
    final dailyMonthTotals = buildMonthlySeries(group);
    final gloc = gen.AppLocalizations.of(context);

    // Base statistics
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly chart
        WeeklyExpenseChart(
          dailyTotals: dailyTotals,
          theme: theme,
          badgeText: gloc.weeklyChartBadge,
          semanticLabel: gloc.weeklyExpensesChart,
        ),
        const SizedBox(height: HomeLayoutConstants.sectionSpacing),
        // Monthly chart
        MonthlyExpenseChart(
          dailyTotals: dailyMonthTotals,
          theme: theme,
          badgeText: gloc.monthlyChartBadge,
          semanticLabel: gloc.monthlyExpensesChart,
        ),
      ],
    );
  }
}

/// Displays the total amount spent in a group.
class GroupCardTotalAmount extends StatelessWidget {
  final ExpenseGroup group;
  final ThemeData theme;

  const GroupCardTotalAmount({
    super.key,
    required this.group,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = gen.AppLocalizations.of(context);
    final totalExpenses = group.expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.amount ?? 0),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Semantics(
          label: localizations.accessibility_total_expenses(
            CurrencyDisplay.formatCurrencyText(totalExpenses, '€'),
          ),
          child: CurrencyDisplay(
            value: totalExpenses,
            currency: '€',
            valueFontSize: HomeLayoutConstants.cardTotalFontSize,
            currencyFontSize: HomeLayoutConstants.cardCurrencyFontSize,
            alignment: MainAxisAlignment.end,
            showDecimals: true,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
