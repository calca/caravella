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

    // No local helpers needed here; formatting handled in sub-widgets

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
            final owes = settlements
                .where((s) => s.fromId == e.participant.id)
                .toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ParticipantStatCard(
                participant: e.participant,
                total: e.total,
                percent: e.pct.toDouble(),
                currency: trip.currency,
                owes: owes,
                idToName: idToName,
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

class _ParticipantStatCard extends StatefulWidget {
  final ExpenseParticipant participant;
  final double total;
  final double percent;
  final String currency;
  final List<Settlement> owes;
  final Map<String, String> idToName;

  const _ParticipantStatCard({
    required this.participant,
    required this.total,
    required this.percent,
    required this.currency,
    required this.owes,
    required this.idToName,
  });

  @override
  State<_ParticipantStatCard> createState() => _ParticipantStatCardState();
}

class _ParticipantStatCardState extends State<_ParticipantStatCard> {
  bool _expanded = false;

  String _fmtCurrency(BuildContext context, double amount) {
    final locale = Localizations.maybeLocaleOf(context)?.toString();
    try {
      if (locale != null) {
        return NumberFormat.currency(
          locale: locale,
          symbol: widget.currency,
        ).format(amount);
      }
    } catch (_) {}
    return '${amount.toStringAsFixed(2)}${widget.currency}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build per-line debts starting with "a " and bold content
    final owes = widget.owes;
    final totalItems = owes.length;
    final showToggle = totalItems > 3;
    final loc = gen.AppLocalizations.of(context);

    List<InlineSpan> buildLines({required bool expanded}) {
      final spans = <InlineSpan>[];
      if (totalItems == 0) return spans;

      final visibleCount = expanded
          ? totalItems
          : (showToggle ? 2 : totalItems);
      for (int i = 0; i < visibleCount; i++) {
        final s = owes[i];
        final toName = widget.idToName[s.toId] ?? s.toId;
        final amount = _fmtCurrency(context, s.amount);
        spans.add(
          TextSpan(
            text: loc.debt_prefix_to,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: '$toName $amount',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        if (i < visibleCount - 1) {
          spans.add(const TextSpan(text: '\n'));
        }
      }
      if (showToggle && !expanded) {
        // Add a newline then an inline More button after the second line
        spans.add(const TextSpan(text: '\n'));
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => setState(() => _expanded = true),
              child: Text(
                loc.more,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      } else if (showToggle && expanded) {
        spans.add(const TextSpan(text: '\n'));
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => setState(() => _expanded = false),
              child: Text(
                loc.less,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }
      return spans;
    }

    final subtitleSpans = buildLines(expanded: _expanded);

    return StatCard(
      title: widget.participant.name,
      value: widget.total,
      currency: widget.currency,
      subtitleSpans: subtitleSpans,
      subtitleMaxLines: _expanded ? 100 : 3,
      leading: ParticipantAvatar(participant: widget.participant, size: 48),
      percent: widget.percent,
      inlineHeader: true,
    );
  }
}
