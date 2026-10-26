import 'dart:math' as math;

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../pages/tabs/categories_overview_tab.dart';
import '../pages/tabs/usecase/daily_totals_utils.dart';
import '../pages/tabs/usecase/date_range_formatter.dart';
import 'group_map_card.dart';
import 'grouped_expense_list.dart';
import 'stat_card.dart';

/// Statistics view of the group page: one spending chart over the whole
/// group ([buildGroupSpendingSeries]), who paid how much,
/// map card ([GroupMapCard]), spending pace ([SpendingPaceCard]), highest expense and most
/// expensive day (or month, for long groups),
/// then the categories. The total, period
/// and participant count are already in the page header, so they aren't
/// repeated here.
class GroupStatisticsView extends StatelessWidget {
  final ExpenseGroup group;

  /// Opens the group setting for automatic location (from the map card,
  /// when no expense has a place and the setting is off).
  final VoidCallback? onEnableLocation;

  const GroupStatisticsView({
    super.key,
    required this.group,
    this.onEnableLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);

    Widget title(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(6, 24, 6, 10),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // One chart over the whole group, step chosen by its length.
          if (buildGroupSpendingSeries(group) case final series?
              when _hasSpending(series.values))
            _ChartCard(
              title: switch (series.step) {
                SpendingStep.day => gloc.chart_day_by_day,
                SpendingStep.week => gloc.chart_week_by_week,
                SpendingStep.month => gloc.chart_month_by_month,
              },
              subtitle: formatDateRange(
                start: series.start,
                end: series.end,
                locale: Localizations.localeOf(context),
              ),
              chart: DateRangeExpenseChart(
                dailyTotals: series.values,
                theme: theme,
                badgeText: gloc.dateRangeChartBadge,
                semanticLabel: gloc.dateRangeExpensesChart,
                height: _ChartCard.chartHeight,
                showBadge: false,
                color: theme.colorScheme.primary,
              ),
            ),
          title(gloc.participants),
          GroupPayersBubbles(group: group),
          const SizedBox(height: 12),
          GroupMapCard(group: group, onEnableLocation: onEnableLocation),
          if (SpendingPace.of(group) case final pace?) ...[
            const SizedBox(height: 12),
            SpendingPaceCard(pace: pace, currency: group.currency),
            const SizedBox(height: 12),
            _RecordCards(
              cards: [
                if (highestExpense(group) case final top?)
                  StatCard(
                    title: gloc.highest_expense,
                    value: top.amount ?? 0,
                    currency: group.currency,
                    subtitle: top.name ?? '',
                    icon: Icons.arrow_upward_rounded,
                  ),
                // The record follows the pace's unit: the most expensive
                // month says more than a single day in a long group.
                if (pace.unit == SpendingPaceUnit.month)
                  if (mostExpensiveMonth(group) case (final month, final total))
                    StatCard(
                      title: gloc.most_expensive_month,
                      value: total,
                      currency: group.currency,
                      subtitle: DateFormat.yMMMM(
                        Localizations.localeOf(context).toString(),
                      ).format(month),
                      icon: Icons.calendar_month_outlined,
                    )
                  else
                    ...[]
                else if (mostExpensiveDay(group) case (final day, final total))
                  StatCard(
                    title: gloc.most_expensive_day,
                    value: total,
                    currency: group.currency,
                    subtitle: DateFormat(
                      'EEE d MMM',
                      Localizations.localeOf(context).toString(),
                    ).format(day),
                    icon: Icons.event_rounded,
                  ),
              ],
            ),
          ],
          title(gloc.categories),
          CategoriesOverviewTab(trip: group, embedded: true),
        ],
      ),
    );
  }
}

/// The record cards (highest expense, most expensive day or month): side by
/// side, or one per row with large text, where side by side they'd break
/// words and truncate the amounts.
class _RecordCards extends StatelessWidget {
  final List<Widget> cards;

  const _RecordCards({required this.cards});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.textScalerOf(context).scale(1) >= 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, c) in cards.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            c,
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, c) in cards.indexed) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: c),
          ],
        ],
      ),
    );
  }
}

/// A chart in a card with an explicit title (and optional subtitle, e.g.
/// the period).
class _ChartCard extends StatelessWidget {
  static const double chartHeight = 96;

  final String title;
  final String? subtitle;
  final Widget chart;

  const _ChartCard({required this.title, required this.chart, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final radius = BorderRadius.circular(20);
    // Title outside the card, like the other sections of the view.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
          // Title left, period right; the period goes under the title when
          // they don't fit on one line (large text).
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: s.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        CardOutline(
          borderRadius: radius,
          child: Material(
            color: s.raisedSurface,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: chart,
            ),
          ),
        ),
      ],
    );
  }
}

/// Whether a chart series has anything to draw (charts render nothing for
/// an all-zero series, which would leave an empty card).
bool _hasSpending(List<double> series) => series.any((v) => v > 0);

/// The group's largest expense, or null when it has none.
ExpenseDetails? highestExpense(ExpenseGroup group) => group.expenses.isEmpty
    ? null
    : group.expenses.reduce(
        (a, b) => (b.amount ?? 0) > (a.amount ?? 0) ? b : a,
      );

