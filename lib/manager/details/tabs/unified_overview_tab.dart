import 'package:flutter/material.dart';
import '../../../data/model/expense_group.dart';
import '../../../widgets/currency_display.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'settlements_logic.dart';
import 'widgets/categories_pie_chart.dart';
import 'widgets/daily_average_by_category.dart';

/// Unified overview tab that combines the functionality of both OverviewTab and StatisticsTab.
/// Shows exactly 2 charts (daily expenses and categories pie chart) plus settlement information.
/// This addresses the requirement to "unify overview and statistics pages with useful information
/// and maximum 2 charts".
class UnifiedOverviewTab extends StatelessWidget {
  final ExpenseGroup trip;
  const UnifiedOverviewTab({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    final settlements = computeSettlements(trip);

    if (trip.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_customize_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              gloc.no_expenses_for_statistics,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    // (Grafico daily/weekly rimosso in favore dei tab dedicati)

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Sezione partecipanti
            Text(
              gloc.expenses_by_participant,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...trip.participants.map((p) {
              final total = trip.expenses
                  .where((e) => e.paidBy.name == p.name)
                  .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary.withAlpha(
                        (0.1 * 255).toInt(),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CurrencyDisplay(
                      value: total,
                      currency: trip.currency,
                      valueFontSize: 14.0,
                      currencyFontSize: 12.0,
                      alignment: MainAxisAlignment.end,
                      showDecimals: true,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Percentuali di contributo
            Builder(
              builder: (context) {
                final totalAll = trip.expenses.fold<double>(
                  0,
                  (s, e) => s + (e.amount ?? 0),
                );
                if (totalAll <= 0) return const SizedBox.shrink();
                // Precompute and sort by percentage descending
                final entries = trip.participants.map((p) {
                  final total = trip.expenses
                      .where((e) => e.paidBy.name == p.name)
                      .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
                  final pct = totalAll == 0 ? 0 : (total / totalAll) * 100;
                  return (participant: p, total: total, pct: pct);
                }).toList()..sort((a, b) => b.pct.compareTo(a.pct));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gen.AppLocalizations.of(context).contribution_percentages,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.participant.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: LinearProgressIndicator(
                                value: (e.pct / 100).clamp(0, 1),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${e.pct.toStringAsFixed(1)}% ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),

            // 2. SETTLEMENT
            Text(
              gloc.settlement,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (settlements.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        gloc.all_balanced,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...settlements.map((settlement) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.error.withAlpha(
                          (0.1 * 255).toInt(),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: settlement['from'],
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              TextSpan(
                                text: gloc.owes_to,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              TextSpan(
                                text: settlement['to'],
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      CurrencyDisplay(
                        value: settlement['amount'],
                        currency: trip.currency,
                        valueFontSize: 14.0,
                        currencyFontSize: 12.0,
                        alignment: MainAxisAlignment.end,
                        showDecimals: true,
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 32),

            // Daily average by category
            DailyAverageByCategoryWidget(trip: trip),

            const SizedBox(height: 32),

            // 4. BY CATEGORY (chart widget prints its own bold title)
            CategoriesPieChart(trip: trip),
          ],
        ),
      ),
    );
  }
}
