import 'dart:async';
import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/sync/widgets/paired_device_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zentoast/zentoast.dart';

/// Bluetooth channel that never touches the platform: the test pushes its
/// events and decides how a requested exchange ends.
class _FakeBluetooth extends BluetoothSyncChannel {
  final events$ = StreamController<BluetoothPeerEvent>.broadcast();
  final List<String> requested = [];
  Completer<SyncResult>? exchange;
  String? updateTarget;
  Object? startError;
  bool stopped = false;
  bool disposed = false;

  @override
  Stream<BluetoothPeerEvent> get events => events$.stream;
  @override
  bool get isAdvertising => updateTarget != null;
  @override
  bool get isDiscovering => updateTarget != null;
  @override
  Future<bool> requestPermissions() async => true;
  @override
  Future<void> startAdvertising({
    required String groupId,
    String groupTitle = '',
  }) async {}
  @override
  Future<void> startDiscovery() async {}
  @override
  Future<void> startUpdate({required String targetDeviceId}) async {
    if (startError != null) throw startError!;
    updateTarget = targetDeviceId;
  }

  @override
  Future<void> stopAll() async => stopped = true;
  @override
  Future<SyncResult> syncWithPeer(String endpointId) {
    requested.add(endpointId);
    exchange = Completer<SyncResult>();
    return exchange!.future;
  }

  @override
  void dispose() => disposed = true;
}

