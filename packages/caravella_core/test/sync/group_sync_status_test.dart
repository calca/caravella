import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 26, 18);

  test('never synced is stale', () {
    final s = GroupSyncStatus.from(
      lastSyncAt: null,
      lastHadErrors: false,
      now: now,
    );
    expect(s.health, GroupSyncHealth.stale);
    expect(s.lastSyncAt, isNull);
  });

  test('synced within a day is ok, older is stale', () {
    expect(
      GroupSyncStatus.from(
        lastSyncAt: now.subtract(const Duration(hours: 23)),
        lastHadErrors: false,
        now: now,
      ).health,
      GroupSyncHealth.ok,
    );
    expect(
      GroupSyncStatus.from(
        lastSyncAt: now.subtract(const Duration(hours: 25)),
        lastHadErrors: false,
        now: now,
      ).health,
      GroupSyncHealth.stale,
    );
  });

  test('errors in the last exchange win over its age', () {
    final s = GroupSyncStatus.from(
      lastSyncAt: now.subtract(const Duration(minutes: 5)),
      lastHadErrors: true,
      now: now,
    );
    expect(s.health, GroupSyncHealth.failed);
  });
}
