import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('migration_test')
      .path;
  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sqflite for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  PathProviderPlatform.instance = _FakePathProvider();

  group('StorageMigrationService', () {
    late FileBasedExpenseGroupRepository jsonRepo;
    late SqliteExpenseGroupRepository sqliteRepo;
    late ExpenseGroup testGroup1;
    late ExpenseGroup testGroup2;

    setUp(() async {
      // Reset SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      jsonRepo = FileBasedExpenseGroupRepository();
      sqliteRepo = SqliteExpenseGroupRepository();

      // Clean up any existing test data
      try {
        final dir = await getApplicationDocumentsDirectory();
        
        // Delete JSON file
        final jsonFile = File('${dir.path}/expense_group_storage.json');
        if (await jsonFile.exists()) {
          await jsonFile.delete();
        }
        
        // Delete SQLite database
        final dbFile = File('${dir.path}/expense_groups.db');
        if (await dbFile.exists()) {
          await dbFile.delete();
        }
      } catch (e) {
        // Ignore errors during cleanup
      }

      // Reset migration status
      await StorageMigrationService.resetMigrationStatus();

      // Set up test data
      final participant = ExpenseParticipant(name: 'John', id: 'p1');
      final category = ExpenseCategory(name: 'Food', id: 'c1');

      testGroup1 = ExpenseGroup(
        id: 'group-1',
        title: 'Test Group 1',
        currency: 'USD',
        participants: [participant],
        categories: [category],
        expenses: [
          ExpenseDetails(
            id: 'e1',
            category: category,
            amount: 50.0,
            paidBy: participant,
            date: DateTime.now(),
            name: 'Lunch',
          ),
        ],
        timestamp: DateTime.now(),
      );

      testGroup2 = ExpenseGroup(
        id: 'group-2',
        title: 'Test Group 2',
        currency: 'EUR',
        participants: [participant],
        categories: [category],
        expenses: [],
        timestamp: DateTime.now(),
      );
    });

    tearDown(() async {
      jsonRepo.clearCache();
      await sqliteRepo.close();
    });

    test('should detect when migration is not completed', () async {
      final completed = await StorageMigrationService.isMigrationCompleted();
      expect(completed, isFalse);
    });

    test('should detect when JSON data exists', () async {
      // Save data to JSON
      await jsonRepo.saveGroup(testGroup1);
      
      final hasData = await StorageMigrationService.hasJsonData();
      expect(hasData, isTrue);
    });

    test('should detect when JSON data does not exist', () async {
      final hasData = await StorageMigrationService.hasJsonData();
      expect(hasData, isFalse);
    });

    test('should successfully migrate data from JSON to SQLite', () async {
      // Save data to JSON backend
      await jsonRepo.saveGroup(testGroup1);
      await jsonRepo.saveGroup(testGroup2);

      // Perform migration
      final result = await StorageMigrationService.migrateToSqlite();
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
      
      await StorageMigrationService.migrateToSqlite();
      
      final completed = await StorageMigrationService.isMigrationCompleted();
      expect(completed, isTrue);
    });

    test('should skip migration if already completed', () async {
      // First migration
      await jsonRepo.saveGroup(testGroup1);
      await StorageMigrationService.migrateToSqlite();

      // Delete SQLite data to verify second migration is skipped
      await sqliteRepo.deleteGroup('group-1');

      // Try to migrate again
      final result = await StorageMigrationService.migrateToSqlite();
      expect(result.isSuccess, isTrue);

      // Verify that migration was skipped (no data restored)
      final groups = await sqliteRepo.getAllGroups();
      expect(groups.data!.isEmpty, isTrue);
    });

    test('should handle empty JSON data', () async {
      // No data in JSON
      final result = await StorageMigrationService.migrateToSqlite();
      expect(result.isSuccess, isTrue);

      final completed = await StorageMigrationService.isMigrationCompleted();
      expect(completed, isTrue);
    });

    test('should validate migrated data count', () async {
      await jsonRepo.saveGroup(testGroup1);
      await jsonRepo.saveGroup(testGroup2);

      final result = await StorageMigrationService.migrateToSqlite();
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
      await StorageMigrationService.migrateToSqlite();

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
      await StorageMigrationService.migrateToSqlite();

      final migratedGroup = await sqliteRepo.getGroupById('group-1');
      expect(migratedGroup.data!.expenses.length, equals(1));
      
      final expense = migratedGroup.data!.expenses.first;
      expect(expense.id, equals('e1'));
      expect(expense.name, equals('Lunch'));
      expect(expense.amount, equals(50.0));
    });

    test('should preserve participants and categories during migration', () async {
      await jsonRepo.saveGroup(testGroup1);
      await StorageMigrationService.migrateToSqlite();

      final migratedGroup = await sqliteRepo.getGroupById('group-1');
      
      expect(migratedGroup.data!.participants.length, equals(1));
      expect(migratedGroup.data!.participants.first.id, equals('p1'));
      expect(migratedGroup.data!.participants.first.name, equals('John'));
      
      expect(migratedGroup.data!.categories.length, equals(1));
      expect(migratedGroup.data!.categories.first.id, equals('c1'));
      expect(migratedGroup.data!.categories.first.name, equals('Food'));
    });

    test('should backup JSON file after successful migration', () async {
      await jsonRepo.saveGroup(testGroup1);
      await StorageMigrationService.migrateToSqlite();

      final dir = await getApplicationDocumentsDirectory();
      final files = Directory(dir.path).listSync();
      
      // Check if backup file was created
      final backupFiles = files.where((f) => 
        f.path.contains('expense_group_storage.json.backup')
      );
      
      expect(backupFiles.isNotEmpty, isTrue);
    });

    test('should reset migration status correctly', () async {
      await jsonRepo.saveGroup(testGroup1);
      await StorageMigrationService.migrateToSqlite();

      expect(await StorageMigrationService.isMigrationCompleted(), isTrue);

      await StorageMigrationService.resetMigrationStatus();
      
      expect(await StorageMigrationService.isMigrationCompleted(), isFalse);
    });
  });
}
