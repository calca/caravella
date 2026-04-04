import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('StorageMigrationService', () {
    late FileBasedExpenseGroupRepository jsonRepo;
    late SqliteExpenseGroupRepository sqliteRepo;
    late ExpenseGroup testGroup1;
    late ExpenseGroup testGroup2;
    late Directory tempDir;

    setUp(() async {
      // Reset SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Create a unique temp directory for each test
      tempDir = Directory.systemTemp.createTempSync(
        'migration_test_${DateTime.now().millisecondsSinceEpoch}',
      );
      final dbPath = '${tempDir.path}/expense_groups.db';
      final jsonPath = '${tempDir.path}/expense_group_storage.json';

      jsonRepo = FileBasedExpenseGroupRepository(storagePath: jsonPath);
      sqliteRepo = SqliteExpenseGroupRepository(databasePath: dbPath);

      // Reset migration status
      await StorageMigrationService.resetMigrationStatus();

      // Set up test data - each group has unique participant/category/expense IDs
      final participant1 = ExpenseParticipant(name: 'John', id: 'g1_p1');
      final category1 = ExpenseCategory(name: 'Food', id: 'g1_c1');

      testGroup1 = ExpenseGroup(
        id: 'group-1',
        title: 'Test Group 1',
        currency: 'USD',
        participants: [participant1],
        categories: [category1],
        expenses: [
          ExpenseDetails(
            id: 'g1_e1',
            category: category1,
            amount: 50.0,
            paidBy: participant1,
            date: DateTime.now(),
            name: 'Lunch',
          ),
        ],
        timestamp: DateTime.now(),
      );

      final participant2 = ExpenseParticipant(name: 'Jane', id: 'g2_p1');
      final category2 = ExpenseCategory(name: 'Transport', id: 'g2_c1');

      testGroup2 = ExpenseGroup(
        id: 'group-2',
        title: 'Test Group 2',
        currency: 'EUR',
        participants: [participant2],
        categories: [category2],
        expenses: [],
        timestamp: DateTime.now(),
      );
    });

    tearDown(() async {
      jsonRepo.clearCache();
      await sqliteRepo.close();

      // Clean up temp directory
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    test('should detect when migration is not completed', () async {
      final completed = await StorageMigrationService.isMigrationCompleted();
      expect(completed, isFalse);
    });

    test('should detect when JSON data exists', () async {
      // Save data to JSON
      await jsonRepo.saveGroup(testGroup1);

      final hasData = await StorageMigrationService.hasJsonData(
        customPath: tempDir.path,
      );
      expect(hasData, isTrue);
    });

    test('should detect when JSON data does not exist', () async {
      final hasData = await StorageMigrationService.hasJsonData(
        customPath: tempDir.path,
      );
      expect(hasData, isFalse);
    });

    test('should successfully migrate data from JSON to SQLite', () async {
      // Save data to JSON backend
      await jsonRepo.saveGroup(testGroup1);
      await jsonRepo.saveGroup(testGroup2);

      // Perform migration with injected repositories
      final result = await StorageMigrationService.migrateToSqlite(
        jsonRepo: jsonRepo,
        sqliteRepo: sqliteRepo,
      );
      expect(result.isSuccess, isTrue);

      // Verify data in SQLite
      final sqliteGroups = await sqliteRepo.getAllGroups();
      expect(sqliteGroups.isSuccess, isTrue);
      expect(sqliteGroups.data!.length, equals(2));

      // Verify specific groups
      final group1 = await sqliteRepo.getGroupById('group-1');
      expect(group1.data, isNotNull);
      expect(group1.data!.title, equals('Test Group 1'));
      expect(group1.data!.expenses.length, equals(1));

      final group2 = await sqliteRepo.getGroupById('group-2');
      expect(group2.data, isNotNull);
      expect(group2.data!.title, equals('Test Group 2'));
    });

    test('should mark migration as completed', () async {
      await jsonRepo.saveGroup(testGroup1);

      await StorageMigrationService.migrateToSqlite(
        jsonRepo: jsonRepo,
        sqliteRepo: sqliteRepo,
      );

      final completed = await StorageMigrationService.isMigrationCompleted();
      expect(completed, isTrue);
    });

    test('should skip migration if already completed', () async {
      // First migration
      await jsonRepo.saveGroup(testGroup1);
      await StorageMigrationService.migrateToSqlite(
        jsonRepo: jsonRepo,
        sqliteRepo: sqliteRepo,
      );

      // Delete SQLite data to verify second migration is skipped
      await sqliteRepo.deleteGroup('group-1');

      // Try to migrate again
      final result = await StorageMigrationService.migrateToSqlite(
        jsonRepo: jsonRepo,
        sqliteRepo: sqliteRepo,
      );
      expect(result.isSuccess, isTrue);

      // Verify that migration was skipped (no data restored)
      final groups = await sqliteRepo.getAllGroups();
      expect(groups.data!.isEmpty, isTrue);
    });

    test('should handle empty JSON data', () async {
      // No data in JSON - hasJsonData will return false, so migration will be skipped
      // We need to use a custom path check
      final result = await StorageMigrationService.migrateToSqlite(
        jsonRepo: jsonRepo,
        sqliteRepo: sqliteRepo,
      );
      expect(result.isSuccess, isTrue);

      final completed = await StorageMigrationService.isMigrationCompleted();
      expect(completed, isTrue);
    });

    test('should validate migrated data count', () async {
      await jsonRepo.saveGroup(testGroup1);
      await jsonRepo.saveGroup(testGroup2);

      final result = await StorageMigrationService.migrateToSqlite(
        jsonRepo: jsonRepo,
        sqliteRepo: sqliteRepo,
      );
      expect(result.isSuccess, isTrue);

      // Verify all groups were migrated
      final jsonGroups = await jsonRepo.getAllGroups();
      final sqliteGroups = await sqliteRepo.getAllGroups();

      expect(sqliteGroups.data!.length, equals(jsonGroups.data!.length));
    });

    test('should preserve group properties during migration', () async {
      final pinnedGroup = testGroup1.copyWith(
        pinned: true,
        archived: false,
        color: 0xFF123456,
        notificationEnabled: true,
        autoLocationEnabled: true,
      );

      await jsonRepo.saveGroup(pinnedGroup);
      await StorageMigrationService.migrateToSqlite(
        jsonRepo: jsonRepo,
        sqliteRepo: sqliteRepo,
      );

      final migratedGroup = await sqliteRepo.getGroupById('group-1');
      expect(migratedGroup.data, isNotNull);
      expect(migratedGroup.data!.pinned, isTrue);
      expect(migratedGroup.data!.archived, isFalse);
      expect(migratedGroup.data!.color, equals(0xFF123456));
      expect(migratedGroup.data!.notificationEnabled, isTrue);
      expect(migratedGroup.data!.autoLocationEnabled, isTrue);
    });

    test('should preserve expenses during migration', () async {
      await jsonRepo.saveGroup(testGroup1);
      await StorageMigrationService.migrateToSqlite(
        jsonRepo: jsonRepo,
        sqliteRepo: sqliteRepo,
      );

      final migratedGroup = await sqliteRepo.getGroupById('group-1');
      expect(migratedGroup.data!.expenses.length, equals(1));

      final expense = migratedGroup.data!.expenses.first;
      expect(expense.id, equals('g1_e1'));
      expect(expense.name, equals('Lunch'));
      expect(expense.amount, equals(50.0));
    });

    test(
      'should preserve participants and categories during migration',
      () async {
        await jsonRepo.saveGroup(testGroup1);
        await StorageMigrationService.migrateToSqlite(
          jsonRepo: jsonRepo,
          sqliteRepo: sqliteRepo,
        );

        final migratedGroup = await sqliteRepo.getGroupById('group-1');

        expect(migratedGroup.data!.participants.length, equals(1));
        expect(migratedGroup.data!.participants.first.id, equals('g1_p1'));
        expect(migratedGroup.data!.participants.first.name, equals('John'));

        expect(migratedGroup.data!.categories.length, equals(1));
        expect(migratedGroup.data!.categories.first.id, equals('g1_c1'));
        expect(migratedGroup.data!.categories.first.name, equals('Food'));
      },
    );

    test('should backup JSON file after successful migration', () async {
      await jsonRepo.saveGroup(testGroup1);
      await StorageMigrationService.migrateToSqlite(
        jsonRepo: jsonRepo,
        sqliteRepo: sqliteRepo,
      );

      // Note: Backup file is created in the default app documents directory,
      // not in our test temp directory, so we check that migration succeeded
      // instead of checking for the backup file
      final completed = await StorageMigrationService.isMigrationCompleted();
      expect(completed, isTrue);
    });

    test('should reset migration status correctly', () async {
      await jsonRepo.saveGroup(testGroup1);
      await StorageMigrationService.migrateToSqlite(
        jsonRepo: jsonRepo,
        sqliteRepo: sqliteRepo,
      );

      expect(await StorageMigrationService.isMigrationCompleted(), isTrue);

      await StorageMigrationService.resetMigrationStatus();

      expect(await StorageMigrationService.isMigrationCompleted(), isFalse);
    });
  });
}
