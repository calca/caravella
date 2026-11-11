import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/pages/expense_group_detail_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _dir = Directory.systemTemp
      .createTempSync('group_page_fab_sections')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir;
  @override
  Future<String?> getTemporaryPath() async => _dir;
}

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _food = ExpenseCategory(id: 'f', name: 'Food');

final _group = ExpenseGroup(
  id: 'fab-sections-group',
  title: 'Weekend',
  participants: [_anna],
  categories: [_food],
  currency: '€',
  expenses: [
    ExpenseDetails(
      id: 'e1',
      name: 'Dinner',
      amount: 20,
      paidBy: _anna,
      category: _food,
      date: DateTime(2026, 11, 1),
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    PreferencesService.reset();
    await PreferencesService.initialize();
    ExpenseGroupRepositoryFactory.reset();
    ExpenseGroupRepositoryFactory.getRepository(useJsonBackend: true);
    ExpenseGroupStorageV2.clearCache();
    await ExpenseGroupStorageV2.addExpenseGroup(_group);
  });

  testWidgets('the add button is only on Expenses', (tester) async {
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

    bool fabShown() {
      final fab = find.byType(AddFab);
      final ignore = tester.widget<IgnorePointer>(
        find.ancestor(of: fab, matching: find.byType(IgnorePointer)).first,
      );
      final opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(of: fab, matching: find.byType(AnimatedOpacity)).first,
      );
      return !ignore.ignoring && opacity.opacity == 1;
    }

    expect(fabShown(), isTrue);

    for (final (tab, shown) in [
      ('Balances', false),
      ('Statistics', false),
      ('Expenses', true),
    ]) {
      await tester.tap(find.text(tab).first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(fabShown(), shown, reason: tab);
    }
  });
}
