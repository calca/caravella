// Long-press options shared by every group card of the Groups page and of
// group search: favorite, archive, delete (with toast feedback).
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'history_options_sheet.dart';

/// Opens the options sheet for [trip] (favorite, archive, delete).
void showGroupOptionsSheet(
  BuildContext context, {
  required ExpenseGroup trip,
  required Future<void> Function(String groupId, bool archived) onArchiveToggle,
  VoidCallback? onDelete,
  VoidCallback? onPin,
}) {
  HapticFeedback.mediumImpact();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetCtx) => HistoryOptionsSheet(
      trip: trip,
      onPinToggle: () async {
        final nav = Navigator.of(sheetCtx);
        nav.pop();
        await _executePinAction(context, trip, onPin);
      },
      onArchiveToggle: () async {
        final nav = Navigator.of(sheetCtx);
        nav.pop();
        await _executeArchiveAction(context, trip, onArchiveToggle);
      },
      onDelete: () async {
        final nav = Navigator.of(sheetCtx);
        nav.pop();
        await _executeDeleteAction(context, trip, onDelete);
      },
    ),
  );
}

Future<void> _executePinAction(
  BuildContext context,
  ExpenseGroup trip,
  VoidCallback? onPin,
) async {
  final isPinned = trip.pinned;
  final gloc = gen.AppLocalizations.of(context);
  final actionText = isPinned ? gloc.unpinned_with_undo : gloc.pinned_with_undo;

  // Use notifier to update pin state (handles storage + shortcuts)
  final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
  await notifier.updateGroupPin(trip.id, !isPinned);

  // Trigger reload callback if provided
  onPin?.call();

  if (!context.mounted) return;
  AppToast.show(
    context,
    '$actionText • ${trip.title}',
    type: ToastType.info,
    duration: const Duration(seconds: 4),
  );
}

Future<void> _executeArchiveAction(
  BuildContext context,
  ExpenseGroup trip,
  Future<void> Function(String groupId, bool archived) onArchiveToggle,
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
  if (context.mounted) {
    AppToast.show(
      context,
      '$actionText • ${trip.title}',
      type: ToastType.info,
      duration: const Duration(seconds: 4),
    );
  }
}

Future<void> _executeDeleteAction(
  BuildContext context,
  ExpenseGroup trip,
  VoidCallback? onDelete,
) async {
  final gloc = gen.AppLocalizations.of(context);

  // Show confirmation dialog
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => Material3Dialog(
      title: Text(gloc.delete_group),
      content: Text(gloc.delete_group_confirm),
      actions: [
        Material3DialogActions.cancel(context, gloc.cancel),
        Material3DialogActions.destructive(
          context,
          gloc.delete,
          onPressed: () => Navigator.pop(context, true),
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
  AppToast.show(
    context,
    '${gloc.deleted_with_undo} • ${trip.title}',
    type: ToastType.success,
    duration: const Duration(seconds: 3),
  );
}
