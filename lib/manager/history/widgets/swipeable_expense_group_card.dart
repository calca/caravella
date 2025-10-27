import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_header.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../../../data/expense_group_storage_v2.dart';
import '../../../state/expense_group_notifier.dart';
import '../../../widgets/currency_display.dart';
import '../../../widgets/base_card.dart';
import '../../../widgets/material3_dialog.dart';
import '../../../widgets/app_toast.dart';
import '../../details/pages/expense_group_detail_page.dart';
import 'history_options_sheet.dart';

/// Expense group card with long-press contextual menu
class SwipeableExpenseGroupCard extends StatelessWidget {
  final ExpenseGroup trip;
  final Future<void> Function(String groupId, bool archived) onArchiveToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final String? searchQuery;

  const SwipeableExpenseGroupCard({
    super.key,
    required this.trip,
    required this.onArchiveToggle,
    this.onDelete,
    this.onPin,
    this.searchQuery,
  });

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();

    // Capture the scaffold messenger before showing the sheet
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => HistoryOptionsSheet(
        trip: trip,
        onPinToggle: () async {
          final nav = Navigator.of(sheetCtx);
          nav.pop();
          await _executePinAction(context, messenger);
        },
        onArchiveToggle: () async {
          final nav = Navigator.of(sheetCtx);
          nav.pop();
          await _executeArchiveAction(context, messenger);
        },
        onDelete: () async {
          final nav = Navigator.of(sheetCtx);
          nav.pop();
          await _executeDeleteAction(context, messenger);
        },
      ),
    );
  }

  Future<void> _executePinAction(
    BuildContext context,
    ScaffoldMessengerState messenger,
  ) async {
    final isPinned = trip.pinned;
    final gloc = gen.AppLocalizations.of(context);
    final actionText = isPinned
        ? gloc.unpinned_with_undo
        : gloc.pinned_with_undo;

    // Use notifier to update pin state (handles storage + shortcuts)
    final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
    await notifier.updateGroupPin(trip.id, !isPinned);

    // Trigger reload callback if provided
    onPin?.call();

    if (!context.mounted) return;
    AppToast.showFromMessenger(
      messenger,
      '$actionText • ${trip.title}',
      type: ToastType.info,
      duration: const Duration(seconds: 4),
      onUndo: () async {
        await notifier.updateGroupPin(trip.id, isPinned);
        // Reload again after undo
        onPin?.call();
      },
    );
  }

  Future<void> _executeArchiveAction(
    BuildContext context,
    ScaffoldMessengerState messenger,
  ) async {
    final isArchived = trip.archived;
    final gloc = gen.AppLocalizations.of(context);
    final actionText = isArchived
        ? gloc.unarchived_with_undo
        : gloc.archived_with_undo;

    // Execute action
    await onArchiveToggle(trip.id, !isArchived);

    // Small delay to ensure UI has updated
    await Future.delayed(const Duration(milliseconds: 100));

    // Show AppToast with undo
    AppToast.showFromMessenger(
      messenger,
      '$actionText • ${trip.title}',
      type: ToastType.info,
      duration: const Duration(seconds: 4),
      onUndo: () async {
        await onArchiveToggle(trip.id, isArchived);
      },
    );
  }

  Future<void> _executeDeleteAction(
    BuildContext context,
    ScaffoldMessengerState messenger,
  ) async {
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

    // Notify the ExpenseGroupNotifier about the deletion
    if (context.mounted) {
      final notifier = context.read<ExpenseGroupNotifier>();
      notifier.notifyGroupDeleted(trip.id);
    }

    // Trigger reload callback if provided
    onDelete?.call();

    if (!context.mounted) return;
    AppToast.showFromMessenger(
      messenger,
      '${gloc.deleted_with_undo} • ${trip.title}',
      type: ToastType.success,
      duration: const Duration(seconds: 3),
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
        noBorder: true,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(16),
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
