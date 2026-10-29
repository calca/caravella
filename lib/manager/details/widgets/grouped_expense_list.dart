import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import 'expense_day_row.dart';

/// Expenses of a group as a sliver: one card per calendar week (Monday to
/// Sunday, newest first) with the week and, when it has more than one
/// expense, its total above it; each row
/// ([ExpenseDayRow]) shows its day like a calendar. Rows open
/// [onExpenseTap].
class WeekGroupedExpenseSliver extends StatelessWidget {
  final List<ExpenseDetails> expenses;
  final String currency;
  final void Function(ExpenseDetails) onExpenseTap;

  /// An expense just added: its row fades and slides in.
  final String? highlightedExpenseId;

  const WeekGroupedExpenseSliver({
    super.key,
    required this.expenses,
    required this.currency,
    required this.onExpenseTap,
    this.highlightedExpenseId,
  });

  /// Expenses grouped by calendar day, days and expenses newest first.
  static List<(DateTime, List<ExpenseDetails>)> groupByDay(
    List<ExpenseDetails> expenses,
  ) {
    final sorted = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
    final days = <(DateTime, List<ExpenseDetails>)>[];
    for (final e in sorted) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      if (days.isEmpty || days.last.$1 != day) days.add((day, []));
      days.last.$2.add(e);
    }
    return days;
  }

  /// Expenses grouped by week (starting Monday), weeks and expenses newest
  /// first.
  static List<(DateTime, List<ExpenseDetails>)> groupByWeek(
    List<ExpenseDetails> expenses,
  ) {
    final weeks = <(DateTime, List<ExpenseDetails>)>[];
    for (final (day, list) in groupByDay(expenses)) {
      final monday = day.subtract(Duration(days: day.weekday - 1));
      if (weeks.isEmpty || weeks.last.$1 != monday) weeks.add((monday, []));
      weeks.last.$2.addAll(list);
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final weeks = groupByWeek(expenses);
    return SliverList.builder(
      itemCount: weeks.length,
      itemBuilder: (context, i) => _WeekSection(
        weekStart: weeks[i].$1,
        expenses: weeks[i].$2,
        currency: currency,
        onExpenseTap: onExpenseTap,
        highlightedExpenseId: highlightedExpenseId,
      ),
    );
  }
}

class _WeekSection extends StatelessWidget {
  final DateTime weekStart;
  final List<ExpenseDetails> expenses;
  final String currency;
  final void Function(ExpenseDetails) onExpenseTap;
  final String? highlightedExpenseId;

  const _WeekSection({
    required this.weekStart,
    required this.expenses,
    required this.currency,
    required this.onExpenseTap,
    this.highlightedExpenseId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final fmt = DateFormat(
      weekStart.year == now.year && weekEnd.year == now.year
          ? 'd MMM'
          : 'd MMM y',
      locale,
    );
    final label = weekStart == thisMonday
        ? gloc.this_week
        : weekStart == thisMonday.subtract(const Duration(days: 7))
        ? gloc.last_week
        : '${fmt.format(weekStart)} – ${fmt.format(weekEnd)}';
    final total = expenses.fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
    final radius = BorderRadius.circular(20);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      label.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: s.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
                // With one expense the total is that expense's amount,
                // already on its row.
                if (expenses.length > 1)
                  CurrencyDisplay(
                    value: total,
                    currency: currency,
                    valueFontSize: 13,
                    currencyFontSize: 11,
                    showDecimals: true,
                    color: s.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
              ],
            ),
          ),
          CardOutline(
            borderRadius: radius,
            child: Material(
              color: s.raisedSurface,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < expenses.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 62,
                        endIndent: 16,
                        color: s.outlineVariant.withValues(alpha: 0.5),
                      ),
                    _maybeAnimated(
                      expenses[i].id == highlightedExpenseId,
                      ExpenseDayRow(
                        expense: expenses[i],
                        currency: currency,
                        onTap: () => onExpenseTap(expenses[i]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades and slides in a just-added row; other rows as they are.
Widget _maybeAnimated(bool animate, Widget child) => !animate
    ? child
    : TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset((1 - t) * 40, 0),
            child: child,
          ),
        ),
        child: child,
      );
