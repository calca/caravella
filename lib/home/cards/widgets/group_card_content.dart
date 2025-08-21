import 'weekly_expense_chart.dart';
import 'monthly_expense_chart.dart';
import 'date_range_expense_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../state/expense_group_notifier.dart';
import '../../../data/expense_group.dart';
import '../../../manager/details/widgets/expense_entry_sheet.dart';
import '../../../widgets/currency_display.dart';
import '../../../manager/details/tabs/overview_stats_logic.dart';

class GroupCardContent extends StatelessWidget {
  // Design constants
  static const double _titleFontSize = 28.0;
  static const double _totalFontSize = 52.0;
  static const double _currencyFontSize = 32.0;
  static const double _buttonVerticalPadding = 12.0;
  static const double _borderRadius = 12.0;
  static const double _iconSize = 20.0;
  static const double _spacing = 8.0;
  static const double _largSpacing = 24.0;

  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onExpenseAdded;
  final VoidCallback? onCategoryAdded;

  const GroupCardContent({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
    required this.onExpenseAdded,
    this.onCategoryAdded,
  });

  String _formatDateRange(ExpenseGroup group, gen.AppLocalizations loc) {
    final start = group.startDate;
    final end = group.endDate;

    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    } else if (start != null) {
      return 'Dal ${_formatDate(start)}';
    } else if (end != null) {
      return 'Fino al ${_formatDate(end)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    final currentYear = DateTime.now().year;
    if (date.year == currentYear) {
      return '${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddExpenseSheet(BuildContext context, ExpenseGroup currentGroup) {
    // Salva il riferimento al notifier
    final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
    notifier.setCurrentGroup(currentGroup);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer<ExpenseGroupNotifier>(
        builder: (context, groupNotifier, child) {
          final currentGroup = groupNotifier.currentGroup ?? group;
          return ExpenseEntrySheet(
            group: currentGroup,
            onExpenseSaved: (expense) async {
              await groupNotifier.addExpense(expense);
              onExpenseAdded();
            },
            onCategoryAdded: (newCategory) async {
              await groupNotifier.addCategory(newCategory);
            },
            fullEdit: false,
          );
        },
      ),
    ).whenComplete(() {
      // Pulisci il notifier quando il dialog si chiude
      notifier.clearCurrentGroup();
    });
  }

  // Computed properties memoizzate per performance
  double get totalExpenses => group.expenses.fold<double>(
    0,
    (sum, expense) => sum + (expense.amount ?? 0),
  );

  int get participantCount => group.participants.length;

  double get recentExpensesTotal => group.expenses
      .where(
        (e) => e.date.isAfter(DateTime.now().subtract(const Duration(days: 7))),
      )
      .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseGroupNotifier>(
      builder: (context, groupNotifier, child) {
        // Se questo gruppo è stato aggiornato, usa i dati dal notifier
        final currentGroup = (groupNotifier.currentGroup?.id == group.id)
            ? groupNotifier.currentGroup!
            : group;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(currentGroup),
            _buildDateRange(currentGroup),
            _buildTotalAmount(context, currentGroup),
            const SizedBox(height: _largSpacing),
            const Spacer(),
            _buildStatistics(currentGroup),
            const SizedBox(height: 24),
            _buildAddButton(context, currentGroup),
          ],
        );
      },
    );
  }

  Widget _buildHeader(ExpenseGroup currentGroup) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            currentGroup.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: _titleFontSize,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (currentGroup.pinned)
          Icon(
            Icons.push_pin_outlined,
            size: _iconSize,
            color: theme.colorScheme.onSurface,
          ),
      ],
    );
  }

  Widget _buildDateRange(ExpenseGroup currentGroup) {
    if (currentGroup.startDate == null && currentGroup.endDate == null) {
      return const SizedBox(height: _spacing);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _spacing),
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 8,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDateRange(currentGroup, localizations),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: _spacing),
      ],
    );
  }

  Widget _buildTotalAmount(BuildContext context, ExpenseGroup currentGroup) {
    final localizations = gen.AppLocalizations.of(context);
    final totalExpenses = currentGroup.expenses.fold<double>(
      0,
      (sum, expense) => sum + (expense.amount ?? 0),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Semantics(
          label: localizations.accessibility_total_expenses(
            totalExpenses.toStringAsFixed(2),
          ),
          child: CurrencyDisplay(
            value: totalExpenses,
            currency: '€',
            valueFontSize: _totalFontSize,
            currencyFontSize: _currencyFontSize,
            alignment: MainAxisAlignment.end,
            showDecimals: true,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

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
    final today = DateTime.now();
    return group.expenses
        .where(
          (e) =>
              e.date.year == today.year &&
              e.date.month == today.month &&
              e.date.day == today.day,
        )
        .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
  }

  Widget _buildExtraInfo(ExpenseGroup group) {
    final dailyAverage = _calculateDailyAverage(group);
    final todaySpending = _calculateTodaySpending(group);
    final textColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatistics(ExpenseGroup currentGroup) {
    // Check if we should show date range chart for groups with dates < 1 month
    if (shouldShowDateRangeChart(currentGroup)) {
      return _buildDateRangeStatistics(currentGroup);
    }

    // Default behavior: show weekly + monthly charts
    return _buildDefaultStatistics(currentGroup);
  }

  Widget _buildDateRangeStatistics(ExpenseGroup currentGroup) {
    final startDate = currentGroup.startDate!;
    final endDate = currentGroup.endDate!;
    final duration = endDate.difference(startDate).inDays + 1; // inclusive

    // Calculate daily totals for each day in the date range
    final dailyTotals = List<double>.generate(duration, (i) {
      final day = startDate.add(Duration(days: i));
      return currentGroup.expenses
          .where(
            (e) =>
                e.date.year == day.year &&
                e.date.month == day.month &&
                e.date.day == day.day,
          )
          .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
    });

    return Column(
      children: [
        // Extra info for short duration trips
        _buildExtraInfo(currentGroup),
        DateRangeExpenseChart(dailyTotals: dailyTotals, theme: theme),
      ],
    );
  }

  Widget _buildDefaultStatistics(ExpenseGroup currentGroup) {
    final now = DateTime.now();
    // Calcola il lunedì della settimana corrente
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Genera i 7 giorni da lunedì a domenica
    final dailyTotals = List<double>.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      return currentGroup.expenses
          .where(
            (e) =>
                e.date.year == day.year &&
                e.date.month == day.month &&
                e.date.day == day.day,
          )
          .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
    });
    // weeklyTotal non più usato

    // Spesa per ogni giorno del mese corrente
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startOfMonth = DateTime(now.year, now.month, 1);
    final dailyMonthTotals = List<double>.generate(daysInMonth, (i) {
      final day = startOfMonth.add(Duration(days: i));
      return currentGroup.expenses
          .where(
            (e) =>
                e.date.year == day.year &&
                e.date.month == day.month &&
                e.date.day == day.day,
          )
          .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
    });
    // monthlyTotal non più usato

    // Statistiche base
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Settimana
        WeeklyExpenseChart(dailyTotals: dailyTotals, theme: theme),
        const SizedBox(height: 16),
        // Mese
        MonthlyExpenseChart(dailyTotals: dailyMonthTotals, theme: theme),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, ExpenseGroup currentGroup) {
    final localizations = gen.AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        label: localizations.accessibility_add_expense,
        child: TextButton(
          onPressed: () => _showAddExpenseSheet(context, currentGroup),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            backgroundColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.05,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: _buttonVerticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
          child: Icon(
            Icons.add,
            size: _iconSize + 2,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
