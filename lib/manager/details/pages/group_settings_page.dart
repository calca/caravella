import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';

import '../../group/pages/expense_group_general_page.dart';
import '../../group/pages/expense_group_participants_page.dart';
import '../../group/pages/expense_group_categories_page.dart';
import '../../group/pages/expense_group_other_page.dart';
import '../../group/pages/expense_group_sync_page.dart';
import '../../group/group_edit_mode.dart';
import '../pages/tabs/usecase/date_range_formatter.dart';

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
    final trip = _currentTrip;
    final dates = (trip.startDate != null || trip.endDate != null)
        ? formatDateRange(
            start: trip.startDate,
            end: trip.endDate,
            locale: Localizations.localeOf(context),
          )
        : null;
    String names(Iterable<String> all) {
      final list = all.toList();
      if (list.length <= 3) return list.join(', ');
      return '${list.take(3).join(', ')}…';
    }

    final hasExpenses = trip.expenses.isNotEmpty;
    return AppSystemUI.edgeToEdge(
      child: SettingsScaffold(
        eyebrow: gloc.group,
        title: gloc.settings,
        children: [
          SettingsProfileCard(
            // Shortcut: the photo / icon opens the background sheet.
            leading: Semantics(
              button: true,
              label: gloc.background,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openGeneralPage(context, openBackground: true),
                child: GroupIconAvatar(group: trip, size: 52),
              ),
            ),
            title: trip.title,
            subtitle: [
              ?dates,
              gloc.participant_count(trip.participants.length),
              trip.currency,
            ].join(' · '),
            actionLabel: gloc.edit,
            onTap: () => _openGeneralPage(context),
          ),
          SettingsGroup(
            label: gloc.group,
            children: [
              SettingsTile(
                icon: Icons.people_outline,
                title: gloc.participants,
                subtitle: trip.participants.isEmpty
                    ? gloc.participants_description
                    : names(trip.participants.map((p) => p.name)),
                onTap: () => _openParticipantsPage(context),
              ),
              SettingsTile(
                icon: Icons.label_outline,
                title: gloc.categories,
                subtitle: trip.categories.isEmpty
                    ? gloc.categories_description
                    : names(trip.categories.map((c) => c.name)),
                onTap: () => _openCategoriesPage(context),
              ),
              SettingsTile(
                icon: Icons.tune_outlined,
                title: gloc.segment_other,
                subtitle: gloc.other_settings_desc,
                onTap: () => _openOtherPage(context),
              ),
            ],
          ),
          SettingsGroup(
            label: gloc.export_share,
            children: [
              SettingsTile(
                icon: Icons.sync_rounded,
                title: gloc.sync_title,
                subtitle: gloc.sync_settings_desc,
                onTap: () => _openSyncPage(context),
              ),
              SettingsTile(
                icon: Icons.ios_share_outlined,
                title: gloc.export_options,
                subtitle: hasExpenses
                    ? gloc.export_options_desc
                    : gloc.export_options_empty,
                enabled: hasExpenses,
                onTap: () => _openExportOptions(context),
              ),
            ],
          ),
          SettingsGroup(
            label: gloc.danger_zone,
            children: [
              SettingsTile(
                icon: trip.archived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                title: trip.archived ? gloc.unarchive : gloc.archive,
                onTap: () => _handleArchiveToggle(context),
              ),
              SettingsTile(
                icon: Icons.delete_outline,
                title: gloc.delete_group,
                destructive: true,
                onTap: () => _handleDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openGeneralPage(
    BuildContext context, {
    bool openBackground = false,
  }) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => ExpenseGroupGeneralPage(
          trip: _currentTrip,
          mode: GroupEditMode.edit,
          openBackground: openBackground,
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
        builder: (ctx) =>
            ExpenseGroupOtherPage(trip: _currentTrip, mode: GroupEditMode.edit),
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

  Future<void> _openSyncPage(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => ExpenseGroupSyncPage(trip: _currentTrip),
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

    if (!context.mounted) return;

    AppToast.show(
      context,
      newArchivedState ? gloc.archived_with_undo : gloc.unarchived_with_undo,
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
