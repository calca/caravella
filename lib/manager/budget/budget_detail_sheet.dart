import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../details/pages/tabs/usecase/date_range_formatter.dart';
import 'budget_settings_sheet.dart';

/// Weeks start as in the user's language (Monday, Sunday, …), as
/// [DateTime.monday] to [DateTime.sunday].
int firstDayOfWeekOf(BuildContext context) {
  final index = MaterialLocalizations.of(context).firstDayOfWeekIndex;
  return index == 0 ? DateTime.sunday : index;
}

/// The budget sheet opened from "Today" on the group page: today at the
/// top, the current period under it, the periods before, and "Change
/// budget" ([onChangeBudget], after the sheet closes).
Future<void> showBudgetDetailSheet(
  BuildContext context, {
  required ExpenseGroup group,
  required VoidCallback onChangeBudget,
}) async {
  final change = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BudgetDetailSheet(group: group),
  );
  if (change == true) onChangeBudget();
}

class BudgetDetailSheet extends StatelessWidget {
  final ExpenseGroup group;

  /// "Today" for the figures; now when null (tests set it).
  final DateTime? today;

  const BudgetDetailSheet({super.key, required this.group, this.today});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final status = BudgetStatus.of(
      group,
      today: today,
      firstDayOfWeek: firstDayOfWeekOf(context),
    );
    if (status == null) return const SizedBox.shrink();
    String money(double v) =>
        CurrencyDisplay.formatLocalizedText(v, group.currency, locale);
    final budget = status.budget;
    final small = theme.textTheme.bodySmall?.copyWith(color: s.outline);
    final caps = theme.textTheme.labelSmall?.copyWith(
      color: s.outline,
      letterSpacing: 0.7,
    );

    final periodName = switch (budget.period) {
      BudgetPeriod.total => gloc.budget_period_total,
      BudgetPeriod.monthly => DateFormat.MMMM(
        locale.toString(),
      ).format(status.start!),
      BudgetPeriod.weekly => formatDateRange(
        start: status.start,
        end: status.end,
        locale: locale,
      ),
      BudgetPeriod.daily => gloc.today,
    };
    final spentPercent = (status.spent / budget.amount * 100).round();
    final elapsed = switch ((status.dayNumber, status.dayCount)) {
      (final d?, final c?) => d / c,
      _ => null,
    };
    final overPeriod = status.spent > budget.amount;

    return CaravellaBottomSheetScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Today(status: status, currency: group.currency, money: money),
          if (budget.period == BudgetPeriod.total &&
              (group.startDate == null || group.endDate == null)) ...[
            const SizedBox(height: 8),
            Text(gloc.budget_set_dates_hint, style: small),
          ],
          if (budget.period != BudgetPeriod.daily) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    gloc.budget_header(periodName).toUpperCase(),
                    style: caps,
                  ),
                ),
                Text(
                  budget.period == BudgetPeriod.total
                      ? money(budget.amount)
                      : '${money(budget.amount)} · '
                            '${budgetPeriodName(gloc, budget.period)}',
                  style: small,
                ),
              ],
            ),
            const SizedBox(height: 6),
            _Figure(
              value: overPeriod ? status.overBy : status.remaining,
              currency: group.currency,
              size: 26,
              after: overPeriod ? gloc.budget_over : gloc.budget_left,
              color: overPeriod ? s.onBudgetOver : null,
            ),
            const SizedBox(height: 10),
            Semantics(
              label: gloc.budget_bar_semantics(
                spentPercent,
                ((elapsed ?? 0) * 100).round(),
              ),
              child: BudgetBar(
                fraction: status.spent / budget.amount,
                over: overPeriod,
                marker: elapsed,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    gloc.budget_spent_percent(
                      money(status.spent),
                      spentPercent,
                    ),
                    style: small,
                  ),
                ),
                if (status.dayNumber != null && status.dayCount != null)
                  Text(
                    gloc.budget_day_of(status.dayNumber!, status.dayCount!),
                    style: small,
                  ),
              ],
            ),
            if (status.todayShare != null) ...[
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Box(
                        label: gloc.budget_per_day_until(
                          DateFormat.MMMd(
                            locale.toString(),
                          ).format(status.end!),
                        ),
                        value: status.todayShare!,
                        currency: group.currency,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Box(
                        label: gloc.budget_average_so_far,
                        value: status.averagePerDay!,
                        currency: group.currency,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          if (status.pastPeriods.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Text(
              switch (budget.period) {
                BudgetPeriod.monthly => gloc.budget_past_months,
                BudgetPeriod.weekly => gloc.budget_past_weeks,
                _ => gloc.budget_past_days,
              }.toUpperCase(),
              style: caps,
            ),
            const SizedBox(height: 12),
            _PastTable(
              periods: status.pastPeriods,
              labelOf: (p) => switch (budget.period) {
                BudgetPeriod.monthly => toBeginningOfSentenceCase(
                  DateFormat.MMMM(locale.toString()).format(p.start),
                  locale.toString(),
                ),
                BudgetPeriod.weekly => formatDateRange(
                  start: p.start,
                  end: p.end,
                  locale: locale,
                ),
                _ => toBeginningOfSentenceCase(
                  DateFormat.MMMEd(locale.toString()).format(p.start),
                  locale.toString(),
                ),
              },
              amount: budget.amount,
              currency: group.currency,
              money: money,
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: const StadiumBorder(),
            ),
            child: Text(gloc.budget_change),
          ),
        ],
      ),
    );
  }
}

