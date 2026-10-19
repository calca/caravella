import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/sync/group_sync_badge.dart';
import 'package:io_caravella_egm/sync/sync_activity.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

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
  test('tracks syncing, synced and failed per group', () {
    final activity = SyncActivity(ExpenseGroupNotifier());
    expect(activity.stateOf('g1'), GroupSyncState.idle);

    activity.handle(const SyncStarted('lan'));
    expect(activity.stateOf('g1'), GroupSyncState.syncing);

    activity.handle(_done());
    expect(activity.stateOf('g1'), GroupSyncState.synced);
    expect(activity.stateOf('other'), GroupSyncState.idle);

    activity.handle(_done(errors: 1));
    expect(activity.stateOf('g1'), GroupSyncState.error);

    activity.handle(const SyncFailed('offline'));
    expect(activity.stateOf('other'), GroupSyncState.error);
  });

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

  testWidgets('the Shared badge speaks its sync state', (tester) async {
    final activity = SyncActivity(ExpenseGroupNotifier());
    final group = ExpenseGroup(
      id: 'g1',
      title: 'Rome',
      expenses: [],
      participants: [],
      currency: '€',
      syncEnabled: true,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: activity,
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: GroupSyncBadge(
              group: group,
              background: Colors.black12,
              foreground: Colors.black,
            ),
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Shared'), findsOneWidget);

    activity.handle(const SyncStarted('lan'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    activity.handle(const SyncFailed('offline'));
    await tester.pump();
    expect(find.bySemanticsLabel(RegExp('sync failed')), findsOneWidget);
  });
}
