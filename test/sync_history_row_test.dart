import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/sync/sync_history_page.dart';
import 'package:io_caravella_egm/sync/sync_settings_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// The "Sync history" row is greyed out until there's something in it.
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late SqliteExpenseGroupRepository repository;
  late SyncOrchestrator orchestrator;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'sync_history_row_${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = SqliteExpenseGroupRepository(
      databasePath: '${tempDir.path}/repo.db',
    );
    await repository.getAllGroups();
    orchestrator = SyncOrchestrator(
      lanChannel: LanSyncChannel(),
      syncManager: SyncManager(repository: repository),
    );
    await orchestrator.initialize();
  });

  tearDown(() async {
    await repository.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  testWidgets('no history yet: the row says so and opens nothing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: SyncSettingsScreen(orchestrator: orchestrator),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();

    final loc = AppLocalizations.of(
      tester.element(find.byType(SyncSettingsScreen)),
    );
    expect(find.text(loc.sync_history_empty), findsOneWidget);

    await tester.tap(find.text(loc.sync_history_title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SyncHistoryPage), findsNothing);
  });
}
