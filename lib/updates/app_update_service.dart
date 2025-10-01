import 'dart:io';
import 'package:in_app_update/in_app_update.dart';

/// Service for managing Google Play Store in-app updates.
/// 
/// This service provides functionality to:
/// - Check if an update is available
/// - Start flexible updates (background download)
/// - Start immediate updates (blocking update flow)
/// 
/// Note: This only works on Android with Google Play Services.
class AppUpdateService {
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
      if (!updateInfo.updateAvailability.isUpdateAvailable) {
        return null;
      }
      
      return updateInfo;
    } catch (e) {
      // Handle errors silently (e.g., no Google Play Services)
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
      final result = await InAppUpdate.startFlexibleUpdate();
      return result == AppUpdateResult.success;
    } catch (e) {
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
      final result = await InAppUpdate.completeFlexibleUpdate();
      return result == AppUpdateResult.success;
    } catch (e) {
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
      final result = await InAppUpdate.performImmediateUpdate();
      return result == AppUpdateResult.success;
    } catch (e) {
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
