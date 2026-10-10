import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/sync/bluetooth_advertise_sheet.dart';
import 'package:io_caravella_egm/sync/bluetooth_sync_channel.dart';
import 'package:io_caravella_egm/sync/bluetooth_sync_sheet.dart';

/// Channel that never touches the platform: discovery/advertising just
/// "run" forever, so the sheets stay in their initial searching/waiting
/// phase (a spinner plus a short status text).
class _IdleBluetoothChannel extends BluetoothSyncChannel {
  final _events = StreamController<BluetoothPeerEvent>.broadcast();

  @override
  Stream<BluetoothPeerEvent> get events => _events.stream;

  @override
  Future<void> startDiscovery() async {}

  @override
  Future<void> startAdvertising({
    required String groupId,
    String groupTitle = '',
  }) async {}

  @override
  Future<void> stopAll() async {}
}

void main() {
  Future<void> pumpSheet(WidgetTester tester, Widget sheet) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          gen.AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: const [Locale('it'), Locale('en')],
        locale: const Locale('en'),
        home: Scaffold(
          body: Align(alignment: Alignment.bottomCenter, child: sheet),
        ),
      ),
    );
    // The spinner animates forever, so pumpAndSettle would time out.
    await tester.pump(const Duration(milliseconds: 300));
  }

  void expectSpinnerCentered(WidgetTester tester) {
    final screenCenterX = tester.getSize(find.byType(Scaffold)).width / 2;
    final spinnerCenterX = tester
        .getCenter(find.byType(CircularProgressIndicator))
        .dx;
    expect(spinnerCenterX, moreOrLessEquals(screenCenterX, epsilon: 1));
  }

  // The search sheet schedules a short delayed phase switch on open; let it
  // fire so no timer is left pending when the test ends.
  Future<void> drainTimers(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 5));

  testWidgets('Bluetooth sync (search) sheet centers its content', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      BluetoothSyncSheet(channel: _IdleBluetoothChannel()),
    );
    expectSpinnerCentered(tester);
    await drainTimers(tester);

    // After the delay it switches to the (still empty) peer list, whose
    // "searching" message must be centered too.
    await tester.pumpAndSettle(); // let the AnimatedSwitcher cross-fade end
    final l10n = gen.AppLocalizations.of(
      tester.element(find.byType(BluetoothSyncSheet)),
    );
    final screenCenterX = tester.getSize(find.byType(Scaffold)).width / 2;
    expect(
      tester.getCenter(find.text(l10n.sync_bt_searching)).dx,
      moreOrLessEquals(screenCenterX, epsilon: 1),
    );
  });

  testWidgets('Bluetooth advertise sheet centers its content', (tester) async {
    await pumpSheet(
      tester,
      BluetoothAdvertiseSheet(
        channel: _IdleBluetoothChannel(),
        groupId: 'g1',
        groupTitle: 'Trip',
      ),
    );
    expectSpinnerCentered(tester);
    await drainTimers(tester);
  });
}
