import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/settings/backup/drive_backup_service.dart';
import 'package:io_caravella_egm/settings/widgets/drive_backup_section.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeStore implements CloudBackupStore {
  _FakeStore({required this.linked});
  bool linked;

  @override
  String get providerName => 'Google Drive';
  @override
  String? get accountName => linked ? 'me@example.com' : null;
  @override
  Future<bool> restoreSession() async => linked;
  @override
  Future<bool> signIn() async => linked = true;
  @override
  Future<void> signOut() async => linked = false;
  @override
  Future<CloudBackupEntry> upload(
    String fileName,
    List<int> bytes, {
    int keep = 5,
  }) => throw UnimplementedError();
  @override
  Future<List<CloudBackupEntry>> list() async => const [];
  @override
  Future<List<int>> download(String id) => throw UnimplementedError();
}

/// Settings → Data, Google Drive section.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => DriveBackupService.debugSetStore(null));

  Future<gen.AppLocalizations> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          gen.AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
        home: const Scaffold(
          body: SingleChildScrollView(child: DriveBackupSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return gen.AppLocalizations.of(
      tester.element(find.byType(DriveBackupSection)),
    );
  }

  testWidgets('hidden in builds without cloud backup', (tester) async {
    DriveBackupService.debugSetStore(null);
    await pump(tester);
    expect(find.text('GOOGLE DRIVE'), findsNothing);
  });

  testWidgets('not linked: one row to connect, then the actions', (
    tester,
  ) async {
    DriveBackupService.debugSetStore(_FakeStore(linked: false));
    final l10n = await pump(tester);

    expect(find.text(l10n.drive_backup_connect), findsOneWidget);
    expect(find.text(l10n.drive_backup_now), findsNothing);

    await tester.tap(find.text(l10n.drive_backup_connect));
    await tester.pumpAndSettle();

    expect(find.text(l10n.drive_backup_now), findsOneWidget);
    expect(find.text(l10n.drive_backup_none), findsOneWidget);
    expect(find.text(l10n.drive_backup_restore), findsOneWidget);
    expect(find.text(l10n.drive_backup_weekly), findsOneWidget);
    expect(find.text('me@example.com'), findsOneWidget);
  });

  testWidgets('the weekly switch is saved', (tester) async {
    DriveBackupService.debugSetStore(_FakeStore(linked: true));
    final l10n = await pump(tester);

    await tester.tap(find.text(l10n.drive_backup_weekly));
    await tester.pumpAndSettle();

    expect(await DriveBackupService.isWeekly(), isTrue);
  });
}
