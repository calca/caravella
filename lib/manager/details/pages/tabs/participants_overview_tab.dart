import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'usecase/settlements_logic.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:share_plus/share_plus.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/group_header.dart';

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
                trip: trip,
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
  final ExpenseGroup trip;

  const _ParticipantStatCard({
    required this.participant,
    required this.total,
    required this.percent,
    required this.currency,
    required this.owes,
    required this.idToName,
    required this.trip,
  });

  @override
  State<_ParticipantStatCard> createState() => _ParticipantStatCardState();
}

class _ParticipantStatCardState extends State<_ParticipantStatCard> {
  bool _expanded = false;

  String _buildReminderMessage(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final participantName = widget.participant.name;
    final groupName = widget.trip.title;
    final owes = widget.owes;

    if (owes.isEmpty) {
      // No debts, return empty (button should be hidden)
      return '';
    }

    if (owes.length == 1) {
      // Single debt
      final debt = owes.first;
      final creditorName = widget.idToName[debt.toId] ?? debt.toId;
      final amount = CurrencyDisplay.formatCurrencyText(
        debt.amount,
        widget.trip.currency,
        showDecimals: true,
      );
      return loc.reminder_message_single(
        participantName,
        amount,
        creditorName,
        groupName,
      );
    } else {
      // Multiple debts
      final debtsList = owes
          .map((debt) {
            final creditorName = widget.idToName[debt.toId] ?? debt.toId;
            final amount = CurrencyDisplay.formatCurrencyText(
              debt.amount,
              widget.trip.currency,
              showDecimals: true,
            );
            return '• $amount ${loc.debt_prefix_to}$creditorName';
          })
          .join('\n');

      return loc.reminder_message_multiple(
        participantName,
        groupName,
        debtsList,
      );
    }
  }

  Future<void> _shareReminder() async {
    final message = _buildReminderMessage(context);
    if (message.isEmpty) return;

    try {
      await SharePlus.instance.share(ShareParams(text: message));
    } catch (e) {
      // Silently handle errors
      debugPrint('Error sharing reminder: $e');
    }
  }

  void _showReminderBottomSheet() {
    final message = _buildReminderMessage(context);
    if (message.isEmpty) return;

    final loc = gen.AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GroupBottomSheetScaffold(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Message preview
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            // Send button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _shareReminder();
                },
                icon: const Icon(Icons.send),
                label: Text(loc.send_reminder),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = gen.AppLocalizations.of(context);

    // Build per-line debts starting with "a " and bold content
    final owes = widget.owes;
    final totalItems = owes.length;
    final showToggle = totalItems > 3;

    List<InlineSpan> buildLines({required bool expanded}) {
      final spans = <InlineSpan>[];
      if (totalItems == 0) return spans;

      final visibleCount = expanded
          ? totalItems
          : (showToggle ? 2 : totalItems);
      for (int i = 0; i < visibleCount; i++) {
        final s = owes[i];
        final toName = widget.idToName[s.toId] ?? s.toId;
        spans.add(
          TextSpan(
            text: loc.debt_prefix_to,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: '$toName ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: CurrencyDisplay(
              value: s.amount,
              currency: widget.currency,
              showDecimals: true,
              valueFontSize: 12,
              currencyFontSize: 10,
              alignment: MainAxisAlignment.start,
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

    // Only show long-press gesture if participant has debts
    final hasDebts = owes.isNotEmpty;

    return GestureDetector(
      onLongPress: hasDebts ? _showReminderBottomSheet : null,
      child: StatCard(
        title: widget.participant.name,
        value: widget.total,
        currency: widget.currency,
        subtitleSpans: subtitleSpans,
        subtitleMaxLines: _expanded ? 100 : 3,
        leading: ParticipantAvatar(participant: widget.participant, size: 48),
        percent: widget.percent,
        inlineHeader: true,
      ),
    );
  }
}
