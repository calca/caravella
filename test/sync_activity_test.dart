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

  test('a group shared for the first time is announced once', () {
    final groups = ExpenseGroupNotifier();
    final activity = SyncActivity(groups);
    var notified = 0;
    activity.addListener(() => notified++);

    activity.handle(
      SyncCompleted(
        SyncResult(
          applied: 1,
          skipped: 0,
          errors: 0,
          channel: 'lan',
          peerId: 'peer',
          syncedAt: DateTime(2026, 10, 26),
          groupIds: {'g1'},
          newGroupIds: {'g1'},
          peerName: 'Pixel 9',
        ),
      ),
    );
    expect(notified, 1);
    expect(activity.takeReceived(), [(groupId: 'g1', from: 'Pixel 9')]);
    expect(activity.takeReceived(), isEmpty);

    // An update to a group already here isn't announced.
    activity.handle(_done(applied: 1, ids: {'g1'}));
    expect(notified, 1);
  });
}
