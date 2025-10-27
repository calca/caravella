import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Categories analysis tab: daily average by category + distribution pie chart.
class CategoriesOverviewTab extends StatelessWidget {
  final ExpenseGroup trip;
  const CategoriesOverviewTab({super.key, required this.trip});

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

    ({DateTime start, DateTime end}) calculateDateRangeLocal() {
      final now = DateTime.now();
      if (trip.startDate == null || trip.endDate == null) {
        if (trip.expenses.isEmpty) {
          final firstDay = DateTime(now.year, now.month, 1);
          final lastDay = DateTime(now.year, now.month + 1, 0);
          return (start: firstDay, end: lastDay);
        }
        final sorted = [...trip.expenses]
          ..sort((a, b) => a.date.compareTo(b.date));
        final first = sorted.first.date;
        return (
          start: DateTime(first.year, first.month, first.day),
          end: DateTime(now.year, now.month, now.day),
        );
      }
      final startDate = DateTime(
        trip.startDate!.year,
        trip.startDate!.month,
        trip.startDate!.day,
      );
      final endDate = DateTime(
        trip.endDate!.year,
        trip.endDate!.month,
        trip.endDate!.day,
      );
      final currentDate = DateTime(now.year, now.month, now.day);
      final effectiveEndDate = endDate.isBefore(currentDate)
          ? endDate
          : currentDate;
      return (start: startDate, end: effectiveEndDate);
    }

    final totalAll = trip.expenses.fold<double>(
      0,
      (s, e) => s + (e.amount ?? 0),
    );
    final range = calculateDateRangeLocal();
    final totalDays = (range.end.difference(range.start).inDays + 1).clamp(
      1,
      1000000,
    );

    // Build totals per category (include known categories; add uncategorized if needed)
    final Map<ExpenseCategory, double> categoryTotals = {
      for (final c in trip.categories)
        c: trip.expenses
            .where((e) => e.category.id == c.id)
            .fold<double>(0, (sum, e) => sum + (e.amount ?? 0)),
    };
    final uncategorizedTotal = trip.expenses
        .where((e) => !trip.categories.any((c) => c.id == e.category.id))
        .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
    if (uncategorizedTotal > 0) {
      categoryTotals[ExpenseCategory(
            name: 'UNCATEGORIZED_PLACEHOLDER',
            id: 'uncategorized',
            createdAt: DateTime(2000),
          )] =
          uncategorizedTotal;
    }

    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top list: one StatCard per category with total, per-day, and % with progress bar
          ...entries.map((entry) {
            final displayName =
                entry.key.id == 'uncategorized' &&
                    entry.key.name == 'UNCATEGORIZED_PLACEHOLDER'
                ? gloc.uncategorized
                : entry.key.name;
            final total = entry.value;
            final perDay = total / totalDays;
            final pct = totalAll == 0 ? 0.0 : (total / totalAll) * 100.0;
            final subtitleSpans = <InlineSpan>[
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: CurrencyDisplay(
                  value: perDay,
                  currency: trip.currency,
                  showDecimals: true,
                  valueFontSize: 12,
                  currencyFontSize: 10,
                  alignment: MainAxisAlignment.start,
                ),
              ),
              TextSpan(text: ' ${gloc.per_day}'),
            ];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StatCard(
                title: displayName,
                value: total,
                currency: trip.currency,
                subtitleSpans: subtitleSpans,
                percent: pct,
                inlineHeader: true,
              ),
            );
          }),
        ],
      ),
    );
  }
}
