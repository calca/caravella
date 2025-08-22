import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:org_app_caravella/settings/auto_backup_notifier.dart';
import 'package:org_app_caravella/settings/backup_service.dart';

void main() {
  group('AutoBackupNotifier', () {
    late AutoBackupNotifier notifier;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      BackupService.debugForceAndroid = true; // simulate Android
      SharedPreferences.setMockInitialValues({});

      // Mock the backup platform channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('org.app.caravella/backup'),
            (MethodCall methodCall) async {
              switch (methodCall.method) {
                case 'isBackupEnabled':
                  return false; // Default to disabled
                case 'setBackupExcluded':
                  return true; // Success
                case 'triggerBackup':
                  return true; // Success
                default:
                  return null;
              }
            },
          );

      notifier = AutoBackupNotifier();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('org.app.caravella/backup'),
            null,
          );
    });

    test('should initialize with default values', () async {
      // Wait for the initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.enabled, false);
      expect(notifier.lastAutoBackup, null);
      expect(notifier.lastManualBackup, null);
    });

    test('should handle platform backup state sync', () async {
      // Wait for the initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.enabled, false);
    });

    test('should call platform methods when setting enabled state', () async {
      // Wait for the initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      List<MethodCall> methodCalls = [];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('org.app.caravella/backup'),
            (MethodCall methodCall) async {
              methodCalls.add(methodCall);
              switch (methodCall.method) {
                case 'isBackupEnabled':
                  return false;
                case 'setBackupExcluded':
                  return true;
                case 'triggerBackup':
                  return true;
                default:
                  return null;
              }
            },
          );

      // Enable auto backup
      await notifier.setEnabled(true);

      // Should have called platform methods
      expect(methodCalls.length, greaterThan(0));
      expect(
        methodCalls.any(
          (call) =>
              call.method == 'setBackupExcluded' ||
              call.method == 'triggerBackup',
        ),
        true,
      );
    });

    test('should notify listeners when state changes', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      bool notified = false;
      notifier.addListener(() {
        notified = true;
      });

      await notifier.setEnabled(true);
      expect(notified, true);
    });

    test('should handle platform method failures gracefully', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      // Mock platform method failure
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('org.app.caravella/backup'),
            (MethodCall methodCall) async {
              throw PlatformException(code: 'ERROR', message: 'Platform error');
            },
          );

      final initialState = notifier.enabled;

      // Attempt to change state - should handle error gracefully
      await notifier.setEnabled(!initialState);

      // State should remain unchanged due to platform error
      expect(notifier.enabled, initialState);
    });

    test('should update manual backup timestamp', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(notifier.lastManualBackup, null);
      
      await notifier.updateManualBackupTimestamp();
      
      expect(notifier.lastManualBackup, isNotNull);
      expect(notifier.lastManualBackup!.isBefore(DateTime.now()), true);
      // Should be within the last second
      expect(
        DateTime.now().difference(notifier.lastManualBackup!).inSeconds < 1,
        true,
      );
    });
  });
}
