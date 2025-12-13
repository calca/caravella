import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../logging/logger_service.dart';

/// Service for managing attachment storage locations
/// Attachments are saved to Documents/Caravella/$GroupName for OS backup
class AttachmentsStorageService {
  static const String _metadataFileName = '.group_metadata';

  /// Get the base Caravella directory for attachments
  /// Returns: Documents/Caravella/
  static Future<Directory> getCaravellaDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final caravellaDir = Directory(path.join(documentsDir.path, 'Caravella'));
    
    if (!await caravellaDir.exists()) {
      await caravellaDir.create(recursive: true);
    }
    
    return caravellaDir;
  }

  /// Get the attachments directory for a specific group
  /// Returns: Documents/Caravella/$groupName/ or Documents/Caravella/$groupName_$groupId/
  /// 
  /// The groupName is sanitized to be filesystem-safe.
  /// GroupId is only appended if the directory exists and belongs to another group.
  static Future<Directory> getGroupAttachmentsDirectory(
    String groupName,
    String groupId,
  ) async {
    final caravellaDir = await getCaravellaDirectory();
    final sanitizedName = _sanitizeDirectoryName(groupName);
    
    // First, try using just the sanitized name
    var groupDir = Directory(path.join(caravellaDir.path, sanitizedName));
    
    // Check if directory exists and if it belongs to a different group
    if (await groupDir.exists()) {
      final existingGroupId = await _getGroupIdFromDirectory(groupDir);
      
      // If directory exists but belongs to a different group, or has no metadata, append groupId
      if (existingGroupId != groupId) {
        // Create unique directory name with groupId suffix
        final uniqueDirName = _createUniqueDirName(sanitizedName, groupId);
        groupDir = Directory(path.join(caravellaDir.path, uniqueDirName));
      }
      // else: existingGroupId == groupId, reuse the directory
    }
    
    // Create directory if it doesn't exist and write/update metadata
    if (!await groupDir.exists()) {
      await groupDir.create(recursive: true);
    }
    
    // Always ensure metadata file exists and is correct
    await _writeGroupIdToDirectory(groupDir, groupId);
    
    return groupDir;
  }

  /// Create a unique directory name by appending a short version of the groupId
  static String _createUniqueDirName(String sanitizedName, String groupId) {
    final shortId = groupId.length > 8 ? groupId.substring(0, 8) : groupId;
    return '${sanitizedName}_$shortId';
  }

  /// Read the groupId from a directory's metadata file
  static Future<String?> _getGroupIdFromDirectory(Directory dir) async {
    try {
      final metadataFile = File(path.join(dir.path, _metadataFileName));
      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        return content.trim(); // Trim whitespace to ensure clean comparison
      }
    } catch (e) {
      // If we can't read the metadata, log and return null
      LoggerService.warning(
        'Failed to read group metadata from ${dir.path}: $e',
        name: 'storage.attachments',
      );
    }
    return null;
  }

  /// Write the groupId to a directory's metadata file
  static Future<void> _writeGroupIdToDirectory(
    Directory dir,
    String groupId,
  ) async {
    try {
      final metadataFile = File(path.join(dir.path, _metadataFileName));
      await metadataFile.writeAsString(groupId);
    } catch (e) {
      // If we can't write metadata, log warning but continue anyway
      // The directory will still work, just without metadata tracking
      LoggerService.warning(
        'Failed to write group metadata to ${dir.path}: $e',
        name: 'storage.attachments',
      );
    }
  }

  /// Sanitize a group name to be filesystem-safe
  /// Removes or replaces characters that are problematic in filenames
  static String _sanitizeDirectoryName(String name) {
    // Replace problematic characters with underscores
    // Keep spaces, letters, numbers, and safe punctuation
    String sanitized = name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'[\x00-\x1F]'), '_') // Control characters
        .trim();
    
    // Limit length to 100 characters to avoid filesystem limits
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }
    
    // Ensure it's not empty
    if (sanitized.isEmpty) {
      sanitized = 'Unnamed';
    }
    
    return sanitized;
  }

  /// Delete all attachments for a specific group
  /// Returns true if deletion was successful
  static Future<bool> deleteGroupAttachments(
    String groupName,
    String groupId,
  ) async {
    try {
      final groupDir = await getGroupAttachmentsDirectory(groupName, groupId);
      if (await groupDir.exists()) {
        await groupDir.delete(recursive: true);
      }
      return true;
    } catch (e) {
      // Log error but don't throw - deletion failure shouldn't crash
      LoggerService.warning(
        'Failed to delete group attachments for $groupName: $e',
        name: 'storage.attachments',
      );
      return false;
    }
  }

  /// Get the full path for a new attachment file
  /// Returns: Documents/Caravella/$groupName/$timestamp_$filename
  /// or Documents/Caravella/$groupName_$groupId/$timestamp_$filename (if conflict exists)
  static Future<String> getAttachmentPath(
    String groupName,
    String groupId,
    String originalFilename,
  ) async {
    final groupDir = await getGroupAttachmentsDirectory(groupName, groupId);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = path.basename(originalFilename);
    return path.join(groupDir.path, '${timestamp}_$filename');
  }
}
