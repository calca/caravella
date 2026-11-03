import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/sync/sync_problem_tile.dart';
import 'package:material_ui/material_ui.dart';

/// #606: a "To fix" row says which group and device, why and what to do.
void main() {
  Future<void> pump(WidgetTester tester, SyncProblem p, SyncNames names) =>
      tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: SyncProblemTile(problem: p, names: names),
          ),
        ),
      );

  final at = DateTime.now().toUtc().subtract(const Duration(minutes: 5));

  testWidgets('a group not shared with a paired device', (tester) async {
    await pump(
      tester,
      SyncProblem(
        reason: SyncProblemReason.notShared,
        channel: 'lan',
        peerId: 'p9',
        groupId: 'g1',
        at: at,
      ),
      const SyncNames(devices: {'p9': 'Pixel 9'}, groups: {'g1': 'Norway'}),
    );
    expect(find.text('Norway · Pixel 9'), findsOneWidget);
    expect(
      find.text(
        'Pixel 9 sent this group, but it isn’t shared with that device '
        'here: share it again',
      ),
      findsOneWidget,
    );
    expect(find.text('5 min'), findsOneWidget);
  });

  testWidgets('a device no longer paired, by the name it gave', (tester) async {
    await pump(
      tester,
      SyncProblem(
        reason: SyncProblemReason.notPaired,
        channel: 'lan',
        peerId: 'tab',
        peerName: 'Sara’s tablet',
        at: at,
      ),
      const SyncNames(),
    );
    expect(find.text('Sara’s tablet'), findsOneWidget);
    expect(
      find.text('Not paired any more: pair it again from “Sync with others”'),
      findsOneWidget,
    );
  });

  testWidgets('the cloud is Google Drive, an unknown peer says so', (
    tester,
  ) async {
    await pump(
      tester,
      SyncProblem(
        reason: SyncProblemReason.cloudUnreachable,
        channel: 'cloud',
        peerId: 'cloud',
        at: at,
      ),
      const SyncNames(),
    );
    expect(find.text('Google Drive'), findsOneWidget);

    await pump(
      tester,
      SyncProblem(
        reason: SyncProblemReason.peerError,
        channel: 'lan',
        peerId: 'x',
        at: at,
      ),
      const SyncNames(),
    );
    expect(find.text('Unknown device'), findsOneWidget);
  });
}
