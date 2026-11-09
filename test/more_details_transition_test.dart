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

class _FakePathProvider extends PathProviderPlatform {
  late final String _dir = Directory.systemTemp
      .createTempSync('more_details_transition')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir;
  @override
  Future<String?> getTemporaryPath() async => _dir;
}

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _food = ExpenseCategory(id: 'f', name: 'Food');

final _group = ExpenseGroup(
  id: 'more-details-group',
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
    ExpenseGroupRepositoryFactory.getRepository(useJsonBackend: true);
    ExpenseGroupStorageV2.clearCache();
    await ExpenseGroupStorageV2.addExpenseGroup(_group);
  });

  testWidgets(
    'More details: the page rises over the sheet, which is then dropped, '
    'with the typed values and no keyboard grab',
    (tester) async {
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

      await tester.tap(find.byType(FilledButton).first);
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.byType(ExpenseEntrySheet), findsOneWidget);

      await tester.enterText(find.byType(EditableText).at(1), 'Pizza');
      await tester.pump();

      final pill = tester.widget<FormPill>(
        find.widgetWithText(FormPill, 'More details'),
      );
      pill.onTap!();
      await tester.pump();
      // Mid-way the page is sliding up over the sheet, still there below.
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(ExpenseFormPage), findsOneWidget);
      expect(
        find.byType(ExpenseEntrySheet, skipOffstage: false),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 600));
      // Settled: the sheet is gone and the page has the typed name.
      expect(find.byType(ExpenseEntrySheet, skipOffstage: false), findsNothing);
      expect(find.byType(ExpenseFormPage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ExpenseFormPage),
          matching: find.text('Pizza'),
        ),
        findsOneWidget,
      );
      // The keyboard went down once and stays down.
      expect(tester.testTextInput.isVisible, isFalse);

      await tester.pump(const Duration(seconds: 1));
    },
  );
}
