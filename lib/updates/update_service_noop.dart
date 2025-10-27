import 'package:flutter/material.dart';
import 'update_service_interface.dart';

/// No-op implementation of UpdateService for builds without Play Store support.
/// 
/// This implementation is used when ENABLE_PLAY_UPDATES is not defined,
/// such as in F-Droid builds.
class NoOpUpdateService implements UpdateService {
  const NoOpUpdateService();
  
  @override
  Future<bool> shouldCheckForUpdate() async => false;
  
  @override
  Future<void> recordUpdateCheck() async {}
  
  @override
  Future<Map<String, dynamic>?> checkForUpdate() async => null;
  
  @override
  Future<bool> startFlexibleUpdate() async => false;
  
  @override
  Future<bool> completeFlexibleUpdate() async => false;
  
  @override
  Future<bool> startImmediateUpdate() async => false;
  
  @override
  Future<Map<String, dynamic>> getUpdateStatus() async => {
    'available': false,
    'version': null,
    'priority': null,
    'immediateAllowed': false,
    'flexibleAllowed': false,
  };
}

/// No-op implementation of UpdateNotifier for builds without Play Store support.
class NoOpUpdateNotifier extends ChangeNotifier implements UpdateNotifier {
  @override
  bool get isChecking => false;
  
  @override
  bool get updateAvailable => false;
  
  @override
  String? get availableVersion => null;
  
  @override
  int? get updatePriority => null;
  
  @override
  bool get immediateAllowed => false;
  
  @override
  bool get flexibleAllowed => false;
  
  @override
  bool get isDownloading => false;
  
  @override
  bool get isInstalling => false;
  
  @override
  String? get error => null;
  
  @override
  Future<void> checkForUpdate() async {}
  
  @override
  Future<bool> startFlexibleUpdate() async => false;
  
  @override
  Future<bool> completeFlexibleUpdate() async => false;
  
  @override
  Future<bool> startImmediateUpdate() async => false;
  
  @override
  void clearError() {}
  
  @override
  void reset() {}
}
