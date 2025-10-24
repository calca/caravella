import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:io_caravella_egm/data/services/storage_migration_service.dart';
import 'package:io_caravella_egm/data/services/hive_initialization_service.dart';
import 'package:io_caravella_egm/data/hive_expense_group_repository.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';
import 'package:io_caravella_egm/data/model/expense_details.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('migration_test')
      .path;
  
  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late Directory tempDir;
  late _FakePathProvider pathProvider;

  setUp(() async {
    // Create temporary directory for tests
    tempDir = Directory.systemTemp.createTempSync('migration_test');
    
    // Set up fake path provider
    pathProvider = _FakePathProvider();
    PathProviderPlatform.instance = pathProvider;
    
    // Initialize Hive with temporary path
    Hive.init(tempDir.path);
    await HiveInitializationService.initialize();
    
    // Reset migration marker before each test
    await StorageMigrationService.resetMigrationMarker();
  });

  tearDown(() async {
    // Clean up
    await HiveInitializationService.closeAll();
    
    // Clean up temporary directory
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('StorageMigrationService', () {
    test('should skip migration when no JSON file exists', () async {
      final result = await StorageMigrationService.migrateJsonToHiveIfNeeded();
      
      expect(result, isTrue);
      
      // Verify marker file was created
      final markerFile = File('${pathProvider._tempDir}/.hive_migration_done');
      expect(await markerFile.exists(), isTrue);
    });

    test('should skip migration when already done', () async {
      // Create marker file
      final markerFile = File('${pathProvider._tempDir}/.hive_migration_done');
      await markerFile.create();
      
      final result = await StorageMigrationService.migrateJsonToHiveIfNeeded();
      
      expect(result, isTrue);
    });

    test('should migrate data from JSON to Hive', () async {
      // Create test data
      final participant = ExpenseParticipant(name: 'John', id: 'p1');
      final category = ExpenseCategory(name: 'Food', id: 'c1');
      final testGroup = ExpenseGroup(
        id: 'test-group-1',
        title: 'Test Group',
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
      
      // Write JSON file
      final jsonFile = File('${pathProvider._tempDir}/expense_group_storage.json');
      final jsonData = [testGroup.toJson()];
      await jsonFile.writeAsString(json.encode(jsonData));
      
      // Perform migration
      final result = await StorageMigrationService.migrateJsonToHiveIfNeeded();
      
      expect(result, isTrue);
      
      // Verify JSON file was deleted
      expect(await jsonFile.exists(), isFalse);
      
      // Verify marker file was created
      final markerFile = File('${pathProvider._tempDir}/.hive_migration_done');
      expect(await markerFile.exists(), isTrue);
      
      // Verify data was migrated to Hive
      final hiveRepo = HiveExpenseGroupRepository();
      final groupResult = await hiveRepo.getGroupById('test-group-1');
      expect(groupResult.isSuccess, isTrue);
      expect(groupResult.data, isNotNull);
      expect(groupResult.data!.title, equals('Test Group'));
      expect(groupResult.data!.expenses.length, equals(1));
      
      await hiveRepo.close();
    });

    test('should migrate multiple groups', () async {
      final participant = ExpenseParticipant(name: 'John', id: 'p1');
      final category = ExpenseCategory(name: 'Food', id: 'c1');
      
      final group1 = ExpenseGroup(
        id: 'group-1',
        title: 'Group 1',
        currency: 'USD',
        participants: [participant],
        categories: [category],
        expenses: [],
        timestamp: DateTime.now(),
      );
      
      final group2 = ExpenseGroup(
        id: 'group-2',
        title: 'Group 2',
        currency: 'EUR',
        participants: [participant],
        categories: [category],
        expenses: [],
        timestamp: DateTime.now(),
      );
      
      // Write JSON file with multiple groups
      final jsonFile = File('${pathProvider._tempDir}/expense_group_storage.json');
      final jsonData = [group1.toJson(), group2.toJson()];
      await jsonFile.writeAsString(json.encode(jsonData));
      
      // Perform migration
      final result = await StorageMigrationService.migrateJsonToHiveIfNeeded();
      
      expect(result, isTrue);
      
      // Verify both groups were migrated
      final hiveRepo = HiveExpenseGroupRepository();
      final allGroupsResult = await hiveRepo.getAllGroups();
      expect(allGroupsResult.isSuccess, isTrue);
      expect(allGroupsResult.data!.length, equals(2));
      
      await hiveRepo.close();
    });

    test('should handle empty JSON file', () async {
      // Create empty JSON file
      final jsonFile = File('${pathProvider._tempDir}/expense_group_storage.json');
      await jsonFile.writeAsString('');
      
      // Perform migration
      final result = await StorageMigrationService.migrateJsonToHiveIfNeeded();
      
      expect(result, isTrue);
      
      // Verify JSON file was deleted
      expect(await jsonFile.exists(), isFalse);
      
      // Verify marker file was created
      final markerFile = File('${pathProvider._tempDir}/.hive_migration_done');
      expect(await markerFile.exists(), isTrue);
    });

    test('should keep JSON file on migration errors', () async {
      // Create invalid JSON file (will cause parsing error)
      final jsonFile = File('${pathProvider._tempDir}/expense_group_storage.json');
      await jsonFile.writeAsString('invalid json content');
      
      // Perform migration (should handle error)
      final result = await StorageMigrationService.migrateJsonToHiveIfNeeded();
      
      expect(result, isFalse);
      
      // Verify JSON file still exists (kept as backup)
      expect(await jsonFile.exists(), isTrue);
    });

    test('should reset migration marker', () async {
      // Create marker file
      final markerFile = File('${pathProvider._tempDir}/.hive_migration_done');
      await markerFile.create();
      expect(await markerFile.exists(), isTrue);
      
      // Reset marker
      await StorageMigrationService.resetMigrationMarker();
      
      // Verify marker was deleted
      expect(await markerFile.exists(), isFalse);
    });
  });
}
