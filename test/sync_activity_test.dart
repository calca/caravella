import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/widgets.dart';
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

/// Records the exchanges [SyncActivity] asks for.
class _Recording extends SyncOrchestrator {
  _Recording(SqliteExpenseGroupRepository repo)
    : super(
        lanChannel: LanSyncChannel(mdns: false),
        syncManager: SyncManager(repository: repo),
      );

  final lan = <({Duration delay, bool rediscover})>[];

  @override
  void requestLanSync({
    Duration delay = const Duration(seconds: 3),
    bool rediscover = false,
  }) => lan.add((delay: delay, rediscover: rediscover));

  @override
  void requestCloudSync({Duration delay = const Duration(seconds: 30)}) {}
}

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

  test('a group from my own devices (Google Drive) is not announced', () {
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
          channel: 'cloud',
          peerId: 'my-tablet',
          syncedAt: DateTime(2026, 11, 10),
          groupIds: {'g1'},
          newGroupIds: {'g1'},
          peerName: 'Tablet',
        ),
      ),
    );

    expect(groups.updatedGroupIds, contains('g1'));
    expect(notified, 0);
    expect(activity.takeReceived(), isEmpty);
  });

  group('Wi-Fi exchanges asked for', () {
    late Directory dir;
    late SqliteExpenseGroupRepository repo;
    late _Recording orchestrator;
    late ExpenseGroupNotifier groups;
    late SyncActivity activity;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('sync_activity');
      repo = SqliteExpenseGroupRepository(databasePath: '${dir.path}/a.db');
      orchestrator = _Recording(repo);
      groups = ExpenseGroupNotifier();
      activity = SyncActivity(groups)..attach(orchestrator);
    });

    tearDown(() async {
      activity.dispose();
      await repo.close();
      dir.deleteSync(recursive: true);
    });

    test('a change here asks for one', () {
      groups.notifyGroupUpdated('g1');
      expect(orchestrator.lan, [
        (delay: const Duration(seconds: 3), rediscover: false),
      ]);
    });

    test('changes that came from a sync do not ask for one back', () {
      activity.handle(_done(applied: 1, ids: {'g1'}));
      expect(groups.updatedGroupIds, contains('g1'));
      expect(orchestrator.lan, isEmpty);
    });

    testWidgets('back in the app: look for the phones again; leaving: now', (
      tester,
    ) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(orchestrator.lan.last, (delay: Duration.zero, rediscover: false));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(orchestrator.lan.last, (
        delay: const Duration(seconds: 1),
        rediscover: true,
      ));
    });
  });
}
