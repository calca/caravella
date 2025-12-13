import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for managing attachment storage locations
/// Attachments are saved to Documents/Caravella/$GroupName for OS backup
class AttachmentsStorageService {
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
  /// Returns: Documents/Caravella/$groupName_$groupId/
  /// 
  /// The groupName is sanitized to be filesystem-safe and groupId is appended for uniqueness
  static Future<Directory> getGroupAttachmentsDirectory(
    String groupName,
    String groupId,
  ) async {
    final caravellaDir = await getCaravellaDirectory();
    final sanitizedName = _sanitizeDirectoryName(groupName);
    // Append groupId (first 8 chars) to ensure uniqueness even with duplicate names
    final uniqueDirName = '${sanitizedName}_${groupId.substring(0, 8)}';
    final groupDir = Directory(path.join(caravellaDir.path, uniqueDirName));
    
    if (!await groupDir.exists()) {
      await groupDir.create(recursive: true);
    }
    
    return groupDir;
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
      return false;
    }
  }

  /// Get the full path for a new attachment file
  /// Returns: Documents/Caravella/$groupName_$groupId/$timestamp_$filename
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
