import 'package:flutter/material.dart';
import '../../../data/model/expense_group.dart';
import '../../../widgets/currency_display.dart';
import '../../../widgets/base_card.dart';
import '../../details/expense_group_detail_page.dart';

class ExpenseGroupCard extends StatelessWidget {
  // Dismiss background for swipe actions
  Widget _buildDismissBackground(BuildContext context) {
    final isArchived = trip.archived;
    final backgroundColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;
    final iconData = isArchived
        ? Icons.unarchive_outlined
        : Icons.archive_outlined;
    final actionText = isArchived ? 'Unarchive' : 'Archive';
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: backgroundColor,
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

  // Confirm archive dialog (returns Future<bool?>)
  Future<bool?> _confirmArchive(BuildContext context) async {
    final isArchived = trip.archived;
    final actionText = isArchived ? 'Unarchive' : 'Archive';
    final confirmText = isArchived
        ? 'Do you want to unarchive'
        : 'Do you want to archive';
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(actionText),
        content: Text('$confirmText "${trip.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  // Archive toggle logic
  void _onArchiveToggle() {
    final updatedTrip = trip.copyWith(
      archived: !trip.archived,
      pinned: !trip.archived ? false : trip.pinned,
    );
    onTripUpdated(updatedTrip);
  }

  final ExpenseGroup trip;
  final Function(ExpenseGroup) onTripUpdated;
  final String? searchQuery;

  const ExpenseGroupCard({
    super.key,
    required this.trip,
    required this.onTripUpdated,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final total = trip.expenses.fold<double>(
      0,
      (sum, e) => sum + (e.amount ?? 0),
    );
    const radius = 16.0;
    final cardColor = Colors.transparent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(radius)),
        child: Dismissible(
          key: ValueKey(
            trip.title +
                (trip.startDate?.toIso8601String() ??
                    trip.timestamp.toIso8601String()),
          ),
          direction: DismissDirection.endToStart,
          background: _buildDismissBackground(context),
          secondaryBackground: _buildDismissBackground(context),
          confirmDismiss: (_) => _confirmArchive(context),
          onDismissed: (_) => _onArchiveToggle(),
          child: Container(
            color: cardColor,
            child: BaseCard(
              backgroundColor: Colors.transparent,
              noBorder: true,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExpenseGroupDetailPage(trip: trip),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Circle with initials
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getInitials(trip.title),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Center: Title, participants, dates
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildHighlightedTitle(context)),
                            _buildStatusIcon(context),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildParticipantsRow(context),
                        const SizedBox(height: 4),
                        _buildDateRow(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right: Total expenses
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedTitle(BuildContext context) {
    final title = trip.title;
    final query = searchQuery?.toLowerCase().trim();

    if (query == null || query.isEmpty) {
      return Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    final highlightStyle = baseStyle?.copyWith(
      backgroundColor: colorScheme.primaryContainer,
      color: colorScheme.onPrimaryContainer,
    );

    final lowerTitle = title.toLowerCase();
    final spans = <TextSpan>[];
    int currentIndex = 0;

    while (currentIndex < title.length) {
      final queryIndex = lowerTitle.indexOf(query, currentIndex);

      if (queryIndex == -1) {
        spans.add(
          TextSpan(text: title.substring(currentIndex), style: baseStyle),
        );
        break;
      }

      if (queryIndex > currentIndex) {
        spans.add(
          TextSpan(
            text: title.substring(currentIndex, queryIndex),
            style: baseStyle,
          ),
        );
      }

      spans.add(
        TextSpan(
          text: title.substring(queryIndex, queryIndex + query.length),
          style: highlightStyle,
        ),
      );
      currentIndex = queryIndex + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _getInitials(String title) {
    final words = title.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    } else {
      return (words[0].substring(0, 1) + words[1].substring(0, 1))
          .toUpperCase();
    }
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
          Icons.event_outlined,
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
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
          Icons.group_outlined,
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
