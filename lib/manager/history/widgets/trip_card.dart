import 'package:flutter/material.dart';
import '../../../data/expense_group.dart';
import '../../../widgets/currency_display.dart';
import '../../../widgets/base_card.dart';
import '../../details/trip_detail_page.dart';

class TripCard extends StatelessWidget {
  final ExpenseGroup trip;
  final Function(ExpenseGroup) onTripDeleted;
  final Function(ExpenseGroup) onTripOptionsPressed;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTripDeleted,
    required this.onTripOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isFuture = trip.startDate?.isAfter(now) ?? false;
    final isPast = trip.endDate?.isBefore(now) ?? false;
    final total =
        trip.expenses.fold<double>(0, (sum, e) => sum + (e.amount ?? 0));

    // Colori per stato
    Color statusColor;
    String statusText;

    if (isFuture) {
      statusColor = Theme.of(context).colorScheme.tertiary;
      statusText = 'Futuro';
    } else if (isPast) {
      statusColor = Theme.of(context).colorScheme.outline;
      statusText = 'Completato';
    } else {
      statusColor = Theme.of(context).colorScheme.primary;
      statusText = 'In corso';
    }

    return Dismissible(
      key: ValueKey(trip.title +
          (trip.startDate?.toIso8601String() ??
              trip.timestamp.toIso8601String())),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(context),
      confirmDismiss: (_) => _confirmDismiss(context),
      onDismissed: (_) => onTripDeleted(trip),
      child: GestureDetector(
        onLongPress: () => onTripOptionsPressed(trip),
        child: BaseCard(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          backgroundColor: Theme.of(context).colorScheme.surface,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TripDetailPage(trip: trip),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
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
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Statistiche quick
                  _buildStatChip(
                    Icons.people_rounded,
                    '${trip.participants.length}',
                    context,
                  ),
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
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_rounded,
            color: Theme.of(context).colorScheme.onError,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            'Elimina',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDismiss(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            const Text('Elimina gruppo'),
          ],
        ),
        content: Text(
          'Vuoi davvero eliminare "${trip.title}"?\n\nQuesta azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHigh
            .withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Spacer(),
          CurrencyDisplay(
            value: total,
            currency: trip.currency,
            valueFontSize: 18.0,
            currencyFontSize: 14.0,
            alignment: MainAxisAlignment.end,
            showDecimals: true,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
