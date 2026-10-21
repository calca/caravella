import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../backup/drive_backup_service.dart';
import '../backup/restore_groups.dart';

/// Settings → Data: backups in Google Drive, an option next to the file
/// export. Hidden in builds without it (F-Droid). Not linked: one row to
/// connect. Linked: back up now (with the last backup time), restore one of
/// the kept backups, the weekly backup switch, and disconnect.
class DriveBackupSection extends StatefulWidget {
  const DriveBackupSection({super.key});

  @override
  State<DriveBackupSection> createState() => _DriveBackupSectionState();
}

class _DriveBackupSectionState extends State<DriveBackupSection> {
  CloudBackupStore? get _store => DriveBackupService.store;

  bool _linked = false;
  bool _busy = false;
  bool _weekly = false;
  DateTime? _last;

  @override
  void initState() {
    super.initState();
    if (_store != null) _load();
  }

  Future<void> _load() async {
    final weekly = await DriveBackupService.isWeekly();
    final last = await DriveBackupService.lastBackup();
    if (!mounted) return;
    setState(() {
      _weekly = weekly;
      _last = last;
      _linked = _store!.accountName != null;
    });
    if (!_linked) {
      final linked = await _store!.restoreSession();
      if (mounted) setState(() => _linked = linked);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e, st) {
      LoggerService.error(
        'Google Drive backup action failed',
        name: 'settings.backup.drive',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        final loc = gen.AppLocalizations.of(context);
        AppToast.show(context, loc.drive_backup_error, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _connect() => _run(() async {
    final linked = await _store!.signIn();
    if (!mounted) return;
    setState(() => _linked = linked);
    if (!linked) {
      final loc = gen.AppLocalizations.of(context);
      AppToast.show(context, loc.drive_backup_error, type: ToastType.error);
    }
  });

  Future<void> _disconnect() => _run(() async {
    await _store!.signOut();
    if (mounted) setState(() => _linked = false);
  });

  Future<void> _backupNow(gen.AppLocalizations loc) => _run(() async {
    final entry = await DriveBackupService.backupNow();
    if (!mounted) return;
    if (entry == null) {
      AppToast.show(context, loc.no_trips_to_backup, type: ToastType.info);
      return;
    }
    final last = await DriveBackupService.lastBackup();
    if (!mounted) return;
    setState(() => _last = last);
    AppToast.show(context, loc.drive_backup_saved, type: ToastType.success);
  });

  Future<void> _restore(gen.AppLocalizations loc) async {
    List<CloudBackupEntry>? entries;
    await _run(() async => entries = await _store!.list());
    if (!mounted || entries == null) return;
    if (entries!.isEmpty) {
      AppToast.show(context, loc.drive_backup_none, type: ToastType.info);
      return;
    }
    final picked = await showModalBottomSheet<CloudBackupEntry>(
      context: context,
      builder: (context) => CaravellaBottomSheetScaffold(
        title: loc.drive_backup_restore,
        child: SettingsGroup(
          topSpacing: 0,
          children: [
            for (final entry in entries!)
              SettingsTile(
                icon: Icons.inventory_2_outlined,
                title: _formatTime(context, entry.createdAt),
                subtitle: _formatSize(entry.sizeBytes),
                chevron: false,
                onTap: () => Navigator.of(context).pop(entry),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    final name = _formatTime(context, picked.createdAt);
    if (!await confirmRestore(context, loc, name) || !mounted) return;

    List<ExpenseGroup>? groups;
    await _run(() async {
      groups = BackupArchive.decode(await _store!.download(picked.id));
    });
    if (groups != null && mounted) {
      await restoreBackupGroups(context, loc, groups!);
    }
  }

  Future<void> _setWeekly(bool value) async {
    await DriveBackupService.setWeekly(value);
    if (mounted) setState(() => _weekly = value);
  }

  String _formatTime(BuildContext context, DateTime time) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).add_Hm().format(time);
  }

  String _formatSize(int bytes) => bytes < 1024 * 1024
      ? '${(bytes / 1024).ceil()} KB'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  @override
  Widget build(BuildContext context) {
    final store = _store;
    if (store == null) return const SizedBox.shrink();
    final loc = gen.AppLocalizations.of(context);
    final enabled = !_busy;

    if (!_linked) {
      return SettingsGroup(
        label: store.providerName,
        children: [
          SettingsTile(
            icon: Icons.add_to_drive_outlined,
            title: loc.drive_backup_connect,
            subtitle: loc.drive_backup_connect_desc,
            onTap: enabled ? _connect : null,
          ),
        ],
      );
    }

    final last = _last;
    return SettingsGroup(
      label: store.providerName,
      children: [
        SettingsTile(
          icon: Icons.cloud_upload_outlined,
          title: loc.drive_backup_now,
          subtitle: last == null
              ? loc.drive_backup_none
              : loc.auto_backup_last(_formatTime(context, last)),
          trailing: _busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: enabled ? () => _backupNow(loc) : null,
        ),
        SettingsTile(
          icon: Icons.cloud_download_outlined,
          title: loc.drive_backup_restore,
          subtitle: loc.drive_backup_restore_desc,
          onTap: enabled ? () => _restore(loc) : null,
        ),
        SettingsTile(
          icon: Icons.event_repeat_outlined,
          title: loc.drive_backup_weekly,
          subtitle: loc.drive_backup_weekly_desc,
          switchValue: _weekly,
          onSwitch: _setWeekly,
        ),
        SettingsTile(
          icon: Icons.logout_rounded,
          title: loc.drive_backup_disconnect,
          subtitle: store.accountName,
          onTap: enabled ? _disconnect : null,
        ),
      ],
    );
  }
}
