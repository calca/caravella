import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncResult', () {
    test('empty() has zeroed counters', () {
      final result = SyncResult.empty();
      expect(result.applied, equals(0));
      expect(result.skipped, equals(0));
      expect(result.errors, equals(0));
      expect(result.channel, isEmpty);
      expect(result.peerId, isEmpty);
    });

    test('merge sums applied, skipped, errors', () {
      final a = SyncResult(
        applied: 3,
        skipped: 1,
        errors: 0,
        channel: 'lan',
        peerId: 'peer-a',
        syncedAt: DateTime.utc(2024, 1, 1),
      );
      final b = SyncResult(
        applied: 2,
        skipped: 4,
        errors: 1,
        channel: 'bt',
        peerId: 'peer-b',
        syncedAt: DateTime.utc(2024, 6, 1),
      );

      final merged = SyncResult.merge(a, b);
      expect(merged.applied, equals(5));
      expect(merged.skipped, equals(5));
      expect(merged.errors, equals(1));
    });

    test('merge keeps the later syncedAt', () {
      final earlier = DateTime.utc(2024, 1, 1);
      final later = DateTime.utc(2024, 6, 1);

      final a = SyncResult(
        applied: 0, skipped: 0, errors: 0,
        channel: 'lan', peerId: 'a', syncedAt: later,
      );
      final b = SyncResult(
        applied: 0, skipped: 0, errors: 0,
        channel: 'lan', peerId: 'b', syncedAt: earlier,
      );

      expect(SyncResult.merge(a, b).syncedAt, equals(later));
      expect(SyncResult.merge(b, a).syncedAt, equals(later));
    });

    test('merge keeps channel and peerId of first argument', () {
      final a = SyncResult(
        applied: 0, skipped: 0, errors: 0,
        channel: 'lan', peerId: 'peer-a', syncedAt: DateTime.utc(2024),
      );
      final b = SyncResult(
        applied: 0, skipped: 0, errors: 0,
        channel: 'bt', peerId: 'peer-b', syncedAt: DateTime.utc(2024),
      );

      final merged = SyncResult.merge(a, b);
      expect(merged.channel, equals('lan'));
      expect(merged.peerId, equals('peer-a'));
    });
  });
}
