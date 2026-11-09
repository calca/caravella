import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/sync/multi_user_sync_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zentoast/zentoast.dart';

/// Tests run with [NoGmsIntegrations], like the F-Droid build: no Bluetooth
/// sync, so Sync with others must not talk about Bluetooth.
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('without Bluetooth sync, Sync with others only names Wi-Fi', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final tempDir = Directory.systemTemp.createTempSync('wifi_only_texts');
    final repository = SqliteExpenseGroupRepository(
      databasePath: '${tempDir.path}/repo.db',
    );
    late SyncOrchestrator orchestrator;
    await tester.runAsync(() async {
      await repository.getAllGroups();
      orchestrator = SyncOrchestrator(
        lanChannel: LanSyncChannel(),
        syncManager: SyncManager(repository: repository),
      );
      await orchestrator.initialize();
    });
    addTearDown(() async {
      await repository.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    await tester.pumpWidget(
      ToastProvider.create(
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
          home: MultiUserSyncPage(orchestrator: orchestrator),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Groups over Wi-Fi'), findsOneWidget);
    expect(find.textContaining('With it off'), findsOneWidget);
    expect(find.textContaining('Bluetooth'), findsNothing);
  });
}
