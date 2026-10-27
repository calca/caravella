import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// The whole place of an expense survives a save: v7 adds
/// `expenses.location_details` (the location as JSON), since only latitude,
/// longitude and name had columns and the automatic location's locality
/// ("Sovico") came back as bare coordinates.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SQLite v7 location details', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(
        'sqlite_v7_location_${DateTime.now().millisecondsSinceEpoch}',
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

    Future<void> createV6Database(String path) async {
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
      // v6 shape: no location_details column yet.
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
          note TEXT,
          created_by_device_id TEXT,
          created_by_device_name TEXT,
          created_by_user_name TEXT,
          updated_by_device_id TEXT,
          updated_by_device_name TEXT,
          updated_by_user_name TEXT
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
        'location_latitude': 45.62,
        'location_longitude': 9.28,
        'location_name': 'Old place',
      });

      await db.setVersion(6);
      await db.close();
    }

    test('upgrades v6 keeping the coordinates and name of old rows', () async {
      await createV6Database(dbPath);

      final repository = SqliteExpenseGroupRepository(databasePath: dbPath);
      addTearDown(repository.close);

      final result = await repository.getAllGroups();
      expect(result.isSuccess, isTrue);
      final location = result.data!.single.expenses.single.location;
      expect(location?.latitude, 45.62);
      expect(location?.longitude, 9.28);
      expect(location?.name, 'Old place');
    });

    test('keeps locality and address of an automatic location', () async {
      final payer = ExpenseParticipant(id: 'p1', name: 'Anna');
      final category = ExpenseCategory(id: 'c1', name: 'Food');
      final place = ExpenseLocation(
        latitude: 45.6489,
        longitude: 9.2731,
        address: 'Via Roma 1, 20845 Sovico MB, Italia',
        street: 'Via Roma',
        streetNumber: '1',
        locality: 'Sovico',
        administrativeArea: 'Lombardia',
        postalCode: '20845',
        country: 'Italia',
        isoCountryCode: 'IT',
      );
      final group = ExpenseGroup(
        id: 'g1',
        title: 'Trip',
        currency: 'EUR',
        participants: [payer],
        categories: [category],
        expenses: [
          ExpenseDetails(
            id: 'e1',
            name: 'Coffee',
            amount: 2.5,
            paidBy: payer,
            category: category,
            date: DateTime(2026, 10, 27),
            location: place,
          ),
        ],
        timestamp: DateTime(2026, 10, 27),
      );

      final writer = SqliteExpenseGroupRepository(databasePath: dbPath);
      expect((await writer.saveGroup(group)).isSuccess, isTrue);
      await writer.close();

      final reader = SqliteExpenseGroupRepository(databasePath: dbPath);
      addTearDown(reader.close);
      final loaded = await reader.getGroupById('g1');
      final location = loaded.data!.expenses.single.location;
      expect(location, place);
      expect(location?.locality, 'Sovico');
    });
  });
}
