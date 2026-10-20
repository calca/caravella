import 'package:caravella_core/caravella_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Backups in the user's cloud (Google Drive in the Play build): back up
/// now, the weekly backup when the app opens, the last backup time. An
/// option next to the file export, which stays available everywhere.
class DriveBackupService {
  DriveBackupService._();

  static const _tag = 'settings.backup.drive';
  static const _weeklyKey = 'drive_backup_weekly';
  static const _lastKey = 'drive_backup_last';
  static const weeklyInterval = Duration(days: 7);

  static CloudBackupStore? _store;
  static bool _storeResolved = false;

  /// `null` when this build has no cloud backup (F-Droid, or Drive off).
  static CloudBackupStore? get store {
    if (!_storeResolved) {
      _store = GmsIntegrations.instance.createCloudBackupStore();
      _storeResolved = true;
    }
    return _store;
  }

  static Future<bool> isWeekly() async =>
      (await SharedPreferences.getInstance()).getBool(_weeklyKey) ?? false;

  static Future<void> setWeekly(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_weeklyKey, value);

  static Future<DateTime?> lastBackup() async {
    final ms = (await SharedPreferences.getInstance()).getInt(_lastKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Uploads a backup of every group. `null` when there's nothing to back
  /// up; throws when the cloud can't be reached.
  static Future<CloudBackupEntry?> backupNow({DateTime? now}) async {
    final cloud = store;
    if (cloud == null) return null;
    final bytes = await BackupArchive.createFromStorage();
    if (bytes == null) return null;
    final time = now ?? DateTime.now();
    final entry = await cloud.upload(BackupArchive.fileNameFor(time), bytes);
    await (await SharedPreferences.getInstance()).setInt(
      _lastKey,
      time.millisecondsSinceEpoch,
    );
    return entry;
  }

  /// The weekly backup: when it's on, linked, and the last one is older
  /// than [weeklyInterval]. Never throws (runs in the background at start).
  static Future<void> runIfDue({DateTime? now}) async {
    try {
      final cloud = store;
      if (cloud == null || !await isWeekly()) return;
      final time = now ?? DateTime.now();
      final last = await lastBackup();
      if (last != null && time.difference(last) < weeklyInterval) return;
      if (!await cloud.restoreSession()) return;
      final entry = await backupNow(now: time);
      if (entry != null) {
        LoggerService.info('Weekly backup saved: ${entry.name}', name: _tag);
      }
    } catch (e, st) {
      LoggerService.warning('Weekly backup failed', name: _tag);
      LoggerService.debug('$e\n$st', name: _tag);
    }
  }

  /// Test hook: use [cloud] instead of the build's store.
  static void debugSetStore(CloudBackupStore? cloud) {
    _store = cloud;
    _storeResolved = true;
  }
}
