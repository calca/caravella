import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/home_cards_header.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/settings/whats_new_status.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// After an update the app said nothing: the news was only in Settings ›
/// Info › What's new. Now the first start on a new release announces it
/// once, and a dot stays on the settings button until the news is opened.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PreferencesService.reset();
    await PreferencesService.initialize();
    WhatsNewStatus.unread.value = false;
  });

  test('a fresh install has nothing new to announce', () async {
    expect(
      await WhatsNewStatus.check(hasData: false, version: '2.5.0'),
      isNull,
    );
    expect(WhatsNewStatus.unread.value, isFalse);
    // Its first groups don't make it news either.
    expect(await WhatsNewStatus.check(hasData: true, version: '2.5.0'), isNull);
    expect(WhatsNewStatus.unread.value, isFalse);
  });

  test('an update: announced once, a dot until opened', () async {
    // Updated from 2.4 (which kept no record) with groups in the app.
    expect(await WhatsNewStatus.check(hasData: true, version: '2.5.0'), '2.5');
    expect(WhatsNewStatus.unread.value, isTrue);
    // The next start: no second toast, the dot stays.
    expect(await WhatsNewStatus.check(hasData: true, version: '2.5.0'), isNull);
    expect(WhatsNewStatus.unread.value, isTrue);

    await WhatsNewStatus.markSeen(version: '2.5.0');
    expect(WhatsNewStatus.unread.value, isFalse);
    expect(await WhatsNewStatus.check(hasData: true, version: '2.5.0'), isNull);
    expect(WhatsNewStatus.unread.value, isFalse);
  });

  test('a patch brings nothing; the next release does', () async {
    await WhatsNewStatus.markSeen(version: '2.5.0');
    expect(await WhatsNewStatus.check(hasData: true, version: '2.5.1'), isNull);
    expect(WhatsNewStatus.unread.value, isFalse);
    expect(await WhatsNewStatus.check(hasData: true, version: '2.6.0'), '2.6');
    expect(WhatsNewStatus.unread.value, isTrue);
  });

  test('the release of a version', () {
    expect(WhatsNewStatus.releaseOf('2.5.0'), '2.5');
    expect(WhatsNewStatus.releaseOf('2.5.1+135'), '2.5');
    expect(WhatsNewStatus.releaseOf('3'), '3');
  });

  testWidgets('the settings button carries a dot while there is news', (
    tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserNameNotifier()),
          Provider<SyncOrchestrator?>.value(value: null),
        ],
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          theme: CaravellaThemes.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: HomeCardsHeader(
                localizations: AppLocalizations.of(context),
                theme: Theme.of(context),
              ),
            ),
          ),
        ),
      ),
    );
    Badge badge() => tester.widget<Badge>(find.byType(Badge));
    expect(badge().isLabelVisible, isFalse);
    expect(find.byTooltip('Settings'), findsOneWidget);

    WhatsNewStatus.unread.value = true;
    await tester.pump();
    expect(badge().isLabelVisible, isTrue);
    expect(find.byTooltip('Settings, new features to see'), findsOneWidget);
  });
}