SyncResult _result({int applied = 2, int sent = 1, int errors = 0}) =>
    SyncResult(
      applied: applied,
      sent: sent,
      skipped: 0,
      errors: errors,
      channel: 'nearby',
      peerId: 'phone-2',
      syncedAt: DateTime.utc(2026, 12, 20),
    );

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late SqliteExpenseGroupRepository repository;
  late SyncOrchestrator orchestrator;
  late _FakeBluetooth bt;
  var btEnabled = true;
  var turnedOn = false;

  // 'a-phone' sorts before 'phone-2' (this phone initiates); 'z-phone'
  // sorts after it (this phone waits).
  const initiatorId = 'a-phone';
  const waiterId = 'z-phone';

  final device = PairedDevice(
    deviceId: 'phone-2',
    deviceName: 'Pixel 9',
    platform: 'android',
    pairedAt: DateTime.utc(2026, 12, 1),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    btEnabled = true;
    turnedOn = false;
    bt = _FakeBluetooth();
    tempDir = Directory.systemTemp.createTempSync(
      'paired_device_bt_${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = SqliteExpenseGroupRepository(
      databasePath: '${tempDir.path}/repo.db',
    );
    await repository.getAllGroups();
    orchestrator = SyncOrchestrator(
      lanChannel: LanSyncChannel(),
      syncManager: SyncManager(repository: repository),
    );
    // Wi-Fi sync is off by default in tests: no platform channel is touched.
    await orchestrator.initialize();
  });

  tearDown(() async {
    await repository.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Widget app() => ToastProvider.create(
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
      home: const Scaffold(body: SizedBox.expand()),
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
  }

  /// Opens the sheet over the app; [groupTitle] null = opened from Settings.
  Future<void> open(
    WidgetTester tester, {
    String ownId = initiatorId,
    String? groupTitle = 'Lisbon',
    bool withBluetooth = true,
  }) async {
    await tester.pumpWidget(app());
    final context = tester.element(find.byType(Scaffold));
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => PairedDeviceSheet(
          orchestrator: orchestrator,
          device: device,
          info: const DeviceSyncInfo(
            lastSyncAt: null,
            lastFailed: false,
            groupIds: [],
          ),
          groupTitles: const [],
          groupId: groupTitle == null ? null : 'g1',
          groupTitle: groupTitle,
          ownDeviceId: ownId,
          createBluetooth: withBluetooth ? () => bt : null,
          isBluetoothEnabled: () async => btEnabled,
          onTurnOnBluetooth: () async {
            turnedOn = true;
            btEnabled = true;
          },
        ),
      ),
    );
    await settle(tester);
  }

  AppLocalizations locOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(PairedDeviceSheet)));

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

  Future<void> startUpdate(WidgetTester tester) async {
    press(tester, locOf(tester).sync_device_update_now);
    await settle(tester);
  }

  Future<void> push(WidgetTester tester, BluetoothPeerEvent event) async {
    bt.events$.add(event);
    // Broadcast events need two pumps to reach the listener and rebuild.
    await tester.pump();
    await tester.pump();
  }

  PeerFound target({String endpoint = 'ep-1'}) => PeerFound(
    name: 'Pixel 9',
    endpointId: endpoint,
    updateDeviceId: 'phone-2',
  );

  testWidgets('Wi-Fi off: goes straight to Bluetooth, advertising and '
      'discovering for the device', (tester) async {
    await open(tester);
    final loc = locOf(tester);
    expect(find.text(loc.sync_update_bt_hint), findsOneWidget);

    await startUpdate(tester);

    expect(bt.updateTarget, 'phone-2');
    expect(bt.isAdvertising && bt.isDiscovering, isTrue);
    expect(find.text(loc.sync_update_step_wifi), findsOneWidget);
    expect(find.text(loc.sync_update_wifi_skipped_off), findsOneWidget);
    expect(find.text(loc.sync_update_bt_close), findsOneWidget);
    expect(
      find.text(loc.sync_update_bt_instruction_group('Pixel 9', 'Lisbon')),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('opened from Settings: the instruction names the Settings path', (
    tester,
  ) async {
    await open(tester, groupTitle: null);
    await startUpdate(tester);
    expect(
      find.text(locOf(tester).sync_update_bt_instruction_settings('Pixel 9')),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('target found and this phone has the smaller ID: it requests '
      'the exchange, then closes with the counts', (tester) async {
    await open(tester);
    final loc = locOf(tester);
    await startUpdate(tester);

    await push(tester, target());
    expect(bt.requested, ['ep-1']);
    expect(find.text(loc.sync_update_bt_found), findsOneWidget);

    bt.exchange!.complete(_result());
    await settle(tester);
    expect(find.text(loc.sync_update_bt_done(2, 1)), findsOneWidget);
    expect(find.byType(PairedDeviceSheet), findsOneWidget);

    await tester.pump(PairedDeviceSheet.doneDelay);
    await tester.pumpAndSettle();
    expect(find.byType(PairedDeviceSheet), findsNothing);
    expect(bt.stopped, isTrue);
    expect(bt.disposed, isTrue);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('target found and this phone has the larger ID: it does not '
      'request, and completes on the incoming exchange', (tester) async {
    await open(tester, ownId: waiterId);
    final loc = locOf(tester);
    await startUpdate(tester);

    await push(tester, target());
    expect(bt.requested, isEmpty);
    expect(find.text(loc.sync_update_bt_found), findsOneWidget);

    await push(tester, BtSyncCompleted(result: _result(applied: 0, sent: 3)));
    expect(find.text(loc.sync_update_bt_done(0, 3)), findsOneWidget);
    expect(bt.requested, isEmpty);

    await tester.pump(PairedDeviceSheet.doneDelay);
    await tester.pumpAndSettle();
    expect(find.byType(PairedDeviceSheet), findsNothing);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('an unknown device, an invitation and an exchange with someone '
      'else are ignored', (tester) async {
    await open(tester);
    final loc = locOf(tester);
    await startUpdate(tester);

    await push(
      tester,
      const PeerFound(
        name: 'Stranger',
        endpointId: 'ep-x',
        updateDeviceId: 'someone-else',
      ),
    );
    await push(
      tester,
      const PeerFound(
        name: 'Pixel 9',
        endpointId: 'ep-y',
        groupTitle: 'Lisbon',
      ),
    );
    await push(
      tester,
      BtSyncCompleted(
        result: SyncResult(
          applied: 1,
          skipped: 0,
          errors: 0,
          channel: 'nearby',
          peerId: 'someone-else',
          syncedAt: DateTime.utc(2026, 12, 20),
        ),
      ),
    );

    expect(bt.requested, isEmpty);
    expect(find.text(loc.sync_update_bt_close), findsOneWidget);
    expect(find.text(loc.sync_update_bt_found), findsNothing);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('a request that fails while the other direction succeeds is '
      'not a failure', (tester) async {
    await open(tester);
    final loc = locOf(tester);
    await startUpdate(tester);

    await push(tester, target());
    bt.exchange!.complete(_result(applied: 0, sent: 0, errors: 1));
    await tester.pump();
    await tester.pump();

    await push(tester, BtSyncCompleted(result: _result()));
    expect(find.text(loc.sync_update_bt_done(2, 1)), findsOneWidget);
    // The grace timer was cancelled: no retry, no failure.
    await tester.pump(PairedDeviceSheet.collisionGrace);
    expect(bt.requested, ['ep-1']);
    await tester.pump(PairedDeviceSheet.doneDelay);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('a request that keeps failing is retried once, then reported', (
    tester,
  ) async {
    await open(tester);
    final loc = locOf(tester);
    await startUpdate(tester);

    await push(tester, target());
    bt.exchange!.complete(_result(errors: 1));
    await tester.pump();
    await tester.pump(PairedDeviceSheet.collisionGrace);
    expect(bt.requested, ['ep-1', 'ep-1']);

    bt.exchange!.complete(_result(errors: 1));
    await tester.pump();
    await tester.pump(PairedDeviceSheet.collisionGrace);
    await tester.pump();
    expect(find.text(loc.sync_bt_error_detail), findsOneWidget);
    expect(find.text(loc.sync_bt_retry), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('Cancel stops Bluetooth and returns to the sheet', (
    tester,
  ) async {
    await open(tester);
    final loc = locOf(tester);
    await startUpdate(tester);
    expect(bt.stopped, isFalse);

    press(tester, loc.cancel);
    await settle(tester);

    expect(bt.stopped, isTrue);
    expect(bt.disposed, isTrue);
    expect(find.byType(PairedDeviceSheet), findsOneWidget);
    expect(find.text(loc.sync_update_bt_close), findsNothing);
    expect(find.text(loc.sync_device_update_now), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('closing the sheet stops Bluetooth', (tester) async {
    await open(tester);
    await startUpdate(tester);
    expect(bt.stopped, isFalse);

    Navigator.of(tester.element(find.byType(PairedDeviceSheet))).pop();
    await tester.pumpAndSettle();

    expect(find.byType(PairedDeviceSheet), findsNothing);
    expect(bt.stopped, isTrue);
    expect(bt.disposed, isTrue);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('Bluetooth switched off: offers Turn on, then starts', (
    tester,
  ) async {
    btEnabled = false;
    await open(tester);
    final loc = locOf(tester);
    await startUpdate(tester);

    expect(bt.updateTarget, isNull);
    expect(find.text(loc.sync_bt_off_title), findsOneWidget);

    press(tester, loc.sync_join_turn_on);
    await settle(tester);

    expect(turnedOn, isTrue);
    expect(bt.updateTarget, 'phone-2');
    expect(find.text(loc.sync_update_bt_close), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets(
    'no Bluetooth in the build: Wi-Fi off keeps Update now disabled',
    (tester) async {
      await open(tester, withBluetooth: false);
      final loc = locOf(tester);
      expect(find.text(loc.sync_device_update_wifi_off), findsOneWidget);
      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text(loc.sync_device_update_now),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      expect(button.onPressed, isNull);
      await tester.pump(const Duration(seconds: 10));
    },
  );

  testWidgets('Bluetooth that cannot start says so, with Retry', (
    tester,
  ) async {
    bt.startError = const BluetoothPermissionDeniedException();
    await open(tester);
    final loc = locOf(tester);
    await startUpdate(tester);

    expect(find.text(loc.sync_bt_permission_denied), findsOneWidget);
    expect(find.text(loc.sync_bt_retry), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
  });
}
