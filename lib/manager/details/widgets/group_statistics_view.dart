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
import 'day_grouped_expense_list.dart';
import 'stat_card.dart';

/// Statistics view of the group page: spending chart, who paid how much,
/// map, daily / monthly averages, highest expense and most expensive day,
/// then the categories. The total, period
/// and participant count are already in the page header, so they aren't
/// repeated here.
class GroupStatisticsView extends StatelessWidget {
  final ExpenseGroup group;

  const GroupStatisticsView({super.key, required this.group});

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
          // Charts sit in cards named explicitly (instead of the D / W / M
          // letter badges used where they're inline).
          if (shouldShowDateRangeChart(group)) ...[
            if (_hasSpending(buildAdaptiveDateRangeSeries(group)))
              _ChartCard(
                title: gloc.chart_day_by_day,
                subtitle: formatDateRange(
                  start: group.getEffectiveDateRange().start,
                  end: group.getEffectiveDateRange().end,
                  locale: Localizations.localeOf(context),
                ),
                chart: DateRangeExpenseChart(
                  dailyTotals: buildAdaptiveDateRangeSeries(group),
                  theme: theme,
                  badgeText: gloc.dateRangeChartBadge,
                  semanticLabel: gloc.dateRangeExpensesChart,
                  height: _ChartCard.chartHeight,
                  showBadge: false,
                  color: theme.colorScheme.primary,
                ),
              ),
          ] else ...[
            if (_hasSpending(buildWeeklySeries(group))) ...[
              _ChartCard(
                title: gloc.this_week,
                chart: WeeklyExpenseChart(
                  dailyTotals: buildWeeklySeries(group),
                  theme: theme,
                  badgeText: gloc.weeklyChartBadge,
                  semanticLabel: gloc.weeklyExpensesChart,
                  height: _ChartCard.chartHeight,
                  showBadge: false,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_hasSpending(buildMonthlySeries(group)))
              _ChartCard(
                title: gloc.this_month,
                chart: MonthlyExpenseChart(
                  dailyTotals: buildMonthlySeries(group),
                  theme: theme,
                  badgeText: gloc.monthlyChartBadge,
                  semanticLabel: gloc.monthlyExpensesChart,
                  height: _ChartCard.chartHeight,
                  showBadge: false,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
          title(gloc.participants),
          GroupPayersBubbles(group: group),
          if (groupPlacesCount(group) > 0) ...[
            const SizedBox(height: 12),
            GroupMapCard(group: group),
          ],
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatCard(
                    title: gloc.daily_average,
                    value: group.getDailyAverage(),
                    currency: group.currency,
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: gloc.monthly_average,
                    value: group.getMonthlyAverage(),
                    currency: group.currency,
                    icon: Icons.calendar_month_outlined,
                  ),
                ),
              ],
            ),
          ),
          if (highestExpense(group) case final top?) ...[
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatCard(
                      title: gloc.highest_expense,
                      value: top.amount ?? 0,
                      currency: group.currency,
                      subtitle: top.name ?? '',
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (mostExpensiveDay(group) case (final day, final total))
                    Expanded(
                      child: StatCard(
                        title: gloc.most_expensive_day,
                        value: total,
                        currency: group.currency,
                        subtitle: DateFormat(
                          'EEE d MMM',
                          Localizations.localeOf(context).toString(),
                        ).format(day),
                        icon: Icons.event_rounded,
                      ),
                    ),
                ],
              ),
            ),
          ],
          title(gloc.categories),
          CategoriesOverviewTab(trip: group, embedded: true),
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
    return CardOutline(
      borderRadius: radius,
      child: Material(
        color: s.raisedSurface,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
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
              const SizedBox(height: 12),
              chart,
            ],
          ),
        ),
      ),
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
  for (final (day, expenses) in DayGroupedExpenseSliver.groupByDay(
    group.expenses,
  )) {
    final total = expenses.fold<double>(0, (t, e) => t + (e.amount ?? 0));
    if (best == null || total > best.$2) best = (day, total);
  }
  return best;
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
                        CurrencyDisplay(
                          value: totals[p.id] ?? 0,
                          currency: group.currency,
                          valueFontSize: 15,
                          currencyFontSize: 11,
                          showDecimals: true,
                          color: s.onSurfaceVariant,
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
