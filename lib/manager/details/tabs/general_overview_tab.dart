import 'package:flutter/material.dart';
import '../../../data/model/expense_group.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'widgets/stat_card.dart';
import '../../../widgets/charts/weekly_expense_chart.dart';
import '../../../widgets/charts/monthly_expense_chart.dart';
import '../../../widgets/charts/date_range_expense_chart.dart';
import 'daily_totals_utils.dart';
import 'date_range_formatter.dart';

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
          if (dateRange.isNotEmpty) ...[
            const SizedBox(height: 24),
            DateRangeExpenseChart(dailyTotals: dateRange, theme: theme),
          ] else ...[
            // Weekly chart
            WeeklyExpenseChart(dailyTotals: weekly, theme: theme),
            const SizedBox(height: 24),
            // Monthly chart
            MonthlyExpenseChart(dailyTotals: monthly, theme: theme),
          ],
          const SizedBox(height: 24),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0, // square cards
            ),
            children: [
              StatCard(
                title: gloc.total_spent,
                value: _total(),
                currency: trip.currency,
              ),
              _InfoMetaCard(trip: trip),
              StatCard(
                title: gloc.daily_average,
                value: dailyAvg,
                currency: trip.currency,
              ),
              StatCard(
                title: gloc.monthly_average,
                value: monthlyAvg,
                currency: trip.currency,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoMetaCard extends StatelessWidget {
  final ExpenseGroup trip;
  const _InfoMetaCard({required this.trip});

  String _dateRangeString(BuildContext context) => formatDateRange(
    start: trip.startDate,
    end: trip.endDate,
    locale: Localizations.localeOf(context),
  );

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final participants = trip.participants.length;
    // If both dates exist and end is today (ongoing), hide date range per requirement.
    String dateStr = _dateRangeString(context);
    if (trip.startDate != null && trip.endDate != null) {
      final today = DateTime.now();
      final end = trip.endDate!;
      final isToday =
          end.year == today.year &&
          end.month == today.month &&
          end.day == today.day;
      if (isToday) {
        dateStr = ''; // suppress date range
      }
    }
    final participantLabel = gloc.participant_count(participants);
    final subtitle = dateStr.isEmpty
        ? participantLabel
        : '$dateStr\n$participantLabel';
    return InfoCard(title: gloc.info_tab, subtitle: subtitle);
  }
}
