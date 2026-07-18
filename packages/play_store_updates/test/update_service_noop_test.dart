import 'package:flutter_test/flutter_test.dart';
import 'package:play_store_updates/play_store_updates.dart';

void main() {
  group('NoOpUpdateService', () {
    const service = NoOpUpdateService();

    test('shouldCheckForUpdate is always false', () async {
      expect(await service.shouldCheckForUpdate(), isFalse);
    });

    test('recordUpdateCheck completes without doing anything', () async {
      await expectLater(service.recordUpdateCheck(), completes);
    });

    test('checkForUpdate never finds an update', () async {
      expect(await service.checkForUpdate(), isNull);
    });

    test('startFlexibleUpdate/completeFlexibleUpdate/startImmediateUpdate '
        'all report failure', () async {
      expect(await service.startFlexibleUpdate(), isFalse);
      expect(await service.completeFlexibleUpdate(), isFalse);
      expect(await service.startImmediateUpdate(), isFalse);
    });

    test('getUpdateStatus reports no update available', () async {
      final status = await service.getUpdateStatus();
      expect(status, {
        'available': false,
        'version': null,
        'priority': null,
        'immediateAllowed': false,
        'flexibleAllowed': false,
      });
    });
  });

  group('NoOpUpdateNotifier', () {
    test('exposes only the empty/false default state', () {
      final notifier = NoOpUpdateNotifier();

      expect(notifier.isChecking, isFalse);
      expect(notifier.updateAvailable, isFalse);
      expect(notifier.availableVersion, isNull);
      expect(notifier.updatePriority, isNull);
      expect(notifier.immediateAllowed, isFalse);
      expect(notifier.flexibleAllowed, isFalse);
      expect(notifier.isDownloading, isFalse);
      expect(notifier.isInstalling, isFalse);
      expect(notifier.error, isNull);
    });

    test('mutating methods are no-ops and never notify listeners', () async {
      final notifier = NoOpUpdateNotifier();
      var notified = false;
      notifier.addListener(() => notified = true);

      await notifier.checkForUpdate();
      expect(await notifier.startFlexibleUpdate(), isFalse);
      expect(await notifier.completeFlexibleUpdate(), isFalse);
      expect(await notifier.startImmediateUpdate(), isFalse);
      notifier.clearError();
      notifier.reset();

      expect(notified, isFalse);
    });
  });
}
