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

  /// Build daily totals for the last 15 days
  /// Returns a list of doubles representing spending per day
  List<double> _buildLast15DaysTotals() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<double> dailyTotals = [];

    for (int i = 14; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayExpenses = group.expenses.where(
        (e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,
      );
      final total = dayExpenses.fold<double>(
        0,
        (sum, e) => sum + (e.amount ?? 0),
      );
      dailyTotals.add(total);
    }

    return dailyTotals;
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
    final todaySpending = _calculateTodaySpending(group);
    final textColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: HomeLayoutConstants.mutedTextAlpha,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // "Oggi:" label
        Text(
          '${localizations.spent_today}:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        // Today's spending value
        CurrencyDisplay(
          value: todaySpending,
          currency: group.currency,
          valueFontSize: 18,
          currencyFontSize: 14,
          alignment: MainAxisAlignment.end,
          showDecimals: true,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildDateRangeStatistics() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bar chart on the left (50% max width)
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Last15DaysBarChart(
              dailyTotals: _buildLast15DaysTotals(),
              theme: theme,
            ),
          ),
        ),
        const SizedBox(width: HomeLayoutConstants.sectionSpacing),
        // Extra info on the right
        Expanded(flex: 1, child: _buildExtraInfo()),
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
