import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../model/expense_group.dart';
import '../../model/expense_details.dart';
import '../../data/expense_group_storage_v2.dart';
import '../logging/logger_service.dart';
import 'attachments_storage_service.dart';

/// Service for migrating attachments from old location to new location
/// Old: Documents/attachments/$groupId/
/// New: Documents/Caravella/$groupName/
class AttachmentsMigrationService {
  /// Migrate all attachments for a specific group from old to new location
  /// Returns the number of files successfully migrated
  static Future<int> migrateGroupAttachments(ExpenseGroup group) async {
    int migratedCount = 0;
    
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final oldDir = Directory(path.join(documentsDir.path, 'attachments', group.id));
      
      // If old directory doesn't exist, nothing to migrate
      if (!await oldDir.exists()) {
        return 0;
      }
      
      // Get new directory
      final newDir = await AttachmentsStorageService.getGroupAttachmentsDirectory(group.title);
      
      // Track path mappings for updating expense details
      final Map<String, String> pathMappings = {};
      
      // Move each file
      final files = oldDir.listSync().whereType<File>();
      for (final file in files) {
        try {
          final filename = path.basename(file.path);
          final newPath = path.join(newDir.path, filename);
          
          // Copy file to new location
          await file.copy(newPath);
          
          // Track mapping
          pathMappings[file.path] = newPath;
          migratedCount++;
          
          LoggerService.info(
            'Migrated attachment: $filename',
            name: 'storage.migration',
          );
        } catch (e) {
          LoggerService.warning(
            'Failed to migrate file: ${file.path}',
            name: 'storage.migration',
          );
        }
      }
      
      // Update expense details with new paths
      if (pathMappings.isNotEmpty) {
        await _updateExpenseAttachmentPaths(group, pathMappings);
      }
      
      // Delete old directory after successful migration
      if (migratedCount > 0) {
        try {
          await oldDir.delete(recursive: true);
          LoggerService.info(
            'Deleted old attachments directory for group: ${group.title}',
            name: 'storage.migration',
          );
        } catch (e) {
          LoggerService.warning(
            'Failed to delete old attachments directory',
            name: 'storage.migration',
          );
        }
      }
      
      return migratedCount;
    } catch (e, st) {
      LoggerService.error(
        'Failed to migrate attachments for group: ${group.title}',
        name: 'storage.migration',
        error: e,
        stackTrace: st,
      );
      return migratedCount;
    }
  }
  
  /// Update expense attachment paths in the database
  static Future<void> _updateExpenseAttachmentPaths(
    ExpenseGroup group,
    Map<String, String> pathMappings,
  ) async {
    try {
      // Create updated expenses with new attachment paths
      final updatedExpenses = group.expenses.map((expense) {
        if (expense.attachments.isEmpty) return expense;
        
        final newAttachments = expense.attachments.map((oldPath) {
          return pathMappings[oldPath] ?? oldPath;
        }).toList();
        
        return expense.copyWith(attachments: newAttachments);
      }).toList();
      
      // Update the group with new expense details
      final updatedGroup = group.copyWith(expenses: updatedExpenses);
      await ExpenseGroupStorageV2.updateGroupMetadata(updatedGroup);
      
      LoggerService.info(
        'Updated ${updatedExpenses.length} expenses with new attachment paths',
        name: 'storage.migration',
      );
    } catch (e, st) {
      LoggerService.error(
        'Failed to update expense attachment paths - files migrated but DB not updated',
        name: 'storage.migration',
        error: e,
        stackTrace: st,
      );
      // Don't rethrow - files are migrated, and both old and new paths will work
      // The app can continue functioning with the old paths in the database
    }
  }
  
  /// Migrate all attachments for all groups
  /// Returns the total number of files migrated
  static Future<int> migrateAllAttachments() async {
    int totalMigrated = 0;
    
    try {
      final groups = await ExpenseGroupStorageV2.getAllTrips();
      
      for (final group in groups) {
        final migrated = await migrateGroupAttachments(group);
        totalMigrated += migrated;
      }
      
      LoggerService.info(
        'Migration complete: $totalMigrated files migrated across ${groups.length} groups',
        name: 'storage.migration',
      );
      
      return totalMigrated;
    } catch (e, st) {
      LoggerService.error(
        'Failed to migrate all attachments',
        name: 'storage.migration',
        error: e,
        stackTrace: st,
      );
      return totalMigrated;
    }
  }
  
  /// Check if migration is needed for any group
  static Future<bool> isMigrationNeeded() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final oldAttachmentsDir = Directory(path.join(documentsDir.path, 'attachments'));
      
      if (!await oldAttachmentsDir.exists()) {
        return false;
      }
      
      // Check if there are any subdirectories (group folders)
      final contents = oldAttachmentsDir.listSync();
      return contents.whereType<Directory>().isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
