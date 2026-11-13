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
///
/// What happened shows in the row itself, not in a toast: the new backup
/// time, "Couldn't reach Google Drive" in red on the row that failed (tap
/// it again to retry), "No backup on Drive yet" on Restore, and both backup
/// rows greyed out while there are no groups.
enum _DriveRow { connect, backup, restore }

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
  bool _hasGroups = true;

  /// The row whose last action failed (Drive unreachable).
  _DriveRow? _failed;

  /// Restore found nothing to restore.
  bool _noBackups = false;

  @override
  void initState() {
    super.initState();
    if (_store != null) _load();
  }

  Future<void> _load() async {
    final weekly = await DriveBackupService.isWeekly();
    final last = await DriveBackupService.lastBackup();
    final groups = await ExpenseGroupStorageV2.getAllGroups();
    if (!mounted) return;
    setState(() {
      _weekly = weekly;
      _last = last;
      _hasGroups = groups.isNotEmpty;
      _linked = _store!.accountName != null;
    });
    if (!_linked) {
      final linked = await _store!.restoreSession();
      if (mounted) setState(() => _linked = linked);
    }
  }

  Future<void> _run(_DriveRow row, Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = null;
    });
    try {
      await action();
    } catch (e, st) {
      LoggerService.error(
        'Google Drive backup action failed',
        name: 'settings.backup.drive',
        error: e,
        stackTrace: st,
      );
      if (mounted) setState(() => _failed = row);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _connect() => _run(_DriveRow.connect, () async {
    final linked = await _store!.signIn();
    if (!mounted) return;
    setState(() {
      _linked = linked;
      if (!linked) _failed = _DriveRow.connect;
    });
  });

  Future<void> _disconnect() => _run(_DriveRow.connect, () async {
    await _store!.signOut();
    if (mounted) setState(() => _linked = false);
  });

  Future<void> _backupNow() => _run(_DriveRow.backup, () async {
    final entry = await DriveBackupService.backupNow();
    if (!mounted) return;
    if (entry == null) {
      setState(() => _hasGroups = false);
      return;
    }
    final last = await DriveBackupService.lastBackup();
    if (!mounted) return;
    // The row's "Last backup" time is the confirmation.
    setState(() {
      _last = last;
      _noBackups = false;
    });
  });

  Future<void> _restore(gen.AppLocalizations loc) async {
    List<CloudBackupEntry>? entries;
    await _run(_DriveRow.restore, () async => entries = await _store!.list());
    if (!mounted || entries == null) return;
    setState(() => _noBackups = entries!.isEmpty);
    if (entries!.isEmpty) return;
    final picked = await showAppBottomSheet<CloudBackupEntry>(
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
    var newer = false;
    await _run(_DriveRow.restore, () async {
      try {
        groups = BackupArchive.decode(await _store!.download(picked.id));
      } on NewerFormatException {
        // Not a Drive failure: this app is too old for the backup.
        newer = true;
      }
    });
    if (newer && mounted) {
      AppToast.show(context, loc.import_error_newer, type: ToastType.error);
      return;
    }
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
    final error = Theme.of(context).colorScheme.error;

    /// In place of [row]'s subtitle after a failure: the reason, in red.
    Widget? failure(_DriveRow row) => _failed == row
        ? Text(loc.drive_backup_error, style: TextStyle(color: error))
        : null;

    if (!_linked) {
      return SettingsGroup(
        label: store.providerName,
        children: [
          SettingsTile(
            icon: Icons.add_to_drive_outlined,
            title: loc.drive_backup_connect,
            subtitle: loc.drive_backup_connect_desc,
            subtitleWidget: failure(_DriveRow.connect),
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
          subtitle: !_hasGroups
              ? loc.no_trips_to_backup
              : last == null
              ? loc.drive_backup_none
              : loc.auto_backup_last(_formatTime(context, last)),
          subtitleWidget: failure(_DriveRow.backup),
          trailing: _busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          enabled: _hasGroups,
          onTap: enabled ? _backupNow : null,
        ),
        SettingsTile(
          icon: Icons.cloud_download_outlined,
          title: loc.drive_backup_restore,
          subtitle: _noBackups
              ? loc.drive_backup_none
              : loc.drive_backup_restore_desc,
          subtitleWidget: failure(_DriveRow.restore),
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
