import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/logging/logger_service.dart';
import '../model/expense_group.dart';
import 'expense_group_repository.dart';
import 'file_based_expense_group_repository.dart';
import 'sqlite_expense_group_repository.dart';
import 'storage_errors.dart';

/// Service to migrate data from JSON file storage to SQLite database
class StorageMigrationService {
  static const String _migrationCompletedKey = 'storage_migration_completed';
  static const String _migrationVersionKey = 'storage_migration_version';
  static const int _currentMigrationVersion = 1;

  /// Check if migration has already been completed
  static Future<bool> isMigrationCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_migrationCompletedKey) ?? false;
      final version = prefs.getInt(_migrationVersionKey) ?? 0;
      return completed && version >= _currentMigrationVersion;
    } catch (e) {
      LoggerService.warning(
        'Failed to check migration status: $e',
        name: 'migration',
      );
      return false;
    }
  }

  /// Check if JSON storage file exists and has data
  static Future<bool> hasJsonData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/expense_group_storage.json');
      if (!await file.exists()) return false;
      
      final contents = await file.readAsString();
      return contents.trim().isNotEmpty && contents.trim() != '[]';
    } catch (e) {
      LoggerService.warning(
        'Failed to check JSON data existence: $e',
        name: 'migration',
      );
      return false;
    }
  }

  /// Perform migration from JSON to SQLite
  static Future<StorageResult<void>> migrateToSqlite() async {
    try {
      LoggerService.info('Starting migration from JSON to SQLite', name: 'migration');

      // Check if migration is needed
      final migrationCompleted = await isMigrationCompleted();
      if (migrationCompleted) {
        LoggerService.info('Migration already completed', name: 'migration');
        return const StorageResult.success(null);
      }

      // Check if there's data to migrate
      final hasData = await hasJsonData();
      if (!hasData) {
        LoggerService.info('No JSON data to migrate', name: 'migration');
        await _markMigrationCompleted();
        return const StorageResult.success(null);
      }

      // Load data from JSON
      final jsonRepo = FileBasedExpenseGroupRepository();
      final loadResult = await jsonRepo.getAllGroups();
      
      if (loadResult.isFailure) {
        LoggerService.warning(
          'Failed to load data from JSON: ${loadResult.error}',
          name: 'migration',
        );
        return StorageResult.failure(
          MigrationError(
            'Failed to load data from JSON storage',
            details: loadResult.error?.message ?? 'Unknown error',
          ),
        );
      }

      final groups = loadResult.data ?? [];
      LoggerService.info('Loaded ${groups.length} groups from JSON', name: 'migration');

      if (groups.isEmpty) {
        LoggerService.info('No groups to migrate', name: 'migration');
        await _markMigrationCompleted();
        return const StorageResult.success(null);
      }

      // Save data to SQLite
      final sqliteRepo = SqliteExpenseGroupRepository();
      
      int successCount = 0;
      int errorCount = 0;
      final errors = <String>[];

      for (final group in groups) {
        final saveResult = await sqliteRepo.saveGroup(group);
        if (saveResult.isSuccess) {
          successCount++;
        } else {
          errorCount++;
          errors.add('Group ${group.title} (${group.id}): ${saveResult.error?.message}');
          LoggerService.warning(
            'Failed to migrate group ${group.title}: ${saveResult.error}',
            name: 'migration',
          );
        }
      }

      LoggerService.info(
        'Migration completed: $successCount succeeded, $errorCount failed',
        name: 'migration',
      );

      if (errorCount > 0) {
        return StorageResult.failure(
          MigrationError(
            'Migration partially failed: $errorCount of ${groups.length} groups failed',
            details: errors.join('; '),
          ),
        );
      }

      // Validate migrated data
      final validationResult = await _validateMigration(groups, sqliteRepo);
      if (validationResult.isFailure) {
        return validationResult;
      }

      // Mark migration as completed
      await _markMigrationCompleted();

      // Optionally backup JSON file
      await _backupJsonFile();

      LoggerService.info('Migration successfully completed', name: 'migration');
      return const StorageResult.success(null);
    } catch (e) {
      LoggerService.warning('Migration failed with exception: $e', name: 'migration');
      return StorageResult.failure(
        MigrationError(
          'Migration failed with exception',
          details: e.toString(),
          cause: e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  /// Validate that migration was successful
  static Future<StorageResult<void>> _validateMigration(
    List<ExpenseGroup> originalGroups,
    SqliteExpenseGroupRepository sqliteRepo,
  ) async {
    try {
      LoggerService.info('Validating migration...', name: 'migration');

      final loadResult = await sqliteRepo.getAllGroups();
      if (loadResult.isFailure) {
        return StorageResult.failure(
          MigrationError(
            'Failed to load migrated data for validation',
            details: loadResult.error?.message ?? 'Unknown error',
          ),
        );
      }

      final migratedGroups = loadResult.data ?? [];

      if (migratedGroups.length != originalGroups.length) {
        return StorageResult.failure(
          MigrationError(
            'Migration validation failed: group count mismatch',
            details: 'Expected ${originalGroups.length}, found ${migratedGroups.length}',
          ),
        );
      }

      // Basic validation - check that all group IDs exist
      final originalIds = originalGroups.map((g) => g.id).toSet();
      final migratedIds = migratedGroups.map((g) => g.id).toSet();

      final missingIds = originalIds.difference(migratedIds);
      if (missingIds.isNotEmpty) {
        return StorageResult.failure(
          MigrationError(
            'Migration validation failed: missing groups',
            details: 'Missing group IDs: ${missingIds.join(', ')}',
          ),
        );
      }

      LoggerService.info('Migration validation passed', name: 'migration');
      return const StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        MigrationError(
          'Migration validation failed with exception',
          details: e.toString(),
          cause: e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  /// Mark migration as completed
  static Future<void> _markMigrationCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_migrationCompletedKey, true);
      await prefs.setInt(_migrationVersionKey, _currentMigrationVersion);
      LoggerService.info('Migration marked as completed', name: 'migration');
    } catch (e) {
      LoggerService.warning(
        'Failed to mark migration as completed: $e',
        name: 'migration',
      );
    }
  }

  /// Backup JSON file after successful migration
  static Future<void> _backupJsonFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final sourceFile = File('${dir.path}/expense_group_storage.json');
      
      if (await sourceFile.exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final backupFile = File('${dir.path}/expense_group_storage.json.backup.$timestamp');
        await sourceFile.copy(backupFile.path);
        LoggerService.info('JSON file backed up to ${backupFile.path}', name: 'migration');
      }
    } catch (e) {
      LoggerService.warning(
        'Failed to backup JSON file: $e',
        name: 'migration',
      );
      // Don't fail migration if backup fails
    }
  }

  /// Reset migration status (useful for testing)
  static Future<void> resetMigrationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_migrationCompletedKey);
      await prefs.remove(_migrationVersionKey);
      LoggerService.info('Migration status reset', name: 'migration');
    } catch (e) {
      LoggerService.warning(
        'Failed to reset migration status: $e',
        name: 'migration',
      );
    }
  }
}
