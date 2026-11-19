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

/// The budget, top to bottom as one answer to "will it last?": the title
/// with the budget and its period ("600 € a month · November") and a pencil
/// to change it; what is left of the current period (or how far over it),
/// its bar with today marked on it, what was spent and the days left; how
/// much a day keeps it within the budget against the pace so far, with a
/// forecast of the day it runs out (or, spent, when it starts again); the
/// periods before. A daily budget's period is today: no pace.
class BudgetDetailSheet extends StatelessWidget {
  final ExpenseGroup group;

  /// "Today" for the figures; now when null (tests set it).
  final DateTime? today;

  /// The pencil; closes the sheet with `true` when null.
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
    final small = theme.textTheme.bodySmall?.copyWith(
      color: s.onSurfaceVariant,
    );
    final caps = theme.textTheme.labelSmall?.copyWith(
      color: s.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.7,
    );

    final rate = switch (budget.period) {
      BudgetPeriod.total => gloc.budget_rate_total,
      BudgetPeriod.monthly => gloc.budget_rate_monthly,
      BudgetPeriod.weekly => gloc.budget_rate_weekly,
      BudgetPeriod.daily => gloc.budget_rate_daily,
    }(money(budget.amount));
    final periodName = switch (budget.period) {
      BudgetPeriod.total => null,
      BudgetPeriod.monthly => DateFormat.MMMM(lang).format(status.start!),
      BudgetPeriod.weekly => formatDateRange(
        start: status.start,
        end: status.end,
        locale: locale,
      ),
      BudgetPeriod.daily => gloc.today.toLowerCase(),
    };
    final spentPercent = (status.spent / budget.amount * 100).round();
    final elapsed = switch ((status.dayNumber, status.dayCount)) {
      (final d?, final c?) when !daily => d / c,
      _ => null,
    };
    final overPeriod = status.spent > budget.amount;
    final daysLeft = daily ? null : status.daysLeft;

    // Text written on the sheet sits 4 in from the cards (the grid: 20
    // from the screen's edge, cards at 16).
    Widget onSheet(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: child,
    );

    return CaravellaBottomSheetScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: onSheet(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          gloc.budget,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text([rate, ?periodName].join(' · '), style: small),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.outlined(
                tooltip: gloc.budget_change,
                onPressed: onChange ?? () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          onSheet(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Figure(
                  value: overPeriod ? status.overBy : status.remaining,
                  currency: group.currency,
                  size: 36,
                  after: overPeriod ? gloc.budget_over : gloc.budget_left,
                  color: overPeriod ? s.onBudgetOver : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  // Without a marker (a daily budget, a budget in total
                  // without dates) only the share spent: "0% of the period
                  // gone" was read at any hour.
                  label: elapsed == null
                      ? gloc.budget_bar_semantics_spent(spentPercent)
                      : gloc.budget_bar_semantics(
                          spentPercent,
                          (elapsed * 100).round(),
                        ),
                  child: BudgetBar(
                    fraction: status.spent / budget.amount,
                    over: overPeriod,
                    marker: elapsed,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        overPeriod
                            ? gloc.budget_spent_of_share(
                                money(status.spent),
                                money(budget.amount),
                              )
                            : gloc.budget_spent(money(status.spent)),
                        style: small,
                      ),
                    ),
                    // Over the budget, the card below says when it
                    // starts again.
                    if (daysLeft != null && !overPeriod) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(gloc.budget_days_left(daysLeft), style: small),
                    ],
                  ],
                ),
                if (budget.period == BudgetPeriod.total &&
                    (group.startDate == null || group.endDate == null)) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(gloc.budget_set_dates_hint, style: small),
                ],
              ],
            ),
          ),
          if (!daily && daysLeft != null)
            if (overPeriod || status.remaining <= 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: budget.period == BudgetPeriod.total
                    ? _NoteCard(
                        icon: Icons.warning_amber_rounded,
                        title: gloc.budget_run_out,
                        subtitle: switch (status.averagePerDay) {
                          final avg? => gloc.budget_so_far_per_day(money(avg)),
                          null => null,
                        },
                      )
                    : _NoteCard(
                        icon: Icons.event_outlined,
                        title: gloc.budget_restarts(
                          DateFormat.MMMMEEEEd(lang).format(
                            DateTime(
                              status.end!.year,
                              status.end!.month,
                              status.end!.day + 1,
                            ),
                          ),
                        ),
                        subtitle: gloc.budget_restarts_in(daysLeft),
                      ),
              )
            else if (status.perDayToEnd case final perDay?)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: _PaceCard(
                  perDay: perDay,
                  soFar: status.averagePerDay ?? 0,
                  currency: group.currency,
                  forecast: switch (status.runOutDay) {
                    final day? => gloc.budget_pace_runs_out(
                      DateFormat.MMMMEEEEd(lang).format(day),
                    ),
                    null => gloc.budget_pace_lasts,
                  },
                ),
              ),
          if (status.pastPeriods.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            onSheet(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    switch (budget.period) {
                      BudgetPeriod.monthly => gloc.budget_past_months,
                      BudgetPeriod.weekly => gloc.budget_past_weeks,
                      _ => gloc.budget_past_days,
                    }.toUpperCase(),
                    style: caps,
                  ),
                  const SizedBox(height: AppSpacing.xs),
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
          ],
        ],
      ),
    );
  }
}

