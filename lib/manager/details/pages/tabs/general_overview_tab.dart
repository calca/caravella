import 'package:flutter/material.dart';
import '../../../../data/model/expense_group.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'widgets/stat_card.dart';
import '../../../../widgets/charts/weekly_expense_chart.dart';
import '../../../../widgets/charts/monthly_expense_chart.dart';
import '../../../../widgets/charts/date_range_expense_chart.dart';
import 'daily_totals_utils.dart';
import 'date_range_formatter.dart';
import '../../widgets/group_header.dart'; // for ParticipantAvatar
import '../../../../widgets/currency_display.dart';
import '../../../../data/model/expense_participant.dart';

/// General statistics tab: shows high level KPIs (daily/monthly average)
/// and spending trend for the last 7 and 30 days.
class GeneralOverviewTab extends StatelessWidget {
  final ExpenseGroup trip;
  const GeneralOverviewTab({super.key, required this.trip});

  double _total() => trip.expenses.fold(0.0, (s, e) => s + (e.amount ?? 0));

  double _dailyAverage() {
    if (trip.expenses.isEmpty) return 0;
    // Distinct days with at least one expense for fairer average
    final days = trip.expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .length;
    return days == 0 ? 0 : _total() / days;
  }

  double _monthlyAverage() {
    if (trip.expenses.isEmpty) return 0;
    final sorted = trip.expenses.map((e) => e.date).toList()..sort();
    final first = sorted.first;
    final last = sorted.last;
    int months = (last.year - first.year) * 12 + (last.month - first.month) + 1;
    if (months <= 0) months = 1;
    return _total() / months;
  }

  // Delegated to shared helpers for consistency
  List<double> _weeklySeries() => buildWeeklySeries(trip);
  List<double> _monthlySeries() => buildMonthlySeries(trip);
  List<double> _dateRangeSeries() => buildAdaptiveDateRangeSeries(trip);

  // Returns participants ordered by activity (number of expenses paid)
  List<ExpenseParticipantCount> _topParticipants() {
    final counts = <String, int>{};
    for (final e in trip.expenses) {
      final id = e.paidBy.id;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final byId = {for (final p in trip.participants) p.id: p};
    final items = <ExpenseParticipantCount>[];
    for (final entry in counts.entries) {
      final p = byId[entry.key];
      if (p != null) items.add(ExpenseParticipantCount(p, entry.value));
    }
    // Include participants with zero activity to avoid empty UI on new groups
    for (final p in trip.participants) {
      if (!counts.containsKey(p.id)) {
        items.add(ExpenseParticipantCount(p, 0));
      }
    }
    items.sort((a, b) => b.count.compareTo(a.count));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (trip.expenses.isEmpty) {
      return Center(
        child: Text(
          gloc.no_expenses_for_statistics,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final dailyAvg = _dailyAverage();
    final monthlyAvg = _monthlyAverage();
    final weekly = _weeklySeries();
    final monthly = _monthlySeries();
    final dateRange = _dateRangeSeries();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _TopSummaryRow(
            total: _total(),
            currency: trip.currency,
            participants: _topParticipants(),
            count: trip.participants.length,
          ),
          const SizedBox(height: 24),
          if (shouldShowDateRangeChart(trip)) ...[
            DateRangeExpenseChart(dailyTotals: dateRange, theme: theme),
          ] else ...[
            // Weekly chart
            WeeklyExpenseChart(dailyTotals: weekly, theme: theme),
            const SizedBox(height: 32),
            // Monthly chart
            MonthlyExpenseChart(dailyTotals: monthly, theme: theme),
          ],
          const SizedBox(height: 32),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6, // square cards
            ),
            children: [
              StatCard(
                title: gloc.daily_average,
                value: dailyAvg,
                currency: trip.currency,
                icon: Icons.calendar_today_outlined,
              ),
              StatCard(
                title: gloc.monthly_average,
                value: monthlyAvg,
                currency: trip.currency,
                icon: Icons.calendar_month_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DetailsCard(trip: trip),
        ],
      ),
    );
  }
}

class ExpenseParticipantCount {
  final ExpenseParticipant participant;
  final int count;
  ExpenseParticipantCount(this.participant, this.count);
}

class _TopSummaryRow extends StatelessWidget {
  final double total;
  final String currency;
  final List<ExpenseParticipantCount> participants;
  final int count;
  const _TopSummaryRow({
    required this.total,
    required this.currency,
    required this.participants,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = theme.colorScheme;
    final avatarSize = 32.0;

    // Take up to 3 (third will be faded if exists)
    final top = participants.take(3).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Total label + amount
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gloc.total_spent,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              CurrencyDisplay(
                value: total,
                currency: currency,
                showDecimals: true,
                valueFontSize: 36,
                currencyFontSize: 16,
                fontWeight: FontWeight.w600,
                alignment: MainAxisAlignment.start,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Right: overlapping avatars + count
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Overlapping avatars
            SizedBox(
              width: avatarSize + 2 * (avatarSize * 0.7),
              height: avatarSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (int i = 0; i < top.length && i < 3; i++)
                    Positioned(
                      left: i * (avatarSize * 0.7),
                      child: Opacity(
                        opacity: i == 2 && top.length >= 3 ? 0.35 : 1.0,
                        child: ParticipantAvatar(
                          participant: top[i].participant,
                          size: avatarSize,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final ExpenseGroup trip;
  const _DetailsCard({required this.trip});

  String _dateRangeString(BuildContext context) => formatDateRange(
    start: trip.startDate,
    end: trip.endDate,
    locale: Localizations.localeOf(context),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;

    final dateStr = _dateRangeString(context);
    final participantsCount = trip.participants.length;
    final participantsLabel = gloc.participant_count(participantsCount);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // Title as in screenshot
                  Localizations.localeOf(context).languageCode == 'it'
                      ? 'Dettagli'
                      : 'Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _DetailRow(
            icon: Icons.info_outline,
            title: gloc.dates,
            subtitle: dateStr.isEmpty ? '-' : dateStr,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.group_outlined,
            title: gloc.participants_label,
            subtitle: participantsLabel,
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: colorScheme.outline, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
