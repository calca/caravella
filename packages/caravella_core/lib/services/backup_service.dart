import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

/// Service to interact with native platform backup functionality
class BackupService {
  static const MethodChannel _channel = MethodChannel(
    'io.caravella.egm/backup',
  );
  // Test override to simulate Android environment in unit tests
  @visibleForTesting
  static bool? debugForceAndroid;

  /// Check if backup is currently enabled/available
  static Future<bool> isBackupEnabled() async {
    try {
      if (Platform.isAndroid || debugForceAndroid == true) {
        return await _channel.invokeMethod('isBackupEnabled') ?? false;
      } else if (Platform.isIOS) {
        return await _channel.invokeMethod('isBackupExcluded') ?? false;
      }
      return false;
    } catch (e) {
      // If platform doesn't support backup or method fails, return false
      return false;
    }
  }

  /// Enable or disable backup functionality
  static Future<bool> setBackupEnabled(bool enabled) async {
    try {
      if (Platform.isAndroid || debugForceAndroid == true) {
        if (enabled) {
          // Request a backup on Android when enabling
          return await _channel.invokeMethod('triggerBackup') ?? false;
        }
        // Turning it off is the app's own preference (saved by
        // AutoBackupNotifier), which CaravellaBackupAgent reads to skip
        // cloud backups: nothing to do on the platform side.
        return true;
      } else if (Platform.isIOS) {
        // On iOS, we control backup exclusion (opposite of enabled)
        return await _channel.invokeMethod('setBackupExcluded', {
              'excluded': !enabled,
            }) ??
            false;
      }
      return false;
    } catch (e) {
      // If platform doesn't support backup or method fails, return false
      return false;
    }
  }

  /// When Android last backed the app up to the cloud (Auto Backup), or
  /// `null` if it hasn't yet since this was tracked — or off Android.
  static Future<DateTime?> lastBackupTime() async {
    try {
      if (Platform.isAndroid || debugForceAndroid == true) {
        final ms = await _channel.invokeMethod<int>('lastBackupTime') ?? 0;
        return ms > 0 ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Request an immediate backup (Android only)
  static Future<bool> requestBackup() async {
    try {
      if (Platform.isAndroid || debugForceAndroid == true) {
        return await _channel.invokeMethod('triggerBackup') ?? false;
      }
      // iOS backup is automatic, so just return true
      return true;
    } catch (e) {
      return false;
    }
  }
}
