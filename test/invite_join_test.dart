import 'dart:async';
import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/sync/invite_sheet.dart';
import 'package:io_caravella_egm/sync/join_group_page.dart';
import 'package:io_caravella_egm/sync/widgets/paired_devices_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zentoast/zentoast.dart';

/// Bluetooth channel that never touches the platform: the test pushes its
/// events and decides how an exchange ends.
class _FakeBluetooth extends BluetoothSyncChannel {
  final events$ = StreamController<BluetoothPeerEvent>.broadcast();
  Object? advertiseError;
  Object? discoveryError;
  Completer<SyncResult>? exchange;
  final List<String> synced = [];
  String? advertisedGroup;
  bool discovering = false;
  bool stopped = false;

  @override
  Stream<BluetoothPeerEvent> get events => events$.stream;
  @override
  bool get isAdvertising => advertisedGroup != null;
  @override
  bool get isDiscovering => false;
  @override
  Future<bool> requestPermissions() async => true;
  @override
  Future<void> startAdvertising({
    required String groupId,
    String groupTitle = '',
  }) async {
    if (advertiseError != null) throw advertiseError!;
    advertisedGroup = groupId;
  }

  @override
  Future<void> startDiscovery() async {
    if (discoveryError != null) throw discoveryError!;
    discovering = true;
  }

  @override
  Future<void> stopAll() async => stopped = true;
  @override
  Future<SyncResult> syncWithPeer(String endpointId) {
    synced.add(endpointId);
    exchange = Completer<SyncResult>();
    return exchange!.future;
  }

  @override
  void dispose() {}
}