/// "To stay within budget": what can be spent a day from today to the end
/// of the period beside what was spent a day so far, and a forecast in
/// words. Calm: no colour, the words say whether the pace lasts.
class _PaceCard extends StatelessWidget {
  final double perDay;
  final double soFar;
  final String currency;
  final String forecast;

  const _PaceCard({
    required this.perDay,
    required this.soFar,
    required this.currency,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final small = theme.textTheme.bodySmall?.copyWith(
      color: s.onSurfaceVariant,
    );
    Widget figure(double value, String words) => Expanded(
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurrencyDisplay(
              value: value,
              currency: currency,
              valueFontSize: 17,
              currencyFontSize: 12,
              showDecimals: true,
              alignment: MainAxisAlignment.start,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 2),
            Text(words, style: small),
          ],
        ),
      ),
    );
    return _CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            gloc.budget_stay_within,
            style: theme.textTheme.labelLarge?.copyWith(
              color: s.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              figure(perDay, gloc.budget_per_day_to_end),
              const SizedBox(width: AppSpacing.sm),
              figure(soFar, gloc.budget_per_day_so_far),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(forecast, style: small),
        ],
      ),
    );
  }
}

/// A card with an icon and a line or two: when a spent budget starts
/// again, or that a budget in total has run out.
class _NoteCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _NoteCard({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return MergeSemantics(
      child: _CardBox(
        child: Row(
          children: [
            Icon(icon, size: 24, color: s.onSurface),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle case final line?) ...[
                    const SizedBox(height: 2),
                    Text(
                      line,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: s.onSurfaceVariant,
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

/// A card on the sheet: text inside at 30 from the screen's edge (14 of
/// padding on a card at 16).
class _CardBox extends StatelessWidget {
  final Widget child;

  const _CardBox({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.raisedSurface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: child,
  );
}

/// The periods before, one row each, all the same height: name, a bar on
/// the budget's scale and what it spent, in whole units, with "+42" in
/// amber beside it when it went over. A table, so the bars line up
/// whatever the amounts.
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
      return TableRow(
        children: [
          Semantics(
            label: gloc.budget_past_semantics(
              label,
              money(p.spent),
              money(amount),
            ),
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Text(label, style: theme.textTheme.bodyMedium),
            ),
          ),
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: BudgetBar(
                fraction: p.spent / amount,
                over: over,
                height: 8,
              ),
            ),
          ),
          ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CurrencyDisplay(
                  value: p.spent.roundToDouble(),
                  currency: currency,
                  valueFontSize: 15,
                  currencyFontSize: 12,
                  showDecimals: false,
                ),
                if (over) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: s.budgetOver.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '+${(p.spent - amount).round()}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: s.onBudgetOver,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
    // "18.00 € left" in one stop.
    return MergeSemantics(
      child: Wrap(
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
      ),
    );
  }
}
