import 'package:flutter_test/flutter_test.dart';
import 'package:play_store_updates/play_store_updates.dart';

void main() {
  group('UpdateServiceFactory', () {
    // The test runner never passes --dart-define=ENABLE_PLAY_UPDATES=true,
    // so `bool.fromEnvironment` resolves to its documented default (false)
    // here — this locks in the F-Droid/no-flag behavior.
    test('isPlayUpdatesEnabled defaults to false without the dart-define', () {
      expect(UpdateServiceFactory.isPlayUpdatesEnabled, isFalse);
    });

    test('createUpdateService falls back to NoOpUpdateService by default', () {
      expect(
        UpdateServiceFactory.createUpdateService(),
        isA<NoOpUpdateService>(),
      );
    });

    test('createUpdateNotifier falls back to NoOpUpdateNotifier by default', () {
      expect(
        UpdateServiceFactory.createUpdateNotifier(),
        isA<NoOpUpdateNotifier>(),
      );
    });
  });
}
