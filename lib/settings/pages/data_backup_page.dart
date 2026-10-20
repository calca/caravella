import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import '../backup/restore_groups.dart';
import '../widgets/drive_backup_section.dart';

class DataBackupPage extends StatelessWidget {
  const DataBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return ChangeNotifierProvider<AutoBackupNotifier>(
      create: (_) => AutoBackupNotifier(),
      child: AppSystemUI.edgeToEdge(
        child: SettingsScaffold(
          eyebrow: gloc.settings,
          title: gloc.settings_data_manage,
          children: [
            SettingsGroup(
              label: gloc.auto_backup_title,
              children: [
                Consumer<AutoBackupNotifier>(
                  builder: (context, notifier, _) => SettingsTile(
                    icon: Icons.backup_outlined,
                    title: gloc.auto_backup_title,
                    subtitle: _autoBackupStatus(context, gloc, notifier),
                    switchValue: notifier.enabled,
                    onSwitch: notifier.setEnabled,
                  ),
                ),
              ],
            ),
            SettingsGroup(
              label: gloc.data_title,
              children: [
                SettingsTile(
                  icon: Icons.upload_outlined,
                  title: gloc.backup,
                  subtitle: gloc.data_backup_desc,
                  onTap: () => _backupTrips(context, gloc),
                ),
                SettingsTile(
                  icon: Icons.download_outlined,
                  title: gloc.data_restore_title,
                  subtitle: gloc.data_restore_desc,
                  onTap: () => _importTrips(context, gloc),
                ),
              ],
            ),
            const DriveBackupSection(),
          ],
        ),
      ),
    );
  }

  /// "Last backup: 19 Oct, 21:30", "No backup yet…" or "Off…" (iOS keeps
  /// the plain description: iCloud doesn't report when it ran).
  String _autoBackupStatus(
    BuildContext context,
    gen.AppLocalizations gloc,
    AutoBackupNotifier notifier,
  ) {
    if (!notifier.enabled) return gloc.auto_backup_off;
    if (!Platform.isAndroid) return gloc.auto_backup_desc;
    final last = notifier.lastBackup;
    if (last == null) return gloc.auto_backup_never;
    final locale = Localizations.localeOf(context).toString();
    return gloc.auto_backup_last(DateFormat.MMMd(locale).add_Hm().format(last));
  }

  Future<void> _backupTrips(
    BuildContext context,
    gen.AppLocalizations loc,
  ) async {
    try {
      final bytes = await BackupArchive.createFromStorage();
      if (bytes == null) {
        if (!context.mounted) return;
        AppToast.show(context, loc.no_trips_to_backup, type: ToastType.info);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final zipPath =
          '${tempDir.path}/${BackupArchive.fileNameFor(DateTime.now())}';
      await File(zipPath).writeAsBytes(bytes);

      if (!context.mounted) return;

      await SharePlus.instance.share(
        ShareParams(text: loc.backup_share_message, files: [XFile(zipPath)]),
      );
    } catch (e, st) {
      LoggerService.error(
        'Failed to create backup',
        name: 'settings.backup',
        error: e,
        stackTrace: st,
      );
      if (!context.mounted) return;
      AppToast.show(context, loc.backup_error, type: ToastType.error);
    }
  }

  Future<void> _importTrips(
    BuildContext context,
    gen.AppLocalizations loc,
  ) async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['zip', 'json'],
    );
    if (!context.mounted || result == null || result.path == null) return;
    final filePath = result.path!;
    if (!await confirmRestore(context, loc, result.name)) return;

    late final List<ExpenseGroup> groups;
    try {
      final isZip = filePath.endsWith('.zip');
      if (!isZip && !filePath.endsWith('.json')) {
        throw const FormatException('Unsupported file format');
      }
      groups = BackupArchive.decode(
        await File(filePath).readAsBytes(),
        isZip: isZip,
      );
    } catch (e, st) {
      LoggerService.error(
        'Failed to read backup',
        name: 'settings.backup',
        error: e,
        stackTrace: st,
      );
      if (context.mounted) {
        AppToast.show(context, loc.import_error, type: ToastType.error);
      }
      return;
    }
    if (context.mounted) await restoreBackupGroups(context, loc, groups);
  }
}
