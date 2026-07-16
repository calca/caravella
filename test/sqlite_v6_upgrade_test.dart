import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Regression test for the v5 -> v6 upgrade path (adding the
/// `created_by_*`/`updated_by_*` per-expense authorship columns).
///
/// Builds a v5 database by hand — `expenses` present without the six new
/// columns — to make sure `SqliteExpenseGroupRepository`'s `onUpgrade` adds
/// them without disturbing existing expenses, and that pre-existing rows
/// simply read back with `createdBy`/`updatedBy` as `null`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SQLite v5 -> v6 upgrade', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(
        'sqlite_v6_upgrade_${DateTime.now().millisecondsSinceEpoch}',
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

    Future<void> createV5Database(String path) async {
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
      // v5 shape: no created_by_*/updated_by_* columns yet.
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
      await db.execute('''
        CREATE TABLE paired_devices (
          device_id TEXT PRIMARY KEY,
          device_name TEXT NOT NULL,
          platform TEXT,
          paired_at INTEGER NOT NULL,
          public_key TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE paired_device_groups (
          device_id TEXT NOT NULL,
          group_id TEXT NOT NULL,
          granted_at INTEGER NOT NULL,
          PRIMARY KEY (device_id, group_id)
        )
      ''');

      await db.insert('groups', {
        'id': 'v5-group-1',
        'title': 'Legacy Trip',
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
        'sync_enabled': 0,
      });
      await db.insert('participants', {
        'id': 'v5-participant-1',
        'group_id': 'v5-group-1',
        'name': 'Alice',
      });
      await db.insert('categories', {
        'id': 'v5-category-1',
        'group_id': 'v5-group-1',
        'name': 'Food',
      });
      await db.insert('expenses', {
        'id': 'v5-expense-1',
        'group_id': 'v5-group-1',
        'name': 'Legacy Expense',
        'amount': 12.5,
        'date': DateTime(2026, 1, 1).millisecondsSinceEpoch,
        'category_id': 'v5-category-1',
        'paid_by_id': 'v5-participant-1',
      });

      await db.setVersion(5);
      await db.close();
    }

    test(
      'adds created_by_*/updated_by_* columns without disturbing existing '
      'expenses, which read back with null authorship',
      () async {
        await createV5Database(dbPath);

        final repository = SqliteExpenseGroupRepository(databasePath: dbPath);
        addTearDown(repository.close);

        final getAllResult = await repository.getAllGroups();
        expect(getAllResult.isSuccess, isTrue);
        expect(getAllResult.data, hasLength(1));

        final group = getAllResult.data!.first;
        expect(group.expenses, hasLength(1));
        final expense = group.expenses.first;
        expect(expense.id, equals('v5-expense-1'));
        expect(expense.createdBy, isNull);
        expect(expense.updatedBy, isNull);
      },
    );
  });
}
