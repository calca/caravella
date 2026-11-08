import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/sync/widgets/paired_device_sheet.dart';
import 'package:io_caravella_egm/sync/widgets/paired_devices_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zentoast/zentoast.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late SqliteExpenseGroupRepository repository;
  late SyncOrchestrator orchestrator;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = Directory.systemTemp.createTempSync(
      'paired_devices_${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = SqliteExpenseGroupRepository(
      databasePath: '${tempDir.path}/repo.db',
    );
    await repository.getAllGroups();
    orchestrator = SyncOrchestrator(
      lanChannel: LanSyncChannel(),
      syncManager: SyncManager(repository: repository),
    );
    // LAN is off by default in tests: no platform channel is touched.
    await orchestrator.initialize();
  });

  tearDown(() async {
    await repository.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<void> pair(String device, String name, String group) =>
      orchestrator.handlePairingCompleted(device, name, 'android', group);

  Widget app(Widget home) => ToastProvider.create(
    child: MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      builder: (context, child) => Stack(
        children: [
          ?child,
          const ToastViewer(alignment: Alignment.bottomCenter),
        ],
      ),
      home: home,
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
  }

  // The toast layer sits over the bottom of the screen in this harness, so
  // buttons there are pressed directly.
  void press(WidgetTester tester, String label) {
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    button.onPressed!();
  }

  // Removing a device is real sqlite work: wait for it (and the sheet's
  // closing and the list's reload) as long as a slow machine needs.
  Future<void> settleUntil(WidgetTester tester, bool Function() done) async {
    for (var i = 0; i < 50 && !done(); i++) {
      await settle(tester);
    }
  }

  AppLocalizations locOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(Scaffold).first));

  test('device sync info: never synced, with the groups it shares', () async {
    await pair('phone-2', 'Pixel 9', 'g1');
    await pair('phone-2', 'Pixel 9', 'g2');
    final info = await orchestrator.getDeviceSyncInfo('phone-2');
    expect(info.lastSyncAt, isNull);
    expect(info.lastFailed, isFalse);
    expect(info.groupIds, unorderedEquals(['g1', 'g2']));
  });

  testWidgets('a group\'s device: never updated, then taken off the group', (
    tester,
  ) async {
    await tester.runAsync(() => pair('phone-2', 'Pixel 9', 'g1'));
    await tester.pumpWidget(
      app(
        Scaffold(
          body: PairedDevicesList(
            orchestrator: orchestrator,
            groupId: 'g1',
            groupTitle: 'Lisbon',
          ),
        ),
      ),
    );
    await settle(tester);
    expect(find.text('Pixel 9'), findsOneWidget);
    expect(find.textContaining('Never updated'), findsOneWidget);

    await tester.tap(find.text('Pixel 9'));
    await settle(tester);
    expect(find.byType(PairedDeviceSheet), findsOneWidget);
    final loc = locOf(tester);
    // LAN sync is off: "Update now" is disabled and says why.
    expect(find.text(loc.sync_device_update_wifi_off), findsOneWidget);

    press(tester, loc.sync_device_remove_from('Lisbon'));
    await settle(tester);
    expect(
      find.text(loc.sync_device_remove_title('Pixel 9', 'Lisbon')),
      findsOneWidget,
    );
    press(tester, loc.sync_device_remove_confirm);
    await settleUntil(
      tester,
      () => find.byType(PairedDeviceSheet).evaluate().isEmpty,
    );

    expect(find.byType(PairedDeviceSheet), findsNothing);
    expect(
      await tester.runAsync(() => orchestrator.getPairedDevicesForGroup('g1')),
      isEmpty,
    );
    // Only this group: the device stays paired.
    expect(
      await tester.runAsync(() => orchestrator.getPairedDevices()),
      hasLength(1),
    );
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('every device: cancelling keeps it, forgetting removes it', (
    tester,
  ) async {
    await tester.runAsync(() => pair('phone-2', 'Pixel 9', 'g1'));
    await tester.pumpWidget(
      app(Scaffold(body: PairedDevicesList(orchestrator: orchestrator))),
    );
    await settle(tester);
    await tester.tap(find.text('Pixel 9'));
    await settle(tester);
    final loc = locOf(tester);

    press(tester, loc.sync_device_forget);
    await settle(tester);
    press(tester, loc.cancel);
    await settle(tester);
    expect(find.byType(PairedDeviceSheet), findsOneWidget);

    press(tester, loc.sync_device_forget);
    await settle(tester);
    press(tester, loc.sync_device_forget_confirm);
    await settleUntil(tester, () => find.text('Pixel 9').evaluate().isEmpty);
    expect(
      await tester.runAsync(() => orchestrator.getPairedDevices()),
      isEmpty,
    );
    expect(find.text('Pixel 9'), findsNothing);
    await tester.pump(const Duration(seconds: 10));
  });
}
