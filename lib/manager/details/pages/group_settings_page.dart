import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';

import '../../group/pages/expenses_group_edit_page.dart';
import '../../group/group_edit_mode.dart';
import '../../../settings/widgets/settings_section.dart';
import '../../../settings/widgets/settings_card.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(gloc.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          0,
          0,
          0,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        children: [
          // Group section
          SettingsSection(
            title: gloc.group,
            description: gloc.edit_group_desc,
            children: [
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                child: ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(gloc.segment_general, style: textTheme.titleMedium),
                  subtitle: Text(gloc.settings_general_desc, style: textTheme.bodySmall),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openEditPage(context, 0),
                ),
              ),
              const SizedBox(height: 8),
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                child: ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: Text(gloc.participants, style: textTheme.titleMedium),
                  subtitle: Text(gloc.participants_description, style: textTheme.bodySmall),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openEditPage(context, 1),
                ),
              ),
              const SizedBox(height: 8),
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                child: ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(gloc.categories, style: textTheme.titleMedium),
                  subtitle: Text(gloc.categories_description, style: textTheme.bodySmall),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openEditPage(context, 2),
                ),
              ),
              const SizedBox(height: 8),
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                child: ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: Text(gloc.segment_other, style: textTheme.titleMedium),
                  subtitle: Text(gloc.other_settings_desc, style: textTheme.bodySmall),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openEditPage(context, 3),
                ),
              ),
            ],
          ),

          // Export and Share section
          SettingsSection(
            title: gloc.export_share,
            description: gloc.export_options_desc,
            children: [
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                child: ListTile(
                  leading: Icon(
                    Icons.ios_share_outlined,
                    color: trip.expenses.isEmpty
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
                        : null,
                  ),
                  title: Text(
                    gloc.export_options,
                    style: textTheme.titleMedium?.copyWith(
                      color: trip.expenses.isEmpty
                          ? colorScheme.onSurface.withValues(alpha: 0.38)
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    gloc.export_options_desc,
                    style: textTheme.bodySmall?.copyWith(
                      color: trip.expenses.isEmpty
                          ? colorScheme.onSurface.withValues(alpha: 0.38)
                          : null,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: trip.expenses.isEmpty
                        ? colorScheme.outline.withValues(alpha: 0.38)
                        : null,
                  ),
                  onTap: trip.expenses.isEmpty ? null : () => _openExportOptions(context),
                ),
              ),
            ],
          ),

          // Dangerous section
          SettingsSection(
            title: gloc.danger_zone,
            description: gloc.danger_zone_desc,
            children: [
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                child: ListTile(
                  leading: Icon(
                    trip.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
                  ),
                  title: Text(
                    trip.archived ? gloc.unarchive : gloc.archive,
                    style: textTheme.titleMedium,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _handleArchiveToggle(context),
                ),
              ),
              const SizedBox(height: 8),
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                child: ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                  ),
                  title: Text(
                    gloc.delete_group,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _handleDelete(context),
                ),
              ),
            ],
          ),
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