SyncResult _ok() => SyncResult(
  applied: 1,
  skipped: 0,
  errors: 0,
  channel: 'bluetooth',
  peerId: 'phone-2',
  syncedAt: DateTime.utc(2026, 12, 20),
);

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late SqliteExpenseGroupRepository repository;
  late SyncOrchestrator orchestrator;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'invite_join_${DateTime.now().microsecondsSinceEpoch}',
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

  Widget app(Widget home) => ToastProvider.create(
    child: MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      // As in the app: toasts show in a ToastViewer above the page.
      builder: (context, child) => Stack(
        children: [
          ?child,
          const ToastViewer(alignment: Alignment.bottomCenter),
        ],
      ),
      home: home,
    ),
  );

  Future<void> settleDb(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }

  Future<void> pair(String device, String name, String group, String via) =>
      orchestrator.handlePairingCompleted(
        device,
        name,
        'android',
        group,
        channel: via,
      );

  group('PeerPaired', () {
    test('says which group, device and transport', () async {
      final next = orchestrator.events.firstWhere((e) => e is PeerPaired);
      await pair('phone-2', 'Pixel 9', 'g1', 'bluetooth');
      final event = await next as PeerPaired;
      expect(event.deviceId, 'phone-2');
      expect(event.deviceName, 'Pixel 9');
      expect(event.groupId, 'g1');
      expect(event.channel, 'bluetooth');
    });

    testWidgets('the device list shows a device as soon as it pairs', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          Scaffold(
            body: PairedDevicesList(orchestrator: orchestrator, groupId: 'g1'),
          ),
        ),
      );
      await settleDb(tester);
      expect(find.text('Pixel 9'), findsNothing);

      await tester.runAsync(() => pair('phone-2', 'Pixel 9', 'g1', 'lan'));
      await settleDb(tester);
      await settleDb(tester);

      expect(find.text('Pixel 9'), findsOneWidget);
    });
  });

  group('InviteSheet', () {
    Future<void> open(
      WidgetTester tester, {
      _FakeBluetooth? bluetooth,
      bool bluetoothOn = true,
      Future<void> Function()? onTurnOnBluetooth,
    }) async {
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => InviteSheet(
                    orchestrator: orchestrator,
                    groupId: 'g1',
                    groupTitle: 'Lisbon',
                    // Off: no real network lookup for the QR code.
                    wifiEnabled: false,
                    bluetooth: bluetooth,
                    bluetoothEnabled: bluetoothOn,
                    onTurnOnBluetooth: onTurnOnBluetooth,
                  ),
                ),
                child: const Text('share'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('share'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('closes when the other phone scans the QR code', (
      tester,
    ) async {
      await open(tester);
      expect(find.text('Invite to «Lisbon»'), findsOneWidget);
      // No Bluetooth in this build: no nearby card.
      expect(find.text('Visible to nearby phones'), findsNothing);

      // A pairing for another group leaves it open.
      await tester.runAsync(() => pair('phone-3', 'Galaxy', 'other', 'lan'));
      await tester.pump();
      expect(find.byType(InviteSheet), findsOneWidget);

      await tester.runAsync(() => pair('phone-2', 'Pixel 9', 'g1', 'lan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(InviteSheet), findsNothing);
      expect(find.text('Synced with Pixel 9'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('over Bluetooth, waits for the exchange before closing', (
      tester,
    ) async {
      final bt = _FakeBluetooth();
      await open(tester, bluetooth: bt);
      expect(bt.advertisedGroup, 'g1');
      expect(find.text('Visible to nearby phones'), findsOneWidget);

      await tester.runAsync(
        () => pair('phone-2', 'Pixel 9', 'g1', 'bluetooth'),
      );
      await tester.pump();
      expect(find.byType(InviteSheet), findsOneWidget);
      expect(find.text('Syncing with Pixel 9…'), findsOneWidget);

      bt.events$.add(BtSyncCompleted(result: _ok()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(InviteSheet), findsNothing);
      expect(find.text('Synced with Pixel 9'), findsOneWidget);
      expect(bt.stopped, isTrue);
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('says so when Bluetooth is not allowed', (tester) async {
      final bt = _FakeBluetooth()
        ..advertiseError = const BluetoothPermissionDeniedException();
      await open(tester, bluetooth: bt);
      final loc = AppLocalizations.of(tester.element(find.byType(InviteSheet)));
      expect(find.text(loc.sync_bt_permission_denied), findsOneWidget);
      expect(find.text(loc.sync_invite_qr_off), findsOneWidget);
    });

    testWidgets('with the Bluetooth switch off, stays invisible until '
        'turned on', (tester) async {
      var turnedOn = false;
      final bt = _FakeBluetooth();
      await open(
        tester,
        bluetooth: bt,
        bluetoothOn: false,
        onTurnOnBluetooth: () async => turnedOn = true,
      );
      final loc = AppLocalizations.of(tester.element(find.byType(InviteSheet)));
      expect(bt.advertisedGroup, isNull);
      expect(find.text(loc.sync_bt_off_title), findsOneWidget);
      expect(find.text(loc.sync_invite_nearby_title), findsNothing);

      await tester.tap(find.text(loc.sync_join_turn_on));
      await tester.pump();
      await tester.pump();
      expect(turnedOn, isTrue);
      expect(bt.advertisedGroup, 'g1');
      expect(find.text(loc.sync_invite_nearby_title), findsOneWidget);
    });
  });

  group('JoinGroupPage', () {
    Future<void> open(
      WidgetTester tester,
      _FakeBluetooth bt, {
      bool wifi = true,
      Future<void> Function()? onTurnOnWifi,
      bool bluetoothOn = true,
      Future<void> Function()? onTurnOnBluetooth,
    }) async {
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<bool>(
                    builder: (_) => JoinGroupPage(
                      orchestrator: orchestrator,
                      wifiEnabled: wifi,
                      onTurnOnWifi: onTurnOnWifi,
                      bluetooth: bt,
                      bluetoothEnabled: bluetoothOn,
                      onTurnOnBluetooth: onTurnOnBluetooth,
                    ),
                  ),
                ),
                child: const Text('join'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('join'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await settleDb(tester);
    }

    testWidgets('joins a nearby phone over Bluetooth', (tester) async {
      final bt = _FakeBluetooth();
      await open(tester, bt);
      expect(find.text('Or a nearby phone'), findsOneWidget);

      bt.events$.add(
        const PeerFound(
          name: 'Pixel 9',
          endpointId: 'e1',
          groupTitle: 'Lisbon',
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Pixel 9'), findsOneWidget);
      expect(find.text('Invite to «Lisbon»'), findsOneWidget);

      await tester.tap(find.text('Join'));
      await tester.pump();
      expect(bt.synced, ['e1']);

      bt.exchange!.complete(_ok());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(JoinGroupPage), findsNothing);
      expect(find.text('Synced with Pixel 9'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('a paired phone is updated, and a failure is explained', (
      tester,
    ) async {
      await tester.runAsync(() => pair('phone-2', 'Pixel 9', 'g1', 'lan'));
      final bt = _FakeBluetooth();
      await open(tester, bt);
      await settleDb(tester);

      bt.events$.add(const PeerFound(name: 'Pixel 9', endpointId: 'e1'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Already paired · updates the groups'), findsOneWidget);

      await tester.tap(find.text('Update'));
      await tester.pump();
      bt.exchange!.completeError(StateError('lost'));
      await tester.pump();

      final loc = AppLocalizations.of(
        tester.element(find.byType(JoinGroupPage)),
      );
      expect(find.byType(JoinGroupPage), findsOneWidget);
      expect(find.text(loc.sync_bt_error_detail), findsOneWidget);
    });

    testWidgets('with Wi-Fi sync off, offers to turn it on for the QR code', (
      tester,
    ) async {
      var turnedOn = false;
      final bt = _FakeBluetooth();
      await open(
        tester,
        bt,
        wifi: false,
        onTurnOnWifi: () async => turnedOn = true,
      );
      final loc = AppLocalizations.of(
        tester.element(find.byType(JoinGroupPage)),
      );
      expect(find.text(loc.sync_join_qr_off), findsOneWidget);

      await tester.tap(find.text(loc.sync_join_turn_on));
      await tester.pump();
      expect(turnedOn, isTrue);
      expect(find.text(loc.sync_join_qr_off), findsNothing);
      expect(find.text(loc.sync_join_scan_hint), findsOneWidget);
    });

    testWidgets('with the Bluetooth switch off, does not search until '
        'turned on', (tester) async {
      var turnedOn = false;
      final bt = _FakeBluetooth();
      await open(
        tester,
        bt,
        bluetoothOn: false,
        onTurnOnBluetooth: () async => turnedOn = true,
      );
      final loc = AppLocalizations.of(
        tester.element(find.byType(JoinGroupPage)),
      );
      expect(bt.discovering, isFalse);
      expect(find.text(loc.sync_bt_off_title), findsOneWidget);
      expect(find.text(loc.sync_join_searching), findsNothing);

      await tester.tap(find.text(loc.sync_join_turn_on));
      await tester.pump();
      await tester.pump();
      expect(turnedOn, isTrue);
      expect(bt.discovering, isTrue);
      expect(find.text(loc.sync_bt_off_title), findsNothing);
      expect(find.text(loc.sync_join_searching), findsOneWidget);
    });
  });
}
