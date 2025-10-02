import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/updates/app_update_notifier.dart';

void main() {
  group('AppUpdateNotifier', () {
    late AppUpdateNotifier notifier;

    setUp(() {
      notifier = AppUpdateNotifier();
    });

    test('initial state should be correct', () {
      expect(notifier.isChecking, false);
      expect(notifier.updateAvailable, false);
      expect(notifier.availableVersion, null);
      expect(notifier.updatePriority, null);
      expect(notifier.immediateAllowed, false);
      expect(notifier.flexibleAllowed, false);
      expect(notifier.isDownloading, false);
      expect(notifier.isInstalling, false);
      expect(notifier.error, null);
    });

    test('reset should clear all state', () {
      // Manually set some values (normally done by methods)
      notifier.reset();
      
      expect(notifier.isChecking, false);
      expect(notifier.updateAvailable, false);
      expect(notifier.availableVersion, null);
      expect(notifier.updatePriority, null);
      expect(notifier.immediateAllowed, false);
      expect(notifier.flexibleAllowed, false);
      expect(notifier.isDownloading, false);
      expect(notifier.isInstalling, false);
      expect(notifier.error, null);
    });

    test('clearError should clear error state', () {
      notifier.clearError();
      expect(notifier.error, null);
    });
  });
}
