import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Expenses of a group as a sliver: one card per day (newest first), with
/// the day and its total above it. Rows open [onExpenseTap].
class DayGroupedExpenseSliver extends StatelessWidget {
  final List<ExpenseDetails> expenses;
  final String currency;
  final void Function(ExpenseDetails) onExpenseTap;

  /// An expense just added: its row fades and slides in.
  final String? highlightedExpenseId;

  const DayGroupedExpenseSliver({
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

  @override
  Widget build(BuildContext context) {
    final days = groupByDay(expenses);
    return SliverList.builder(
      itemCount: days.length,
      itemBuilder: (context, i) => _DaySection(
        day: days[i].$1,
        expenses: days[i].$2,
        currency: currency,
        onExpenseTap: onExpenseTap,
        highlightedExpenseId: highlightedExpenseId,
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<ExpenseDetails> expenses;
  final String currency;
  final void Function(ExpenseDetails) onExpenseTap;
  final String? highlightedExpenseId;

  const _DaySection({
    required this.day,
    required this.expenses,
    required this.currency,
    required this.onExpenseTap,
    this.highlightedExpenseId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final label = DateFormat(
      day.year == now.year ? 'EEE d MMM' : 'EEE d MMM y',
      locale,
    ).format(day);
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
                        indent: 16,
                        endIndent: 16,
                        color: s.outlineVariant.withValues(alpha: 0.5),
                      ),
                    _maybeAnimated(
                      expenses[i].id == highlightedExpenseId,
                      ExpenseAmountCard(
                        title: expenses[i].name ?? '',
                        amount: expenses[i].amount ?? 0,
                        checked: true,
                        paidBy: expenses[i].paidBy,
                        category: expenses[i].category.name,
                        date: expenses[i].date,
                        showDate: false,
                        compact: true,
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
