import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncClock', () {
    test('nowMs returns a positive integer', () {
      expect(SyncClock.nowMs(), greaterThan(0));
    });

    test('nowMs is monotonically increasing', () {
      final t1 = SyncClock.nowMs();
      final t2 = SyncClock.nowMs();
      expect(t2, greaterThanOrEqualTo(t1));
    });

    test('toIso and fromIso round-trip', () {
      final ms = 1700000000000; // fixed known value
      final iso = SyncClock.toIso(ms);
      final back = SyncClock.fromIso(iso);
      expect(back, equals(ms));
    });

    test('fromIso parses ISO 8601 strings', () {
      final ms = SyncClock.fromIso('2024-01-01T00:00:00.000Z');
      expect(ms, equals(1704067200000));
    });
  });
}