/// Today: the big ring, what's left of today's share (or how far over it)
/// and what was spent of it.
class _Today extends StatelessWidget {
  final BudgetStatus status;
  final String currency;
  final String Function(double) money;

  const _Today({
    required this.status,
    required this.currency,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final share = status.todayShare;
    final left = status.remainingToday;
    return MergeSemantics(
      child: Row(
        children: [
          if (status.todayFraction case final f?) ...[
            BudgetRing(
              fraction: f,
              over: status.overToday,
              size: 56,
              strokeWidth: 6,
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gloc.today.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: s.outline,
                    letterSpacing: 0.7,
                  ),
                ),
                if (share != null && left != null) ...[
                  _Figure(
                    value: left.abs(),
                    currency: currency,
                    size: 22,
                    after: status.overToday
                        ? gloc.budget_over_today
                        : gloc.budget_left_today,
                    color: status.overToday ? s.onBudgetOver : null,
                  ),
                  Text(
                    gloc.budget_spent_of_share(
                      money(status.spentToday),
                      money(share),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: s.outline,
                    ),
                  ),
                ] else
                  _Figure(
                    value: status.spentToday,
                    currency: currency,
                    size: 22,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final String label;
  final double value;
  final String currency;

  const _Box({
    required this.label,
    required this.value,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: s.raisedSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: s.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            _Figure(value: value, currency: currency, size: 18),
          ],
        ),
      ),
    );
  }
}

/// The periods before, one row each: name, a bar on the budget's scale
/// and what it spent (in amber, with how much over under it, when it went
/// over). A table, so the bars line up whatever the amounts.
class _PastTable extends StatelessWidget {
  final List<BudgetPastPeriod> periods;
  final String Function(BudgetPastPeriod) labelOf;
  final double amount;
  final String currency;
  final String Function(double) money;

  const _PastTable({
    required this.periods,
    required this.labelOf,
    required this.amount,
    required this.currency,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    TableRow row(BudgetPastPeriod p) {
      final label = labelOf(p);
      final over = p.spent > amount;
      Widget cell(Widget child) => Semantics(
        label: gloc.budget_past_semantics(label, money(p.spent), money(amount)),
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: child,
        ),
      );
      return TableRow(
        children: [
          cell(Text(label, style: theme.textTheme.bodyMedium)),
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: BudgetBar(
                fraction: p.spent / amount,
                over: over,
                height: 8,
              ),
            ),
          ),
          ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CurrencyDisplay(
                  value: p.spent,
                  currency: currency,
                  valueFontSize: 15,
                  currencyFontSize: 11,
                  showDecimals: true,
                  color: over ? s.onBudgetOver : null,
                ),
                if (over)
                  Text(
                    gloc.budget_over_by(money(p.spent - amount)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: s.onBudgetOver,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [for (final p in periods) row(p)],
    );
  }
}

/// An amount in the app's style ([CurrencyDisplay]: decimals and currency
/// smaller), optionally followed by a few words ("left", "over budget").
class _Figure extends StatelessWidget {
  final double value;
  final String currency;
  final double size;
  final String? after;
  final Color? color;

  const _Figure({
    required this.value,
    required this.currency,
    required this.size,
    this.after,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        CurrencyDisplay(
          value: value,
          currency: currency,
          valueFontSize: size,
          currencyFontSize: (size * 0.55).roundToDouble(),
          showDecimals: true,
          alignment: MainAxisAlignment.start,
          color: color,
        ),
        if (after case final words?)
          Padding(
            padding: EdgeInsets.only(bottom: size * 0.08),
            child: Text(
              words,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: color ?? theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
