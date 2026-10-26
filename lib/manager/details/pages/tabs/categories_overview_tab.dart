import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../widgets/stat_card.dart';

/// Categories analysis tab: daily average by category + distribution pie chart.
class CategoriesOverviewTab extends StatelessWidget {
  final ExpenseGroup trip;

  /// Without its own scroll view, to sit inside the group page's scroll.
  final bool embedded;

  const CategoriesOverviewTab({
    super.key,
    required this.trip,
    this.embedded = false,
  });

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

    final totalAll = trip.getTotalExpenses();
    // Same period and unit as the spending pace card, so the per-day (or
    // per-month, for long groups) figures add up to it.
    final pace = SpendingPace.of(trip);
    final periods = pace?.periods ?? 1;
    final perUnit = pace?.unit == SpendingPaceUnit.month
        ? gloc.per_month
        : gloc.per_day;

    // Build totals per category using model method
    final categoryTotals = trip.getCategoryTotals();
    final uncategorizedTotal = trip.getUncategorizedTotal();
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

    final content = Padding(
      padding: embedded
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(12, 8, 12, 32),
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
            final perPeriod = total / periods;
            final pct = totalAll == 0 ? 0.0 : (total / totalAll) * 100.0;
            final subtitleSpans = <InlineSpan>[
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: CurrencyDisplay(
                  value: perPeriod,
                  currency: trip.currency,
                  showDecimals: true,
                  valueFontSize: 12,
                  currencyFontSize: 10,
                  alignment: MainAxisAlignment.start,
                ),
              ),
              TextSpan(text: ' $perUnit'),
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
    return embedded ? content : SingleChildScrollView(child: content);
  }
}
