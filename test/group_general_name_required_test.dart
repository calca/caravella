import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zentoast/zentoast.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';
import 'package:io_caravella_egm/manager/group/pages/expense_group_general_page.dart';
import 'package:caravella_core/caravella_core.dart';
import 'helpers/test_database.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _dir = Directory.systemTemp
      .createTempSync('group_name_required')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir;
  @override
  Future<String?> getTemporaryPath() async => _dir;
}

final _group = ExpenseGroup(
  id: 'g1',
  title: 'Norway Road Trip',
  participants: [ExpenseParticipant(id: 'a', name: 'Anna')],
  categories: [ExpenseCategory(id: 'f', name: 'Food')],
  currency: '€',
  expenses: const [],
);

/// Group → General: the name can't be emptied and saved by going back.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PreferencesService.reset();
    await PreferencesService.initialize();
    ExpenseGroupRepositoryFactory.reset();
    useTestDatabase();
    await ExpenseGroupStorageV2.addExpenseGroup(_group);
  });

  Future<void> open(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ExpenseGroupNotifier(),
        child: ToastProvider.create(
          child: MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: gen.AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            builder: (context, child) => Stack(
              children: [
                ?child,
                const ToastViewer(alignment: Alignment.bottomCenter),
              ],
            ),
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ExpenseGroupGeneralPage(
                      trip: _group,
                      mode: GroupEditMode.edit,
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('back with an empty name stays on the page and saves nothing', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).first, '  ');
    await tester.pump();

    await tester.runAsync(() => tester.binding.handlePopRoute());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ExpenseGroupGeneralPage), findsOneWidget);
    expect(find.text('The group needs a name'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.focusNode?.hasFocus, isTrue);

    final stored = await tester.runAsync(
      () => ExpenseGroupStorageV2.getTripById('g1'),
    );
    expect(stored?.title, 'Norway Road Trip');
  });

  testWidgets('back with a new name saves it and leaves', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).first, 'Fjords');
    await tester.pump();

    await tester.runAsync(() => tester.binding.handlePopRoute());
    // The save runs on the real database: wait for the page to leave
    // instead of a fixed delay, which a slow CI machine sometimes outran.
    for (var i = 0; i < 50; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      if (find.byType(ExpenseGroupGeneralPage).evaluate().isEmpty) break;
    }

    expect(find.byType(ExpenseGroupGeneralPage), findsNothing);
    final stored = await tester.runAsync(
      () => ExpenseGroupStorageV2.getTripById('g1'),
    );
    expect(stored?.title, 'Fjords');
  });
}
