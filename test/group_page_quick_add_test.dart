import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/pages/expense_group_detail_page.dart';
import 'package:io_caravella_egm/manager/details/widgets/expense_entry_sheet.dart';
import 'package:io_caravella_egm/manager/expense/pages/expense_form_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/test_database.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _dir = Directory.systemTemp
      .createTempSync('group_page_quick_add')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir;
  @override
  Future<String?> getTemporaryPath() async => _dir;
}

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _food = ExpenseCategory(id: 'f', name: 'Food');

final _group = ExpenseGroup(
  id: 'quick-add-group',
  title: 'Weekend',
  participants: [_anna],
  categories: [_food],
  currency: '€',
  expenses: const [],
);

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

  testWidgets('group page add opens the Home quick-add sheet and saves', (
    tester,
  ) async {
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

    // The empty state's own add button (same callback as the FAB).
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(ExpenseEntrySheet), findsOneWidget);
    expect(find.byType(ExpenseFormPage), findsNothing);

    await tester.enterText(find.byType(EditableText).first, '12');
    await tester.enterText(find.byType(EditableText).at(1), 'Pizza');
    await tester.tap(find.text('Anna').last);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Food').last);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byType(FilledButton).last);
    // Storage is real I/O: alternate real waits with pumps until it closes.
    for (var i = 0; i < 50; i++) {
      if (find.byType(ExpenseEntrySheet).evaluate().isEmpty) break;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    final saved = await tester.runAsync(
      () => ExpenseGroupStorageV2.getTripById(_group.id),
    );
    expect(saved!.expenses, hasLength(1));
    expect(saved.expenses.single.amount, 12);
    expect(find.byType(ExpenseEntrySheet), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });
}
