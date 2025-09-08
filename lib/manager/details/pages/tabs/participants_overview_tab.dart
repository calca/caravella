import 'package:flutter/material.dart';
import '../../../../data/model/expense_group.dart';
import 'usecase/settlements_logic.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../widgets/group_header.dart'; // ParticipantAvatar
import 'package:intl/intl.dart';
import '../../widgets/stat_card.dart';
import '../../../../widgets/currency_display.dart';
import '../../../../data/model/expense_participant.dart';

/// Participants tab: per participant totals, contribution percentages and settlements.
class ParticipantsOverviewTab extends StatelessWidget {
  final ExpenseGroup trip;
  const ParticipantsOverviewTab({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    final settlements = computeSettlements(trip);
    final idToName = {for (final p in trip.participants) p.id: p.name};

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
    final participantsCount = trip.participants.length;
    final avgPerPerson = participantsCount == 0
        ? 0.0
        : totalAll / participantsCount;
    final contributionEntries = trip.participants.map((p) {
      final total = trip.expenses
          .where((e) => e.paidBy.id == p.id)
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
          const SizedBox(height: 8),
          _AveragePerPersonRow(
            average: avgPerPerson,
            currency: trip.currency,
            participants: trip.participants,
            count: participantsCount,
          ),
          const SizedBox(height: 24),
          // Top summary: per participant card with avatar, total, %, and owes info
          ...contributionEntries.map((e) {
            // Build owes summary for this participant (from settlements)
            final owes = settlements
                .where((s) => s.fromId == e.participant.id)
                .toList();
            String? subtitle; // unused when using spans
            List<InlineSpan>? subtitleSpans;
            if (owes.isNotEmpty) {
              final spans = <InlineSpan>[];
              // Prefix connector (localized), normal weight
              spans.add(TextSpan(text: gloc.owes_to));
              for (int i = 0; i < owes.length; i++) {
                final s = owes[i];
                final to = idToName[s.toId] ?? s.toId;
                final amount = fmtCurrency(s.amount);
                // Bold: ' destinatario importo' (note leading space)
                spans.add(
                  TextSpan(
                    text: '$to $amount',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                );
                if (i < owes.length - 1) {
                  // Separator as normal text
                  spans.add(const TextSpan(text: ', '));
                }
              }
              subtitleSpans = spans;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StatCard(
                title: e.participant.name,
                value: e.total,
                currency: trip.currency,
                subtitle: subtitle,
                subtitleSpans: subtitleSpans,
                leading: ParticipantAvatar(
                  participant: e.participant,
                  size: 48,
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

class _AveragePerPersonRow extends StatelessWidget {
  final double average;
  final String currency;
  final List<ExpenseParticipant> participants;
  final int count;
  const _AveragePerPersonRow({
    required this.average,
    required this.currency,
    required this.participants,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final label = gen.AppLocalizations.of(context).average_per_person;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              CurrencyDisplay(
                value: average,
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
      ],
    );
  }
}
