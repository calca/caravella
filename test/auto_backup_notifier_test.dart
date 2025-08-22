import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:org_app_caravella/settings/auto_backup_notifier.dart';

void main() {
  group('AutoBackupNotifier', () {
    late AutoBackupNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      notifier = AutoBackupNotifier();
    });

    test('should initialize with default value false', () async {
      // Wait for the initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.enabled, false);
    });

    test('should persist enabled state', () async {
      // Wait for the initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Enable auto backup
      await notifier.setEnabled(true);
      expect(notifier.enabled, true);
      
      // Verify persistence by creating a new instance
      final newNotifier = AutoBackupNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(newNotifier.enabled, true);
    });

    test('should persist disabled state', () async {
      // Wait for the initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Enable then disable auto backup
      await notifier.setEnabled(true);
      await notifier.setEnabled(false);
      expect(notifier.enabled, false);
      
      // Verify persistence by creating a new instance
      final newNotifier = AutoBackupNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(newNotifier.enabled, false);
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
  });
}