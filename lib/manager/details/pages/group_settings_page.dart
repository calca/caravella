import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';

import '../../group/pages/expense_group_general_page.dart';
import '../../group/pages/expense_group_participants_page.dart';
import '../../group/pages/expense_group_categories_page.dart';
import '../../group/pages/expense_group_other_page.dart';
import '../../group/group_edit_mode.dart';
import '../../../settings/widgets/settings_section.dart';
import '../../../settings/widgets/settings_card.dart';

class GroupSettingsPage extends StatefulWidget {
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
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  late ExpenseGroup _currentTrip;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
  }

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
                  title: Text(
                    gloc.segment_general,
                    style: textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    gloc.settings_general_desc,
                    style: textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openGeneralPage(context),
                ),
              ),
              const SizedBox(height: 8),
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                child: ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: Text(gloc.participants, style: textTheme.titleMedium),
                  subtitle: Text(
                    gloc.participants_description,
                    style: textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openParticipantsPage(context),
                ),
              ),
              const SizedBox(height: 8),
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                child: ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(gloc.categories, style: textTheme.titleMedium),
                  subtitle: Text(
                    gloc.categories_description,
                    style: textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openCategoriesPage(context),
                ),
              ),
              const SizedBox(height: 8),
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                child: ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: Text(gloc.segment_other, style: textTheme.titleMedium),
                  subtitle: Text(
                    gloc.other_settings_desc,
                    style: textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openOtherPage(context),
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
                    color: _currentTrip.expenses.isEmpty
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
                        : null,
                  ),
                  title: Text(
                    gloc.export_options,
                    style: textTheme.titleMedium?.copyWith(
                      color: _currentTrip.expenses.isEmpty
                          ? colorScheme.onSurface.withValues(alpha: 0.38)
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    gloc.export_options_desc,
                    style: textTheme.bodySmall?.copyWith(
                      color: _currentTrip.expenses.isEmpty
                          ? colorScheme.onSurface.withValues(alpha: 0.38)
                          : null,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: _currentTrip.expenses.isEmpty
                        ? colorScheme.outline.withValues(alpha: 0.38)
                        : null,
                  ),
                  onTap: _currentTrip.expenses.isEmpty
                      ? null
                      : () => _openExportOptions(context),
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
                    _currentTrip.archived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                  ),
                  title: Text(
                    _currentTrip.archived ? gloc.unarchive : gloc.archive,
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
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
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

  Future<void> _openGeneralPage(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => ExpenseGroupGeneralPage(
          trip: _currentTrip,
          mode: GroupEditMode.edit,
        ),
      ),
    );

    if (result == true && context.mounted) {
      // Ricarica il gruppo aggiornato
      final updatedGroup = await ExpenseGroupStorageV2.getTripById(
        _currentTrip.id,
      );
      if (updatedGroup != null && mounted) {
        setState(() {
          _currentTrip = updatedGroup;
        });
      }
      widget.onGroupUpdated?.call();
    }
  }

  Future<void> _openParticipantsPage(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => ExpenseGroupParticipantsPage(
          trip: _currentTrip,
          mode: GroupEditMode.edit,
        ),
      ),
    );

    if (result == true && context.mounted) {
      // Ricarica il gruppo aggiornato
      final updatedGroup = await ExpenseGroupStorageV2.getTripById(
        _currentTrip.id,
      );
      if (updatedGroup != null && mounted) {
        setState(() {
          _currentTrip = updatedGroup;
        });
      }
      widget.onGroupUpdated?.call();
    }
  }

  Future<void> _openCategoriesPage(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => ExpenseGroupCategoriesPage(
          trip: _currentTrip,
          mode: GroupEditMode.edit,
        ),
      ),
    );

    if (result == true && context.mounted) {
      // Ricarica il gruppo aggiornato
      final updatedGroup = await ExpenseGroupStorageV2.getTripById(
        _currentTrip.id,
      );
      if (updatedGroup != null && mounted) {
        setState(() {
          _currentTrip = updatedGroup;
        });
      }
      widget.onGroupUpdated?.call();
    }
  }

  Future<void> _openOtherPage(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => ExpenseGroupOtherPage(
          trip: _currentTrip,
          mode: GroupEditMode.edit,
        ),
      ),
    );

    if (result == true && context.mounted) {
      // Ricarica il gruppo aggiornato
      final updatedGroup = await ExpenseGroupStorageV2.getTripById(
        _currentTrip.id,
      );
      if (updatedGroup != null && mounted) {
        setState(() {
          _currentTrip = updatedGroup;
        });
      }
      widget.onGroupUpdated?.call();
    }
  }

  void _openExportOptions(BuildContext context) {
    if (widget.onExportOptions != null) {
      widget.onExportOptions!();
    }
  }

  Future<void> _handleArchiveToggle(BuildContext context) async {
    final gloc = gen.AppLocalizations.of(context);
    final groupNotifier = Provider.of<ExpenseGroupNotifier>(
      context,
      listen: false,
    );
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final newArchivedState = !_currentTrip.archived;
    await groupNotifier.updateGroupArchive(_currentTrip.id, newArchivedState);

    if (!mounted) return;

    // Ricarica il gruppo aggiornato
    final updatedGroup = await ExpenseGroupStorageV2.getTripById(
      _currentTrip.id,
    );
    if (updatedGroup != null && mounted) {
      setState(() {
        _currentTrip = updatedGroup;
      });
    }

    if (!mounted) return;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          newArchivedState
              ? gloc.archived_with_undo
              : gloc.unarchived_with_undo,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    widget.onGroupUpdated?.call();
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
          Material3DialogActions.cancel(dialogCtx, gloc.cancel),
          Material3DialogActions.destructive(
            dialogCtx,
            gloc.delete,
            onPressed: () => Navigator.of(dialogCtx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final groupNotifier = Provider.of<ExpenseGroupNotifier>(
        context,
        listen: false,
      );

      await ExpenseGroupStorageV2.deleteGroup(_currentTrip.id);
      ExpenseGroupStorageV2.forceReload();
      groupNotifier.notifyGroupDeleted(_currentTrip.id);

      if (!context.mounted) return;

      widget.onGroupDeleted?.call();
      Navigator.of(context).pop(); // Close settings page
    }
  }
}
