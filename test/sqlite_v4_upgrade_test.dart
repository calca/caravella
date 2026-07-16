import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Regression test for the v4 -> v5 upgrade path (adding `public_key` to
/// `paired_devices` and the new `paired_device_groups` table for per-group
/// pairing grants, both needed for end-to-end encrypted sync).
///
/// Builds a v4 database by hand — `paired_devices` present without
/// `public_key`, no `paired_device_groups` table — to make sure
/// `SqliteExpenseGroupRepository`'s `onUpgrade` adds both without
/// disturbing an existing pairing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SQLite v4 -> v5 upgrade', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(
        'sqlite_v4_upgrade_${DateTime.now().millisecondsSinceEpoch}',
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

    Future<void> createV4Database(String path) async {
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
      // v4 shape: no public_key column yet.
      await db.execute('''
        CREATE TABLE paired_devices (
          device_id TEXT PRIMARY KEY,
          device_name TEXT NOT NULL,
          platform TEXT,
          paired_at INTEGER NOT NULL
        )
      ''');

      // Pre-existing shared group and pairing, from before end-to-end
      // encryption / per-group grants landed.
      await db.insert('groups', {
        'id': 'v4-group-1',
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
      await db.insert('paired_devices', {
        'device_id': 'v4-paired-device',
        'device_name': 'Old Pixel',
        'platform': 'android',
        'paired_at': DateTime(2026, 1, 1).millisecondsSinceEpoch,
      });

      await db.setVersion(4);
      await db.close();
    }

    test(
      'adds public_key column and paired_device_groups table without '
      'disturbing the existing pairing or groups',
      () async {
        await createV4Database(dbPath);

        final repository = SqliteExpenseGroupRepository(databasePath: dbPath);
        addTearDown(repository.close);

        final getAllResult = await repository.getAllGroups();
        expect(getAllResult.isSuccess, isTrue);
        expect(getAllResult.data, hasLength(1));
        expect(getAllResult.data!.first.id, equals('v4-group-1'));

        final db = await repository.database;
        final syncDao = SyncDao(db);

        // Pre-existing pairing survived, with no public key (must be
        // re-paired before it can sync again under the new protocol).
        final devices = await syncDao.getPairedDevices();
        expect(devices, hasLength(1));
        expect(devices.first.deviceId, equals('v4-paired-device'));
        expect(devices.first.deviceName, equals('Old Pixel'));
        expect(devices.first.publicKey, isNull);

        // New per-group grant table works.
        expect(
          await syncDao.isGroupGranted('v4-paired-device', 'v4-group-1'),
          isFalse,
        );
        await syncDao.grantGroupAccess('v4-paired-device', 'v4-group-1');
        expect(
          await syncDao.isGroupGranted('v4-paired-device', 'v4-group-1'),
          isTrue,
        );
      },
    );
  });
}
