import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/settings/widgets/info_settings_section.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _FakeStore implements StoreReviewClient {
  int opened = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> requestReview() async {}

  @override
  Future<void> openStoreListing() async => opened++;
}

class _PlayIntegrations extends NoGmsIntegrations {
  final StoreReviewClient store;
  const _PlayIntegrations(this.store);

  @override
  StoreReviewClient? get storeReview => store;
}

/// Settings → the "Caravella" and "Open source project" sections (#617).
void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Caravella',
      packageName: 'io.caravella.egm',
      version: '2.3.0',
      buildNumber: '128',
      buildSignature: '',
    );
  });
  tearDown(() => GmsIntegrations.instance = const NoGmsIntegrations());

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(
          body: SingleChildScrollView(child: InfoSettingsSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the rows, the version and the footer', (tester) async {
    await pump(tester);
    expect(find.text('CARAVELLA'), findsOneWidget);
    expect(find.text('OPEN SOURCE PROJECT'), findsOneWidget);
    expect(find.text('Invite your friends'), findsOneWidget);
    expect(find.text('What’s new in version 2.3.0'), findsOneWidget);
    expect(find.text('Buy me a coffee'), findsOneWidget);
    expect(find.text('Source code'), findsOneWidget);
    expect(find.text('Report a problem'), findsOneWidget);
    expect(find.text('Caravella 2.3.0'), findsOneWidget);
    expect(find.text('Made by calca'), findsOneWidget);
    expect(find.text('License'), findsOneWidget);
  });

  testWidgets('the F-Droid build points to its F-Droid page', (tester) async {
    await pump(tester);
    expect(find.text('Caravella on F-Droid'), findsOneWidget);
    expect(find.text('Rate Caravella'), findsNothing);
  });

  testWidgets('the Play build opens its store listing', (tester) async {
    final store = _FakeStore();
    GmsIntegrations.instance = _PlayIntegrations(store);
    await pump(tester);
    expect(find.text('Caravella on F-Droid'), findsNothing);

    await tester.tap(find.text('Rate Caravella'));
    await tester.pump();
    expect(store.opened, 1);
  });
}
