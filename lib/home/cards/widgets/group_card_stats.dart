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
class GroupCardStats extends StatefulWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;

  const GroupCardStats({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
  });

  @override
  State<GroupCardStats> createState() => _GroupCardStatsState();
}

class _GroupCardStatsState extends State<GroupCardStats> {
  double _todaySpending = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTodaySpending();
  }

  @override
  void didUpdateWidget(GroupCardStats oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.id != widget.group.id ||
        oldWidget.group.expenses.length != widget.group.expenses.length) {
      _loadTodaySpending();
    }
  }

  Future<void> _loadTodaySpending() async {
    final spending = await ExpenseGroupStorageV2.getTodaySpending(
      widget.group.id,
    );
    if (mounted) {
      setState(() {
        _todaySpending = spending;
      });
    }
  }

  /// Build daily totals for the last 15 days via shared utility.
  List<double> _buildLast15DaysTotals() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 14));
    return calculateDailyTotalsOptimized(widget.group, start, 15);
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should show date range chart for groups with dates < 1 month
    if (shouldShowDateRangeChart(widget.group)) {
      return _buildDateRangeStatistics();
    }

    // Default behavior: show weekly + monthly charts
    return _buildDefaultStatistics(context);
  }

  Widget _buildExtraInfo() {
    final textColor = widget.theme.colorScheme.onSurfaceVariant.withValues(
      alpha: HomeLayoutConstants.mutedTextAlpha,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // "Oggi:" label
        Text(
          '${widget.localizations.spent_today}:',
          style: widget.theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        // Today's spending value
        CurrencyDisplay(
          value: _todaySpending,
          currency: widget.group.currency,
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Extra info on the right
        Expanded(flex: 0, child: _buildExtraInfo()),
        const SizedBox(width: HomeLayoutConstants.sectionSpacing),
        // Bar chart on the left (50% max width)
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Last15DaysBarChart(
              dailyTotals: _buildLast15DaysTotals(),
              theme: widget.theme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultStatistics(BuildContext context) {
    // Weekly and monthly series via shared helpers
    final dailyTotals = buildWeeklySeries(widget.group);
    final dailyMonthTotals = buildMonthlySeries(widget.group);
    final gloc = gen.AppLocalizations.of(context);

    // Base statistics
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly chart
        WeeklyExpenseChart(
          dailyTotals: dailyTotals,
          theme: widget.theme,
          badgeText: gloc.weeklyChartBadge,
          semanticLabel: gloc.weeklyExpensesChart,
        ),
        const SizedBox(height: HomeLayoutConstants.sectionSpacing),
        // Monthly chart
        MonthlyExpenseChart(
          dailyTotals: dailyMonthTotals,
          theme: widget.theme,
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
    final totalExpenses = group.getTotalExpenses();

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
