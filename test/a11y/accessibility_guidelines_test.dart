import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/home_page.dart';
import 'package:io_caravella_egm/home/search/group_search_page.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/pages/expense_group_detail_page.dart';
import 'package:io_caravella_egm/manager/details/pages/group_settings_page.dart';
import 'package:io_caravella_egm/manager/expense/pages/expense_form_page.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';
import 'package:io_caravella_egm/manager/group/pages/expense_group_categories_page.dart';
import 'package:io_caravella_egm/manager/group/pages/expense_group_general_page.dart';
import 'package:io_caravella_egm/manager/group/pages/expense_group_participants_page.dart';
import 'package:io_caravella_egm/manager/group/pages/group_creation_wizard_page.dart';
import 'package:io_caravella_egm/manager/history/expenses_history_page.dart';
import 'package:io_caravella_egm/settings/pages/appearance_settings_page.dart';
import 'package:io_caravella_egm/settings/pages/settings_page.dart';
import 'package:io_caravella_egm/settings/state/group_type_templates_notifier.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Flutter's accessibility guidelines on the app's main screens, in the
/// light and dark theme and at 200% text: touch targets of at least 48 dp,
/// a label on every tappable element, text contrast as drawn.
class _FakePathProvider extends PathProviderPlatform {
  late final String _dir = Directory.systemTemp
      .createTempSync('a11y_guidelines')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir;
  @override
  Future<String?> getTemporaryPath() async => _dir;
}

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _luca = ExpenseParticipant(id: 'l', name: 'Luca');
final _food = ExpenseCategory(id: 'f', name: 'Food');
final _stay = ExpenseCategory(id: 's', name: 'Accommodation');

final _group = ExpenseGroup(
  id: 'norway',
  title: 'Norway Road Trip',
  participants: [_anna, _luca],
  categories: [_food, _stay],
  currency: '€',
  startDate: DateTime(2026, 10, 16),
  endDate: DateTime(2026, 10, 25),
  expenses: [
    ExpenseDetails(
      name: 'Fish soup',
      amount: 54.5,
      date: DateTime(2026, 10, 22),
      paidBy: _anna,
      category: _food,
    ),
    ExpenseDetails(
      name: 'Cabin by the fjord',
      amount: 312,
      date: DateTime(2026, 10, 21),
      paidBy: _luca,
      category: _stay,
    ),
  ],
);

Widget _app(Widget home, {required bool dark, required double textScale}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
        ChangeNotifierProvider(create: (_) => UserNameNotifier()),
        ChangeNotifierProvider(create: (_) => GroupTypeTemplatesNotifier()),
      ],
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        theme: CaravellaThemes.light,
        darkTheme: CaravellaThemes.dark,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: home,
      ),
    );

/// The screens under test; [open] can tap into a section after pumping.
final _screens =
    <String, (Widget Function(), Future<void> Function(WidgetTester)?)>{
      'group page · expenses': (
        () => ExpenseGroupDetailPage(trip: _group),
        null,
      ),
      'group page · balances': (
        () => ExpenseGroupDetailPage(trip: _group),
        (t) => t.tap(find.text('Balances')),
      ),
      'group page · statistics': (
        () => ExpenseGroupDetailPage(trip: _group),
        (t) => t.tap(find.text('Statistics')),
      ),
      'groups page': (() => const ExpesensHistoryPage(), null),
      'group search': (() => const GroupSearchPage(), null),
      'expense form (edit)': (
        () => ExpenseFormPage(
          group: _group,
          initialExpense: _group.expenses.first,
          onExpenseSaved: (_) {},
          onCategoryAdded: (_) {},
        ),
        null,
      ),
      'group creation': (() => const GroupCreationWizardPage(), null),
      'settings': (() => const SettingsPage(), null),
      'appearance': (() => const AppearanceSettingsPage(), null),
      'home': (() => const HomePage(), null),
      'expense form (new)': (
        () => ExpenseFormPage(
          group: _group,
          onExpenseSaved: (_) {},
          onCategoryAdded: (_) {},
        ),
        null,
      ),
      'group settings': (() => GroupSettingsPage(trip: _group), null),
      'group · general': (
        () => ExpenseGroupGeneralPage(trip: _group, mode: GroupEditMode.edit),
        null,
      ),
      'group · participants': (
        () => ExpenseGroupParticipantsPage(
          trip: _group,
          mode: GroupEditMode.edit,
        ),
        null,
      ),
      'group · categories': (
        () =>
            ExpenseGroupCategoriesPage(trip: _group, mode: GroupEditMode.edit),
        null,
      ),
    };

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

  for (final (variant, dark, scale) in [
    ('light', false, 1.0),
    ('dark', true, 1.0),
    ('200% text', false, 2.0),
  ]) {
    for (final MapEntry(key: name, value: (build, open)) in _screens.entries) {
      testWidgets('$name · $variant', (tester) async {
        final handle = tester.ensureSemantics();
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);

        await tester.runAsync(() async {
          await tester.pumpWidget(_app(build(), dark: dark, textScale: scale));
          await Future<void>.delayed(const Duration(milliseconds: 300));
        });
        await tester.pump(const Duration(milliseconds: 500));
        if (open != null) {
          await open(tester);
          await tester.pump(const Duration(milliseconds: 600));
        }

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  }
}
