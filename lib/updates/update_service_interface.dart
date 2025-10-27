import 'package:flutter/material.dart';

/// Abstract interface for app update functionality.
/// 
/// This allows for different implementations:
/// - PlayStoreUpdateService: Real implementation using Google Play
/// - NoOpUpdateService: Empty implementation for F-Droid builds
abstract class UpdateService {
  /// Check if it's time to perform an automatic update check.
  Future<bool> shouldCheckForUpdate();
  
  /// Save the current timestamp as the last update check time.
  Future<void> recordUpdateCheck();
  
  /// Check if an update is available.
  /// Returns a map with update information or null if no update available.
  Future<Map<String, dynamic>?> checkForUpdate();
  
  /// Start a flexible update flow.
  Future<bool> startFlexibleUpdate();
  
  /// Complete a flexible update (install and restart).
  Future<bool> completeFlexibleUpdate();
  
  /// Start an immediate update flow.
  Future<bool> startImmediateUpdate();
  
  /// Get detailed update status.
  Future<Map<String, dynamic>> getUpdateStatus();
}

/// Abstract interface for update state notifier.
abstract class UpdateNotifier extends ChangeNotifier {
  bool get isChecking;
  bool get updateAvailable;
  String? get availableVersion;
  int? get updatePriority;
  bool get immediateAllowed;
  bool get flexibleAllowed;
  bool get isDownloading;
  bool get isInstalling;
  String? get error;
  
  Future<void> checkForUpdate();
  Future<bool> startFlexibleUpdate();
  Future<bool> completeFlexibleUpdate();
  Future<bool> startImmediateUpdate();
  void clearError();
  void reset();
}
