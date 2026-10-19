import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/sync/sync_activity.dart';

SyncCompleted _done({int applied = 1, int errors = 0, Set<String>? ids}) =>
    SyncCompleted(
      SyncResult(
        applied: applied,
        skipped: 0,
        errors: errors,
        channel: 'lan',
        peerId: 'peer',
        syncedAt: DateTime(2026, 10, 19),
        groupIds: ids ?? {'g1'},
      ),
    );

void main() {
  test('changes from a sync refresh the touched groups', () {
    final groups = ExpenseGroupNotifier();
    final activity = SyncActivity(groups);
    final before = groups.revision;

    activity.handle(_done(applied: 0));
    expect(groups.revision, before, reason: 'nothing applied, no refresh');

    activity.handle(_done(applied: 2, ids: {'g1', 'g2'}));
    expect(groups.updatedGroupIds, containsAll(['g1', 'g2']));
    expect(groups.revision, greaterThan(before));
  });
}
