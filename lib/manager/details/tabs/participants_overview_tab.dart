import 'package:flutter/material.dart';
import '../../../data/model/expense_group.dart';
import '../../../widgets/currency_display.dart';
import 'settlements_logic.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Participants tab: per participant totals, contribution percentages and settlements.
class ParticipantsOverviewTab extends StatelessWidget {
  final ExpenseGroup trip;
  const ParticipantsOverviewTab({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    final settlements = computeSettlements(trip);

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

    final totalAll = trip.expenses.fold<double>(
      0,
      (s, e) => s + (e.amount ?? 0),
    );
    final contributionEntries = trip.participants.map((p) {
      final total = trip.expenses
          .where((e) => e.paidBy.name == p.name)
          .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
      final pct = totalAll == 0 ? 0 : (total / totalAll) * 100;
      return (participant: p, total: total, pct: pct);
    }).toList()..sort((a, b) => b.pct.compareTo(a.pct));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Totals per participant
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
          const SizedBox(height: 28),
          // Contribution percentages
          Text(
            gloc.contribution_percentages,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...contributionEntries.map(
            (e) => Padding(
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
                    width: 90,
                    child: LinearProgressIndicator(
                      value: (e.pct / 100).clamp(0, 1),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                      color: theme.colorScheme.surfaceDim,
                      backgroundColor: theme.colorScheme.surfaceDim.withAlpha(
                        (0.4 * 255).toInt(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${e.pct.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Settlements
          Text(
            gloc.settlement,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (settlements.isEmpty)
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
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
            )
          else
            ...settlements.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: s['from'],
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                            TextSpan(
                              text: gloc.owes_to,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextSpan(
                              text: s['to'],
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CurrencyDisplay(
                      value: s['amount'],
                      currency: trip.currency,
                      valueFontSize: 14.0,
                      currencyFontSize: 12.0,
                      alignment: MainAxisAlignment.end,
                      showDecimals: true,
                      color: theme.colorScheme.error,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
