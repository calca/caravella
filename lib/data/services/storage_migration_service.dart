import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../model/expense_group.dart';
import '../hive_expense_group_repository.dart';
import '../file_based_expense_group_repository.dart';
import 'logger_service.dart';

/// Service to automatically migrate data from JSON file storage to Hive
class StorageMigrationService {
  static const String jsonFileName = 'expense_group_storage.json';
  static const String migrationMarkerFile = '.hive_migration_done';
  
  /// Checks if migration from JSON to Hive is needed and performs it
  /// Returns true if migration was performed or already done, false on error
  static Future<bool> migrateJsonToHiveIfNeeded() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final jsonFile = File('${dir.path}/$jsonFileName');
      final markerFile = File('${dir.path}/$migrationMarkerFile');
      
      // Check if migration was already done
      if (await markerFile.exists()) {
        LoggerService.info(
          'Hive migration already completed',
          name: 'migration',
        );
        return true;
      }
      
      // Check if JSON file exists
      if (!await jsonFile.exists()) {
        LoggerService.info(
          'No JSON file found, skipping migration',
          name: 'migration',
        );
        // Create marker to avoid checking again
        await markerFile.create();
        return true;
      }
      
      LoggerService.info(
        'Starting migration from JSON to Hive...',
        name: 'migration',
      );
      
      // Read and parse JSON file
      final contents = await jsonFile.readAsString();
      if (contents.trim().isEmpty) {
        LoggerService.info(
          'JSON file is empty, skipping migration',
          name: 'migration',
        );
        await _completeMigration(jsonFile, markerFile);
        return true;
      }
      
      final List<dynamic> jsonData = json.decode(contents);
      final groups = jsonData
          .map((j) => ExpenseGroup.fromJson(j as Map<String, dynamic>))
          .toList();
      
      LoggerService.info(
        'Found ${groups.length} groups to migrate',
        name: 'migration',
      );
      
      // Migrate to Hive
      final hiveRepo = HiveExpenseGroupRepository();
      int successCount = 0;
      int errorCount = 0;
      
      for (final group in groups) {
        final result = await hiveRepo.saveGroup(group);
        if (result.isSuccess) {
          successCount++;
          LoggerService.info(
            'Migrated group: ${group.title} (${group.id})',
            name: 'migration',
          );
        } else {
          errorCount++;
          LoggerService.warning(
            'Failed to migrate group ${group.title}: ${result.error}',
            name: 'migration',
          );
        }
      }
      
      await hiveRepo.close();
      
      LoggerService.info(
        'Migration completed: $successCount succeeded, $errorCount failed',
        name: 'migration',
      );
      
      // Only delete JSON file and create marker if all migrations succeeded
      if (errorCount == 0) {
        await _completeMigration(jsonFile, markerFile);
        return true;
      } else {
        LoggerService.warning(
          'Migration had errors, keeping JSON file as backup',
          name: 'migration',
        );
        return false;
      }
    } catch (e) {
      LoggerService.warning(
        'Error during migration: $e',
        name: 'migration',
      );
      return false;
    }
  }
  
  /// Completes migration by deleting JSON file and creating marker
  static Future<void> _completeMigration(File jsonFile, File markerFile) async {
    try {
      // Delete the JSON file
      await jsonFile.delete();
      LoggerService.info(
        'Deleted JSON file after successful migration',
        name: 'migration',
      );
      
      // Create marker file to prevent future migrations
      await markerFile.create();
      await markerFile.writeAsString(DateTime.now().toIso8601String());
      LoggerService.info(
        'Created migration marker file',
        name: 'migration',
      );
    } catch (e) {
      LoggerService.warning(
        'Error completing migration: $e',
        name: 'migration',
      );
    }
  }
  
  /// Resets migration marker (useful for testing)
  static Future<void> resetMigrationMarker() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final markerFile = File('${dir.path}/$migrationMarkerFile');
      if (await markerFile.exists()) {
        await markerFile.delete();
        LoggerService.info(
          'Reset migration marker',
          name: 'migration',
        );
      }
    } catch (e) {
      LoggerService.warning(
        'Error resetting migration marker: $e',
        name: 'migration',
      );
    }
  }
}
