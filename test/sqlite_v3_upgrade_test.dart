import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Regression test for the v3 -> v4 upgrade path (adding `paired_devices`
/// for QR pairing).
///
/// Builds a v3 database by hand — sync columns/tables present, no
/// `paired_devices` table — to make sure `SqliteExpenseGroupRepository`'s
/// `onUpgrade` adds the new table without disturbing existing sync data.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SQLite v3 -> v4 upgrade', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(
        'sqlite_v3_upgrade_${DateTime.now().millisecondsSinceEpoch}',
      );
      dbPath = '${tempDir.path}/expense_groups.db';
    });

    tearDown(() async {
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (_) {
        // Ignore cleanup errors
      }
    });

    Future<void> createV3Database(String path) async {
      final db = await databaseFactoryFfi.openDatabase(path);

      await db.execute('''
        CREATE TABLE groups (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          currency TEXT NOT NULL,
          start_date INTEGER,
          end_date INTEGER,
          timestamp INTEGER NOT NULL,
          pinned INTEGER NOT NULL DEFAULT 0,
          archived INTEGER NOT NULL DEFAULT 0,
          file TEXT,
          color INTEGER,
          notification_enabled INTEGER NOT NULL DEFAULT 0,
          group_type TEXT,
          auto_location_enabled INTEGER NOT NULL DEFAULT 0,
          device_id TEXT NOT NULL DEFAULT '',
          updated_at INTEGER NOT NULL DEFAULT 0,
          deleted INTEGER NOT NULL DEFAULT 0,
          sync_version INTEGER NOT NULL DEFAULT 0,
          sync_enabled INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE participants (
          id TEXT PRIMARY KEY,
          group_id TEXT NOT NULL,
          name TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          group_id TEXT NOT NULL,
          name TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE expenses (
          id TEXT PRIMARY KEY,
          group_id TEXT NOT NULL,
          name TEXT NOT NULL,
          amount REAL,
          date INTEGER NOT NULL,
          category_id TEXT NOT NULL,
          paid_by_id TEXT NOT NULL,
          location_latitude REAL,
          location_longitude REAL,
          location_name TEXT,
          note TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE attachments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          expense_id TEXT NOT NULL,
          file_path TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE device_meta (
          device_id TEXT PRIMARY KEY,
          device_name TEXT,
          last_seen INTEGER,
          vector_clock TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE sync_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          peer_id TEXT NOT NULL,
          channel TEXT NOT NULL,
          synced_at INTEGER NOT NULL,
          delta_sent INTEGER NOT NULL DEFAULT 0,
          delta_recv INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Pre-existing shared group, saved before QR pairing landed.
      await db.insert('groups', {
        'id': 'v3-group-1',
        'title': 'Shared Trip',
        'currency': 'EUR',
        'timestamp': DateTime(2026, 1, 1).millisecondsSinceEpoch,
        'pinned': 0,
        'archived': 0,
        'notification_enabled': 0,
        'auto_location_enabled': 0,
        'device_id': 'device-original',
        'updated_at': DateTime(2026, 1, 1).millisecondsSinceEpoch,
        'deleted': 0,
        'sync_version': 1,
        'sync_enabled': 1,
      });

      await db.setVersion(3);
      await db.close();
    }

    test('adds the paired_devices table without touching existing groups', () async {
      await createV3Database(dbPath);

      final repository = SqliteExpenseGroupRepository(databasePath: dbPath);
      addTearDown(repository.close);

      final getAllResult = await repository.getAllGroups();
      expect(getAllResult.isSuccess, isTrue);
      expect(getAllResult.data, hasLength(1));
      expect(getAllResult.data!.first.id, equals('v3-group-1'));
      expect(getAllResult.data!.first.syncEnabled, isTrue);

      final db = await repository.database;
      final syncDao = SyncDao(db);

      expect(await syncDao.isPaired('some-device'), isFalse);

      await syncDao.addPairedDevice(
        deviceId: 'some-device',
        deviceName: 'Test Device',
        platform: 'android',
      );

      expect(await syncDao.isPaired('some-device'), isTrue);
    });
  });
}
