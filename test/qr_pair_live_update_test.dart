import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/sync/qr_pair_show_sheet.dart';
import 'package:io_caravella_egm/sync/widgets/paired_devices_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zentoast/zentoast.dart';

/// When the other phone scans the QR code, the sharing phone must notice
/// without being reopened: the QR sheet closes and the group's device list
/// shows the new device.
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late SqliteExpenseGroupRepository repository;
  late SyncOrchestrator orchestrator;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'qr_pair_live_${DateTime.now().microsecondsSinceEpoch}',
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

  test('a completed pairing is announced as PeerPaired', () async {
    final next = orchestrator.events.firstWhere((e) => e is PeerPaired);
    await orchestrator.handlePairingCompleted(
      'phone-2',
      'Pixel 9',
      'android',
      'g1',
    );
    final event = await next as PeerPaired;
    expect(event.deviceId, 'phone-2');
    expect(event.deviceName, 'Pixel 9');
    expect(event.groupId, 'g1');
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

    await tester.runAsync(
      () => orchestrator.handlePairingCompleted(
        'phone-2',
        'Pixel 9',
        'android',
        'g1',
      ),
    );
    await settleDb(tester);
    await settleDb(tester);

    expect(find.text('Pixel 9'), findsOneWidget);
  });

  testWidgets('the QR sheet closes when the other phone pairs', (tester) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => QrPairShowSheet(
                  orchestrator: orchestrator,
                  groupId: 'g1',
                  groupTitle: 'Lisbon',
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
    expect(find.byType(QrPairShowSheet), findsOneWidget);

    // A pairing for another group leaves it open.
    await tester.runAsync(
      () => orchestrator.handlePairingCompleted(
        'phone-3',
        'Galaxy',
        'android',
        'other',
      ),
    );
    await tester.pump();
    expect(find.byType(QrPairShowSheet), findsOneWidget);

    await tester.runAsync(
      () => orchestrator.handlePairingCompleted(
        'phone-2',
        'Pixel 9',
        'android',
        'g1',
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(QrPairShowSheet), findsNothing);
    expect(find.text('Paired with Pixel 9'), findsOneWidget);

    // Let the toast time out.
    await tester.pump(const Duration(seconds: 10));
  });
}
