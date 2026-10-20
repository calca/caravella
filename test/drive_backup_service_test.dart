import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/settings/backup/drive_backup_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('drive_backup_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

/// In-memory cloud backup store.
class _FakeStore implements CloudBackupStore {
  bool linked = true;
  final uploads = <String, List<int>>{};

  @override
  String get providerName => 'Fake';
  @override
  String? get accountName => linked ? 'me@example.com' : null;
  @override
  Future<bool> restoreSession() async => linked;
  @override
  Future<bool> signIn() async => linked = true;
  @override
  Future<void> signOut() async => linked = false;

  @override
  Future<CloudBackupEntry> upload(
    String fileName,
    List<int> bytes, {
    int keep = 5,
  }) async {
    uploads[fileName] = bytes;
    return CloudBackupEntry(
      id: fileName,
      name: fileName,
      createdAt: DateTime.now(),
      sizeBytes: bytes.length,
    );
  }

  @override
  Future<List<CloudBackupEntry>> list() async => const [];
  @override
  Future<List<int>> download(String id) async => uploads[id]!;
}

/// Google Drive backup: "back up now" and the weekly backup at start.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();
  late _FakeStore store;
  final now = DateTime(2026, 10, 20, 9);

  setUpAll(() {
    ExpenseGroupRepositoryFactory.reset();
    ExpenseGroupRepositoryFactory.getRepository(useJsonBackend: true);
  });

  setUp(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ExpenseGroupStorageV2.fileName}');
    if (await file.exists()) await file.delete();
    ExpenseGroupStorageV2.clearCache();
    ExpenseGroupStorageV2.forceReload();
    SharedPreferences.setMockInitialValues({});
    store = _FakeStore();
    DriveBackupService.debugSetStore(store);
  });

  Future<void> addGroup() => ExpenseGroupStorageV2.addExpenseGroup(
    ExpenseGroup(
      title: 'Norway',
      expenses: const [],
      participants: [ExpenseParticipant(name: 'Anna')],
      currency: '€',
    ),
  );

  test('back up now uploads every group and records the time', () async {
    await addGroup();
    final entry = await DriveBackupService.backupNow(now: now);

    expect(entry!.name, 'caravella_backup_20261020_090000.zip');
    final groups = BackupArchive.decode(store.uploads[entry.name]!);
    expect(groups.single.title, 'Norway');
    expect(await DriveBackupService.lastBackup(), now);
  });

  test('nothing to back up without groups', () async {
    expect(await DriveBackupService.backupNow(now: now), isNull);
    expect(store.uploads, isEmpty);
  });

  test('the weekly backup runs only when on and due', () async {
    await addGroup();

    await DriveBackupService.runIfDue(now: now);
    expect(store.uploads, isEmpty, reason: 'weekly backup is off');

    await DriveBackupService.setWeekly(true);
    await DriveBackupService.runIfDue(now: now);
    expect(store.uploads, hasLength(1), reason: 'never backed up');

    await DriveBackupService.runIfDue(now: now.add(const Duration(days: 3)));
    expect(store.uploads, hasLength(1), reason: 'last one is recent');

    await DriveBackupService.runIfDue(now: now.add(const Duration(days: 8)));
    expect(store.uploads, hasLength(2), reason: 'a week has passed');
  });

  test('the weekly backup skips when the account is not linked', () async {
    await addGroup();
    await DriveBackupService.setWeekly(true);
    store.linked = false;

    await DriveBackupService.runIfDue(now: now);
    expect(store.uploads, isEmpty);
  });
}
