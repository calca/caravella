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
/// budget", which opens the budget's settings inside the same sheet
/// ([SheetPager]). A saved change goes to [onBudgetResult] and the sheet
/// shows the new budget; a removed one closes the sheet.
Future<void> showBudgetDetailSheet(
  BuildContext context, {
  required ExpenseGroup group,
  required Future<void> Function(BudgetSheetResult result) onBudgetResult,
}) => showAppBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => SheetPager(
    child: _BudgetDetailHost(group: group, onBudgetResult: onBudgetResult),
  ),
);

class _BudgetDetailHost extends StatefulWidget {
  final ExpenseGroup group;
  final Future<void> Function(BudgetSheetResult result) onBudgetResult;

  const _BudgetDetailHost({required this.group, required this.onBudgetResult});

  @override
  State<_BudgetDetailHost> createState() => _BudgetDetailHostState();
}

class _BudgetDetailHostState extends State<_BudgetDetailHost> {
  late ExpenseGroup _group = widget.group;

  Future<void> _change() async {
    final result = await showSheetPage<BudgetSheetResult>(
      context,
      title: gen.AppLocalizations.of(context).budget,
      builder: (_) => BudgetSettingsSheet(
        budget: _group.budget,
        currency: _group.currency,
        groupType: _group.groupType,
      ),
    );
    if (result == null || !mounted) return;
    await widget.onBudgetResult(result);
    if (!mounted) return;
    switch (result) {
      case BudgetSaved(:final budget):
        setState(() => _group = _group.copyWith(budget: budget));
      case BudgetRemoved():
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) =>
      BudgetDetailSheet(group: _group, onChange: _change);
}

/// The budget, top to bottom as one story: the title with the budget
/// ("600 € a month"), what is left of the current period (or how far over
/// it), its bar with today marked on it, a line on today, the periods
/// before and "Change budget". A daily budget's period is today, so it has
/// no line on today.
class BudgetDetailSheet extends StatelessWidget {
  final ExpenseGroup group;

  /// "Today" for the figures; now when null (tests set it).
  final DateTime? today;

  /// "Change budget"; closes the sheet with `true` when null.
  final VoidCallback? onChange;

  const BudgetDetailSheet({
    super.key,
    required this.group,
    this.today,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final lang = locale.toString();
    final status = BudgetStatus.of(
      group,
      today: today,
      firstDayOfWeek: firstDayOfWeekOf(context),
    );
    if (status == null) return const SizedBox.shrink();
    String money(double v) =>
        CurrencyDisplay.formatLocalizedText(v, group.currency, locale);
    final budget = status.budget;
    final daily = budget.period == BudgetPeriod.daily;
    final small = theme.textTheme.bodySmall?.copyWith(color: s.outline);
    final caps = theme.textTheme.labelSmall?.copyWith(
      color: s.outline,
      letterSpacing: 0.7,
    );

    final rate = switch (budget.period) {
      BudgetPeriod.total => gloc.budget_rate_total,
      BudgetPeriod.monthly => gloc.budget_rate_monthly,
      BudgetPeriod.weekly => gloc.budget_rate_weekly,
      BudgetPeriod.daily => gloc.budget_rate_daily,
    }(money(budget.amount));
    final periodName = switch (budget.period) {
      BudgetPeriod.total => gloc.budget_period_total,
      BudgetPeriod.monthly => toBeginningOfSentenceCase(
        DateFormat.MMMM(lang).format(status.start!),
        lang,
      ),
      BudgetPeriod.weekly => formatDateRange(
        start: status.start,
        end: status.end,
        locale: locale,
      ),
      BudgetPeriod.daily => gloc.budget_today_date(
        DateFormat.MMMMEEEEd(lang).format(status.start!),
      ),
    };
    final caption = switch ((status.dayNumber, status.dayCount)) {
      (final d?, final c?) when !daily => gloc.budget_period_day(
        periodName,
        d,
        c,
      ),
      _ => periodName,
    };
    final spentPercent = (status.spent / budget.amount * 100).round();
    final elapsed = switch ((status.dayNumber, status.dayCount)) {
      (final d?, final c?) when !daily => d / c,
      _ => null,
    };
    final overPeriod = status.spent > budget.amount;

    return CaravellaBottomSheetScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Text on the sheet at 20 (the grid), the card and button at 16.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          gloc.budget,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      rate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: s.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(caption, style: small),
                const SizedBox(height: 2),
                _Figure(
                  value: overPeriod ? status.overBy : status.remaining,
                  currency: group.currency,
                  size: 30,
                  after: overPeriod ? gloc.budget_over : gloc.budget_left,
                  color: overPeriod ? s.onBudgetOver : null,
                ),
                const SizedBox(height: 10),
                if (elapsed != null)
                  // "today" over the marker on the bar.
                  ExcludeSemantics(
                    child: Align(
                      alignment: Alignment(elapsed * 2 - 1, 0),
                      child: Text(gloc.today.toLowerCase(), style: small),
                    ),
                  ),
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
                const SizedBox(height: 6),
                Text(
                  gloc.budget_spent_of_share(
                    money(status.spent),
                    money(budget.amount),
                  ),
                  style: small,
                ),
                if (budget.period == BudgetPeriod.total &&
                    (group.startDate == null || group.endDate == null)) ...[
                  const SizedBox(height: 8),
                  Text(gloc.budget_set_dates_hint, style: small),
                ],
              ],
            ),
          ),
          if (!daily && status.todayShare != null) ...[
            const SizedBox(height: 16),
            _TodayCard(
              status: status,
              money: money,
              runOut: overPeriod || status.remaining <= 0,
              runOutText: budget.period == BudgetPeriod.monthly
                  ? gloc.budget_run_out_month(
                      DateFormat.MMMM(lang).format(status.start!),
                    )
                  : gloc.budget_run_out,
            ),
          ],
          if (status.pastPeriods.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
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
                        DateFormat.MMMM(lang).format(p.start),
                        lang,
                      ),
                      BudgetPeriod.weekly => formatDateRange(
                        start: p.start,
                        end: p.end,
                        locale: locale,
                      ),
                      _ => toBeginningOfSentenceCase(
                        DateFormat.MMMEd(lang).format(p.start),
                        lang,
                      ),
                    },
                    amount: budget.amount,
                    currency: group.currency,
                    money: money,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: onChange ?? () => Navigator.of(context).pop(true),
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

/// Today, in one card under the period: what can still be spent today
/// (with the ring), how far over today's share, or, the period's budget
/// spent, that it has run out; and the average per day so far.
class _TodayCard extends StatelessWidget {
  final BudgetStatus status;
  final String Function(double) money;
  final bool runOut;
  final String runOutText;

  const _TodayCard({
    required this.status,
    required this.money,
    required this.runOut,
    required this.runOutText,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final left = status.remainingToday ?? 0;
    final line = runOut
        ? runOutText
        : status.overToday
        ? gloc.budget_over_today_share(money(-left))
        : gloc.budget_can_spend_today(money(left));
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: s.raisedSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (runOut)
              Icon(Icons.warning_rounded, size: 24, color: s.onBudgetOver)
            else
              BudgetRing(
                fraction: status.todayFraction ?? 0,
                over: status.overToday,
                size: 32,
                strokeWidth: 4,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: status.overToday && !runOut
                          ? s.onBudgetOver
                          : null,
                    ),
                  ),
                  if (status.averagePerDay case final avg?) ...[
                    const SizedBox(height: 2),
                    Text(
                      gloc.budget_so_far_per_day(money(avg)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: s.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
