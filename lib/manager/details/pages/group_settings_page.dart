import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';

import '../../group/pages/expenses_group_edit_page.dart';
import '../../group/group_edit_mode.dart';

class GroupSettingsPage extends StatelessWidget {
  final ExpenseGroup trip;
  final VoidCallback? onGroupUpdated;
  final VoidCallback? onGroupDeleted;
  final VoidCallback? onExportOptions;

  const GroupSettingsPage({
    super.key,
    required this.trip,
    this.onGroupUpdated,
    this.onGroupDeleted,
    this.onExportOptions,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(gloc.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          // Group section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              gloc.group,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: colorScheme.onSurface,
            ),
            title: Text(gloc.segment_general),
            subtitle: Text(gloc.settings_general_desc),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
            onTap: () => _openEditPage(context, 0),
          ),
          ListTile(
            leading: Icon(
              Icons.people_outline,
              color: colorScheme.onSurface,
            ),
            title: Text(gloc.participants),
            subtitle: Text(gloc.participants_description),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
            onTap: () => _openEditPage(context, 1),
          ),
          ListTile(
            leading: Icon(
              Icons.label_outline,
              color: colorScheme.onSurface,
            ),
            title: Text(gloc.categories),
            subtitle: Text(gloc.categories_description),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
            onTap: () => _openEditPage(context, 2),
          ),
          ListTile(
            leading: Icon(
              Icons.tune_outlined,
              color: colorScheme.onSurface,
            ),
            title: Text(gloc.segment_other),
            subtitle: Text(gloc.other_settings_desc),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
            onTap: () => _openEditPage(context, 3),
          ),
          const Divider(height: 32),

          // Export and Share section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              gloc.export_share,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.ios_share_outlined,
              color: trip.expenses.isEmpty
                  ? colorScheme.onSurface.withValues(alpha: 0.38)
                  : colorScheme.onSurface,
            ),
            title: Text(
              gloc.export_options,
              style: trip.expenses.isEmpty
                  ? TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.38),
                    )
                  : null,
            ),
            subtitle: Text(
              gloc.export_options_desc,
              style: trip.expenses.isEmpty
                  ? TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.38),
                    )
                  : null,
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: trip.expenses.isEmpty
                  ? colorScheme.outline.withValues(alpha: 0.38)
                  : colorScheme.outline,
            ),
            onTap: trip.expenses.isEmpty ? null : () => _openExportOptions(context),
          ),
          const Divider(height: 32),

          // Dangerous section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              gloc.danger_zone,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              trip.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
              color: colorScheme.onSurface,
            ),
            title: Text(trip.archived ? gloc.unarchive : gloc.archive),
            onTap: () => _handleArchiveToggle(context),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: colorScheme.error,
            ),
            title: Text(
              gloc.delete_group,
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () => _handleDelete(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _openEditPage(BuildContext context, int initialTab) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => ExpensesGroupEditPage(
          trip: trip,
          mode: GroupEditMode.edit,
          initialTab: initialTab,
        ),
      ),
    );
    
    if (result == true && context.mounted) {
      onGroupUpdated?.call();
    }
  }

  void _openExportOptions(BuildContext context) {
    if (onExportOptions != null) {
      onExportOptions!();
    }
  }

  Future<void> _handleArchiveToggle(BuildContext context) async {
    final gloc = gen.AppLocalizations.of(context);
    final groupNotifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
    
    await groupNotifier.updateGroupArchive(trip.id, !trip.archived);
    
    if (!context.mounted) return;
    
    AppToast.show(
      context,
      trip.archived ? gloc.unarchived_with_undo : gloc.archived_with_undo,
      type: ToastType.success,
    );
    
    onGroupUpdated?.call();
  }

  Future<void> _handleDelete(BuildContext context) async {
    final gloc = gen.AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => Material3Dialog(
        icon: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
          size: 24,
        ),
        title: Text(gloc.delete_group),
        content: Text(gloc.delete_group_confirm),
        actions: [
          Material3DialogActions.cancel(
            dialogCtx,
            gloc.cancel,
          ),
          Material3DialogActions.destructive(
            dialogCtx,
            gloc.delete,
            onPressed: () => Navigator.of(dialogCtx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final groupNotifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
      
      await ExpenseGroupStorageV2.deleteGroup(trip.id);
      ExpenseGroupStorageV2.forceReload();
      groupNotifier.notifyGroupDeleted(trip.id);

      if (!context.mounted) return;
      
      onGroupDeleted?.call();
      Navigator.of(context).pop(); // Close settings page
    }
  }
}
