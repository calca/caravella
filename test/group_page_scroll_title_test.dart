import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/pages/expense_group_detail_page.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_detail_header.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_detail_top_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/test_database.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _dir = Directory.systemTemp
      .createTempSync('group_page_scroll_title')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir;
  @override
  Future<String?> getTemporaryPath() async => _dir;
}

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _food = ExpenseCategory(id: 'f', name: 'Food');

final _group = ExpenseGroup(
  id: 'scroll-title-group',
  title: 'Weekend',
  participants: [_anna],
  categories: [_food],
  currency: '€',
  expenses: [
    for (var i = 0; i < 30; i++)
      ExpenseDetails(
        id: 'e$i',
        name: 'Dinner $i',
        amount: 20,
        paidBy: _anna,
        category: _food,
        date: DateTime(2026, 11, 1 + i % 20),
      ),
  ],
);

/// The top bar shows the group's name only once the whole header band has
/// gone under it, and a scroll let go with the band half under the bar
/// settles to the nearest end, so the band's line never rests cut by it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    PreferencesService.reset();
    await PreferencesService.initialize();
    ExpenseGroupRepositoryFactory.reset();
    useTestDatabase();
    await ExpenseGroupStorageV2.addExpenseGroup(_group);
  });

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
          ],
          child: MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            theme: CaravellaThemes.light,
            home: ExpenseGroupDetailPage(trip: _group),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(milliseconds: 500));
  }

  ScrollPosition position(WidgetTester tester) =>
      tester.state<ScrollableState>(find.byType(Scrollable).first).position;

  double barTitleOpacity(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(
        find.ancestor(
          of: find.descendant(
            of: find.byType(GroupDetailTopBar),
            matching: find.text('Weekend'),
          ),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;

  testWidgets('let go with the band half under the bar: back to the top', (
    tester,
  ) async {
    await open(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -60));
    await tester.pumpAndSettle();
    expect(position(tester).pixels, 0);
    expect(barTitleOpacity(tester), 0);
  });

  testWidgets('past half: the band goes under, then the name shows', (
    tester,
  ) async {
    await open(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
    await tester.pump();
    // The band's line is still showing: no name in the bar yet.
    expect(barTitleOpacity(tester), 0);
    await tester.pumpAndSettle();
    final band = tester.getRect(find.byType(GroupHeaderBand));
    final bar = tester.getRect(find.byType(GroupDetailTopBar));
    expect(band.bottom - GroupHeaderBand.bottomGap, closeTo(bar.bottom, 1));
    expect(barTitleOpacity(tester), 1);
  });

  testWidgets('scrolled well past the band: it stays where it was left', (
    tester,
  ) async {
    await open(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();
    final offset = position(tester).pixels;
    expect(offset, greaterThan(500));
    expect(barTitleOpacity(tester), 1);
  });
}
