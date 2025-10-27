import 'dart:io';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/logger_service.dart';

/// Service for managing Google Play Store in-app updates.
///
/// This service provides functionality to:
/// - Check if an update is available
/// - Start flexible updates (background download)
/// - Start immediate updates (blocking update flow)
/// - Automatic weekly update checks
///
/// Note: This only works on Android with Google Play Services.
/// The app must be downloaded from Google Play Store for this to work.
class AppUpdateService {
  static const String _lastCheckKey = 'last_update_check_timestamp';
  static const Duration _checkInterval = Duration(days: 7);

  /// Check if it's time to perform an automatic update check.
  ///
  /// Returns true if more than 7 days have passed since the last check,
  /// or if no check has been performed yet.
  static Future<bool> shouldCheckForUpdate() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckTimestamp = prefs.getInt(_lastCheckKey);

      if (lastCheckTimestamp == null) {
        // First time, should check
        return true;
      }

      final lastCheck = DateTime.fromMillisecondsSinceEpoch(lastCheckTimestamp);
      final now = DateTime.now();
      final difference = now.difference(lastCheck);

      return difference >= _checkInterval;
    } catch (e) {
      return false;
    }
  }

  /// Save the current timestamp as the last update check time.
  static Future<void> recordUpdateCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Check if an update is available from Google Play Store.
  ///
  /// Returns an [AppUpdateInfo] object if an update is available,
  /// or null if no update is available or on unsupported platforms.
  static Future<AppUpdateInfo?> checkForUpdate() async {
    // Only available on Android
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      // Return null if no update is available
      if (updateInfo.updateAvailability != UpdateAvailability.updateAvailable) {
        return null;
      }

      return updateInfo;
    } on PlatformException catch (e) {
      // Handle specific platform exceptions
      if (e.code == 'TASK_FAILURE') {
        // This happens when the app is not installed from Google Play Store
        // (e.g., debug builds, sideloaded APKs, F-Droid builds)
        LoggerService.info('Update check skipped: App not from Play Store');
        return null;
      }
      LoggerService.warning('Update check failed: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      // Handle any other errors silently
      LoggerService.warning('Update check error: $e');
      return null;
    }
  }

  /// Start a flexible update flow.
  ///
  /// Flexible updates allow the user to continue using the app while
  /// the update downloads in the background.
  ///
  /// Returns true if the update was started successfully.
  static Future<bool> startFlexibleUpdate() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      await InAppUpdate.startFlexibleUpdate();
      return true;
    } on PlatformException catch (e) {
      if (e.code == 'TASK_FAILURE') {
        LoggerService.info('Flexible update skipped: App not from Play Store');
        return false;
      }
      LoggerService.warning('Flexible update failed: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      LoggerService.warning('Flexible update error: $e');
      return false;
    }
  }

  /// Complete a flexible update.
  ///
  /// After a flexible update is downloaded, call this method to
  /// install the update. This will restart the app.
  ///
  /// Returns true if the update was completed successfully.
  static Future<bool> completeFlexibleUpdate() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      await InAppUpdate.completeFlexibleUpdate();
      return true;
    } on PlatformException catch (e) {
      if (e.code == 'TASK_FAILURE') {
        LoggerService.info('Complete update skipped: App not from Play Store');
        return false;
      }
      LoggerService.warning('Complete update failed: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      LoggerService.warning('Complete update error: $e');
      return false;
    }
  }

  /// Start an immediate update flow.
  ///
  /// Immediate updates block the user from using the app until
  /// the update is installed. Use this for critical updates.
  ///
  /// Returns true if the update was started successfully.
  static Future<bool> startImmediateUpdate() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      await InAppUpdate.performImmediateUpdate();
      return true;
    } on PlatformException catch (e) {
      if (e.code == 'TASK_FAILURE') {
        LoggerService.info('Immediate update skipped: App not from Play Store');
        return false;
      }
      LoggerService.warning(
        'Immediate update failed: ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      LoggerService.warning('Immediate update error: $e');
      return false;
    }
  }

  /// Check if an update is available and return user-friendly information.
  ///
  /// Returns a map with:
  /// - 'available': bool - whether an update is available
  /// - 'version': String? - available version code (if available)
  /// - 'priority': int? - update priority (0-5, higher is more important)
  /// - 'immediateAllowed': bool - whether immediate update is allowed
  /// - 'flexibleAllowed': bool - whether flexible update is allowed
  static Future<Map<String, dynamic>> getUpdateStatus() async {
    final updateInfo = await checkForUpdate();

    if (updateInfo == null) {
      return {
        'available': false,
        'version': null,
        'priority': null,
        'immediateAllowed': false,
        'flexibleAllowed': false,
      };
    }

    return {
      'available': true,
      'version': updateInfo.availableVersionCode?.toString(),
      'priority': updateInfo.updatePriority,
      'immediateAllowed': updateInfo.immediateUpdateAllowed,
      'flexibleAllowed': updateInfo.flexibleUpdateAllowed,
    };
  }
}