/// The calendar day with the highest total and that total, or null when the
/// group has no expenses.
(DateTime, double)? mostExpensiveDay(ExpenseGroup group) {
  (DateTime, double)? best;
  for (final (day, expenses) in WeekGroupedExpenseSliver.groupByDay(
    group.expenses,
  )) {
    final total = expenses.fold<double>(0, (t, e) => t + (e.amount ?? 0));
    if (best == null || total > best.$2) best = (day, total);
  }
  return best;
}

/// The calendar month with the highest total (as its first day) and that
/// total, or null when the group has no expenses.
(DateTime, double)? mostExpensiveMonth(ExpenseGroup group) {
  final totals = <DateTime, double>{};
  for (final e in group.expenses) {
    final month = DateTime(e.date.year, e.date.month);
    totals[month] = (totals[month] ?? 0) + (e.amount ?? 0);
  }
  (DateTime, double)? best;
  for (final MapEntry(key: month, value: total) in totals.entries) {
    if (best == null || total > best.$2) best = (month, total);
  }
  return best;
}

/// The group's average spending over its whole period ([SpendingPace]): the
/// amount per day (or per month, for long groups), what it is computed over,
/// then the number of expenses, the average expense and how many days or
/// months had any.
class SpendingPaceCard extends StatelessWidget {
  final SpendingPace pace;
  final String currency;

  const SpendingPaceCard({
    super.key,
    required this.pace,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final monthly = pace.unit == SpendingPaceUnit.month;
    final range = monthly
        ? _monthRange(pace.start, pace.end, locale)
        : formatDateRange(start: pace.start, end: pace.end, locale: locale);
    final unit = monthly ? gloc.stats_per_month : gloc.stats_per_day;
    final over = monthly
        ? gloc.stats_pace_months(pace.periods, range)
        : gloc.stats_pace_days(pace.periods, range);
    final perExpense = CurrencyDisplay.formatCurrencyText(
      pace.perExpense,
      currency,
    );
    final radius = BorderRadius.circular(20);

    Widget pill(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: s.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: theme.textTheme.bodySmall),
    );

    return Semantics(
      container: true,
      label:
          '${gloc.stats_pace_title}: '
          '${CurrencyDisplay.formatCurrencyText(pace.average, currency)} '
          '$unit. $over',
      child: CardOutline(
        borderRadius: radius,
        child: Material(
          color: s.raisedSurface,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Text(
                    gloc.stats_pace_title.toUpperCase(),
                    // Same label style as Home's "Recent expenses".
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: s.outline,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ExcludeSemantics(
                  // "per day" goes under the amount if they don't fit.
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: CurrencyDisplay(
                          value: pace.average,
                          currency: currency,
                          valueFontSize: 32,
                          currencyFontSize: 16,
                          showDecimals: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        unit,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: s.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(over, style: AppTextStyles.subtle(context)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    pill(gloc.expense_count(pace.expenseCount)),
                    pill(gloc.stats_per_expense(perExpense)),
                    pill(
                      monthly
                          ? gloc.stats_active_months(
                              pace.activePeriods,
                              pace.periods,
                            )
                          : gloc.stats_active_days(
                              pace.activePeriods,
                              pace.periods,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _monthRange(DateTime start, DateTime end, Locale locale) {
    final fmt = DateFormat.yMMM(locale.toString());
    return start.year == end.year && start.month == end.month
        ? fmt.format(start)
        : '${fmt.format(start)} – ${fmt.format(end)}';
  }
}

/// Who paid how much: one avatar per participant, sized by what they paid
/// (area proportional to the amount), with name and amount below.
class GroupPayersBubbles extends StatelessWidget {
  final ExpenseGroup group;

  const GroupPayersBubbles({super.key, required this.group});

  static const double _minSize = 36;
  static const double _maxSize = 72;

  /// Avatar size for [paid] out of the largest [max] payment.
  static double sizeFor(double paid, double max) => max <= 0
      ? _minSize
      : _minSize + (_maxSize - _minSize) * math.sqrt(paid / max);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final totals = group.getParticipantTotals();
    final payers = group.participants.toList()
      ..sort((a, b) => (totals[b.id] ?? 0).compareTo(totals[a.id] ?? 0));
    final max = payers.isEmpty ? 0.0 : (totals[payers.first.id] ?? 0);
    final radius = BorderRadius.circular(20);

    return CardOutline(
      borderRadius: radius,
      child: Material(
        color: s.raisedSurface,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 4,
            runSpacing: 16,
            children: [
              for (final p in payers)
                Semantics(
                  label:
                      '${p.name}, '
                      '${(totals[p.id] ?? 0).toStringAsFixed(2)} '
                      '${group.currency}',
                  excludeSemantics: true,
                  child: SizedBox(
                    width: 74,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ParticipantAvatar(
                          participant: p,
                          size: sizeFor(totals[p.id] ?? 0, max),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Shrinks rather than truncates with large text.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: CurrencyDisplay(
                            value: totals[p.id] ?? 0,
                            currency: group.currency,
                            valueFontSize: 15,
                            currencyFontSize: 11,
                            showDecimals: true,
                            color: s.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
