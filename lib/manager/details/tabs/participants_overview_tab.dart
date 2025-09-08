import 'package:flutter/material.dart';
import '../../../data/model/expense_group.dart';
import '../../../widgets/currency_display.dart';
import 'settlements_logic.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../widgets/group_header.dart'; // ParticipantAvatar
import 'package:intl/intl.dart';
import '../tabs/widgets/stat_card.dart';

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
    }).toList()..sort((a, b) => b.total.compareTo(a.total));

    // Helper for currency formatting in subtitles
    String fmtCurrency(double amount) {
      final locale = Localizations.maybeLocaleOf(context)?.toString();
      try {
        if (locale != null) {
          return NumberFormat.currency(
            locale: locale,
            symbol: trip.currency,
          ).format(amount);
        }
      } catch (_) {}
      return '${amount.toStringAsFixed(2)}${trip.currency}';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top summary: per participant card with avatar, total, %, and owes info
          ...contributionEntries.map((e) {
            // Build owes summary for this participant (from settlements)
            final owes = settlements
                .where((s) => s['from'] == e.participant.name)
                .toList();
            String subtitle;
            final pctText = '${e.pct.toStringAsFixed(1)}%';
            if (owes.isNotEmpty) {
              final parts = owes.map(
                (s) => '${s['to']} (${fmtCurrency(s['amount'] as double)})',
              );
              // Put settlement on a new line, with localized connector
              subtitle = '$pctText\n${gloc.owes_to}${parts.join(', ')}';
            } else {
              subtitle = pctText;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StatCard(
                title: e.participant.name,
                value: e.total,
                currency: trip.currency,
                subtitle: subtitle,
                leading: ParticipantAvatar(
                  participant: e.participant,
                  size: 36,
                ),
                percent: e.pct.toDouble(),
                inlineHeader: true,
              ),
            );
          }),
        ],
      ),
    );
  }
}
