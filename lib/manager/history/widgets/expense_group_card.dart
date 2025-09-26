import 'package:flutter/material.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_header.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import '../../details/pages/expense_group_detail_page.dart';

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
  Future<void> _onArchiveToggle() async {
    // Delegate actual archive/unarchive persistence to the parent handler.
    // The parent (history page) is responsible for calling storage helpers
    // and refreshing the canonical group state.
    await onArchiveToggle(trip.id, !trip.archived);
  }

  final ExpenseGroup trip;
  final Future<void> Function(String groupId, bool archived) onArchiveToggle;
  final String? searchQuery;

  const ExpenseGroupCard({
    super.key,
    required this.trip,
    required this.onArchiveToggle,
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
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExpenseGroupDetailPage(trip: trip),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ExpenseGroupAvatar(
                    trip: trip,
                    size: 48,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer,
                  ),
                  // Left: Circle with initials
                  const SizedBox(width: 16),
                  // Center: Title, participants, dates
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildHighlightedTitle(context)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildParticipantsRow(context),
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
