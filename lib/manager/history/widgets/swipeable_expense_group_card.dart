import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_header.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../../../data/expense_group_storage_v2.dart';
import '../../../widgets/currency_display.dart';
import '../../../widgets/base_card.dart';
import '../../../widgets/bottom_sheet_scaffold.dart';
import '../../../widgets/material3_dialog.dart';
import '../../details/pages/expense_group_detail_page.dart';

/// Expense group card with long-press contextual menu
class SwipeableExpenseGroupCard extends StatelessWidget {
  final ExpenseGroup trip;
  final Future<void> Function(String groupId, bool archived) onArchiveToggle;
  final String? searchQuery;

  const SwipeableExpenseGroupCard({
    super.key,
    required this.trip,
    required this.onArchiveToggle,
    this.searchQuery,
  });

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();

    final gloc = gen.AppLocalizations.of(context);
    final isArchived = trip.archived;
    final isPinned = trip.pinned;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => GroupBottomSheetScaffold(
        title: trip.title,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pin/Unpin action
            _MenuActionTile(
              icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              label: isPinned ? gloc.unpin : gloc.pin,
              color: colorScheme.tertiaryContainer,
              iconColor: colorScheme.onTertiaryContainer,
              onTap: () async {
                Navigator.pop(context);
                await _executePinAction(context);
              },
            ),
            const SizedBox(height: 12),
            // Archive/Unarchive action
            _MenuActionTile(
              icon: isArchived
                  ? Icons.unarchive_rounded
                  : Icons.archive_rounded,
              label: isArchived ? gloc.unarchive : gloc.archive,
              color: isArchived
                  ? colorScheme.primaryContainer
                  : colorScheme.secondaryContainer,
              iconColor: isArchived
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSecondaryContainer,
              onTap: () async {
                Navigator.pop(context);
                await _executeArchiveAction(context);
              },
            ),
            const SizedBox(height: 12),
            // Delete action
            _MenuActionTile(
              icon: Icons.delete_rounded,
              label: gloc.delete,
              color: colorScheme.errorContainer,
              iconColor: colorScheme.onErrorContainer,
              onTap: () async {
                Navigator.pop(context);
                await _executeDeleteAction(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executePinAction(BuildContext context) async {
    final isPinned = trip.pinned;
    final gloc = gen.AppLocalizations.of(context);
    final actionText = isPinned
        ? gloc.unpinned_with_undo
        : gloc.pinned_with_undo;

    await ExpenseGroupStorageV2.updateGroupPin(trip.id, !isPinned);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$actionText • ${trip.title}'),
        action: SnackBarAction(
          label: gloc.undo,
          onPressed: () async {
            await ExpenseGroupStorageV2.updateGroupPin(trip.id, isPinned);
          },
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _executeArchiveAction(BuildContext context) async {
    final isArchived = trip.archived;
    final gloc = gen.AppLocalizations.of(context);
    final actionText = isArchived
        ? gloc.unarchived_with_undo
        : gloc.archived_with_undo;

    // Execute action
    await onArchiveToggle(trip.id, !isArchived);

    // Show SnackBar with undo
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$actionText • ${trip.title}'),
        action: SnackBarAction(
          label: gloc.undo,
          onPressed: () async {
            await onArchiveToggle(trip.id, isArchived);
          },
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _executeDeleteAction(BuildContext context) async {
    final gloc = gen.AppLocalizations.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Material3Dialog(
        title: Text(gloc.delete_trip),
        content: Text(gloc.delete_trip_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(gloc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(gloc.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Execute deletion
    await ExpenseGroupStorageV2.deleteGroup(trip.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${gloc.deleted_with_undo} • ${trip.title}'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = trip.expenses.fold<double>(
      0,
      (sum, e) => sum + (e.amount ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: _buildCard(context, total),
    );
  }

  Widget _buildCard(BuildContext context, double total) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExpenseGroupDetailPage(trip: trip),
          ),
        );
      },
      onLongPress: () => _showContextMenu(context),
      borderRadius: BorderRadius.circular(16),
      child: BaseCard(
        backgroundColor: Theme.of(context).colorScheme.surface,
        noBorder: false,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExpenseGroupAvatar(
              trip: trip,
              size: 48,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            ),
            const SizedBox(width: 16),
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

/// Menu action tile for bottom sheet
class _MenuActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: iconColor),
          ],
        ),
      ),
    );
  }
}
