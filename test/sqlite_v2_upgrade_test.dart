import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Regression test for the v2 -> v3 upgrade path.
///
/// Real installs that predate the sync feature are at on-disk schema version
/// 2 (bumped previously for aggregation views that were later dropped without
/// a version change) and have NONE of the sync columns/tables. This test
/// builds that exact pre-sync schema by hand — the same shape produced by
/// `createSqliteSchema` before the sync columns were added — to make sure
/// `SqliteExpenseGroupRepository`'s `onUpgrade` brings a real v2 database up
/// to date instead of silently skipping the migration.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SQLite v2 -> v3 upgrade', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(
        'sqlite_v2_upgrade_${DateTime.now().millisecondsSinceEpoch}',
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

    Future<void> createPreSyncV2Database(String path) async {
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
          auto_location_enabled INTEGER NOT NULL DEFAULT 0
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

      // Pre-existing group, saved before the sync feature ever ran.
      await db.insert('groups', {
        'id': 'legacy-group-1',
        'title': 'Legacy Trip',
        'currency': 'EUR',
        'timestamp': DateTime(2025, 1, 1).millisecondsSinceEpoch,
        'pinned': 0,
        'archived': 0,
        'notification_enabled': 0,
        'auto_location_enabled': 0,
      });
      await db.insert('participants', {
        'id': 'legacy-p1',
        'group_id': 'legacy-group-1',
        'name': 'Alice',
      });
      await db.insert('categories', {
        'id': 'legacy-c1',
        'group_id': 'legacy-group-1',
        'name': 'Food',
      });

      await db.setVersion(2);
      await db.close();
    }

    test(
      'recognizes groups saved before the sync feature after upgrading',
      () async {
        await createPreSyncV2Database(dbPath);

        final repository = SqliteExpenseGroupRepository(databasePath: dbPath);
        addTearDown(repository.close);

        final getAllResult = await repository.getAllGroups();
        expect(
          getAllResult.isSuccess,
          isTrue,
          reason: 'getAllGroups failed: ${getAllResult.error}',
        );
        expect(getAllResult.data, hasLength(1));
        expect(getAllResult.data!.first.id, equals('legacy-group-1'));
        expect(getAllResult.data!.first.title, equals('Legacy Trip'));
      },
    );

    test('can create new groups after upgrading from a pre-sync v2 database', () async {
      await createPreSyncV2Database(dbPath);

      final repository = SqliteExpenseGroupRepository(databasePath: dbPath);
      addTearDown(repository.close);

      final newGroup = ExpenseGroup(
        id: 'new-group-1',
        title: 'New Trip',
        currency: 'USD',
        participants: [ExpenseParticipant(id: 'p1', name: 'Bob')],
        categories: [ExpenseCategory(id: 'c1', name: 'Transport')],
        expenses: const [],
        timestamp: DateTime.now(),
      );

      final saveResult = await repository.saveGroup(newGroup);
      expect(
        saveResult.isSuccess,
        isTrue,
        reason: 'saveGroup failed: ${saveResult.error}',
      );

      final getResult = await repository.getGroupById('new-group-1');
      expect(getResult.isSuccess, isTrue);
      expect(getResult.data?.title, equals('New Trip'));
    });
  });
}
