import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Restores [groups] from a backup (file or cloud): saves them, refreshes
/// the screens showing them, then shows the result and goes back home.
Future<void> restoreBackupGroups(
  BuildContext context,
  gen.AppLocalizations loc,
  List<ExpenseGroup> groups,
) async {
  try {
    final result = await BackupArchive.restore(groups);

    // Groups saved before a failure still show up instead of the UI
    // silently staying stale.
    if (result.saved.isNotEmpty && context.mounted) {
      final notifier = context.read<ExpenseGroupNotifier>();
      for (final group in result.saved) {
        notifier.notifyGroupUpdated(group.id);
      }
    }
    if (result.error != null) throw Exception(result.error);

    // The user has groups now: no longer the first start.
    try {
      await PreferencesService.instance.appState.setIsFirstStart(false);
    } catch (e, st) {
      LoggerService.error(
        'Failed to update first start preference',
        name: 'settings.backup',
        error: e,
        stackTrace: st,
      );
    }

    if (context.mounted) {
      AppToast.show(context, loc.import_success, type: ToastType.success);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  } catch (e, st) {
    LoggerService.error(
      'Failed to import backup',
      name: 'settings.backup',
      error: e,
      stackTrace: st,
    );
    if (context.mounted) {
      AppToast.show(context, loc.import_error, type: ToastType.error);
    }
  }
}

/// Asks to confirm restoring the backup [name]; `true` when confirmed.
Future<bool> confirmRestore(
  BuildContext context,
  gen.AppLocalizations loc,
  String name,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => Material3Dialog(
        icon: Icon(
          Icons.upload_file_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        title: Text(loc.import_confirm_title),
        content: Text(loc.import_confirm_message(name)),
        actions: [
          Material3DialogActions.cancel(context, loc.cancel),
          Material3DialogActions.primary(
            context,
            loc.ok,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ??
    false;
