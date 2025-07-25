import 'package:flutter/material.dart';
import '../../../data/expense_group.dart';
import '../../../widgets/currency_display.dart';
import '../../../widgets/base_card.dart';
import '../../../app_localizations.dart';
import '../../../state/locale_notifier.dart';
import '../../details/expense_group_detail_page.dart';

class ExpenseGroupCard extends StatelessWidget {
  final ExpenseGroup trip;
  final Function(ExpenseGroup) onTripUpdated;
  final Function(ExpenseGroup) onTripOptionsPressed;

  const ExpenseGroupCard({
    super.key,
    required this.trip,
    required this.onTripUpdated,
    required this.onTripOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final total =
        trip.expenses.fold<double>(0, (sum, e) => sum + (e.amount ?? 0));

    return Dismissible(
      key: ValueKey(trip.title +
          (trip.startDate?.toIso8601String() ??
              trip.timestamp.toIso8601String())),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(context),
      confirmDismiss: (_) => _confirmArchive(context),
      onDismissed: (_) => _onArchiveToggle(),
      child: GestureDetector(
        onLongPress: () => onTripOptionsPressed(trip),
        child: BaseCard(
          noBorder: true,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          // backgroundColor centralizzato nel tema
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ExpenseGroupDetailPage(trip: trip),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con titolo e stato
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            trip.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Icona stato (pinned, archiviato, attivo)
                  _buildStatusIcon(context),
                ],
              ),
              const SizedBox(height: 12),
              // Partecipanti e data
              _buildParticipantsRow(context),
              const SizedBox(height: 6),
              _buildDateRow(context),
              const SizedBox(height: 12),
              // Totale spese
              _buildTotalExpensesContainer(context, total),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);

    final isArchived = trip.archived;
    final backgroundColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final iconData =
        isArchived ? Icons.unarchive_outlined : Icons.archive_outlined;
    final actionText = isArchived ? loc.get('unarchive') : loc.get('archive');

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: Theme.of(context).colorScheme.onSurface,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            actionText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmArchive(BuildContext context) async {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);

    final isArchived = trip.archived;
    final actionText = isArchived ? loc.get('unarchive') : loc.get('archive');
    final confirmText =
        isArchived ? loc.get('unarchive_confirm') : loc.get('archive_confirm');

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              isArchived ? Icons.unarchive_rounded : Icons.archive_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(actionText),
          ],
        ),
        content: Text(
          '$confirmText "${trip.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.get('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  void _onArchiveToggle() {
    final updatedTrip = trip.copyWith(archived: !trip.archived);
    onTripUpdated(updatedTrip);
  }

  Widget _buildStatusIcon(BuildContext context) {
    if (trip.pinned) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.push_pin_outlined,
          size: 20,
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    } else if (trip.archived) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.archive_outlined,
          size: 20,
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildDateRow(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            trip.startDate != null && trip.endDate != null
                ? '${trip.startDate!.day}/${trip.startDate!.month}/${trip.startDate!.year} - ${trip.endDate!.day}/${trip.endDate!.month}/${trip.endDate!.year}'
                : '-',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsRow(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.group_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            trip.participants.length <= 2
                ? trip.participants.map((p) => p.name).join(', ')
                : '${trip.participants.length} partecipanti',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalExpensesContainer(BuildContext context, double total) {
    return Row(
      children: [
        const Spacer(),
        CurrencyDisplay(
          value: total,
          currency: trip.currency,
          valueFontSize: 20.0,
          currencyFontSize: 16.0,
          alignment: MainAxisAlignment.end,
          showDecimals: true,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ],
    );
  }
}
