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
import 'helpers/test_database.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _dir = Directory.systemTemp
      .createTempSync('group_page_opens_at_once')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir;
  @override
  Future<String?> getTemporaryPath() async => _dir;
}

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _food = ExpenseCategory(id: 'f', name: 'Food');

final _group = ExpenseGroup(
  id: 'opens-at-once',
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

/// Opening a group shows it from the first frame: no loading spinner while
/// the page reads the group again from storage (it showed as a dot in the
/// middle of the screen while the page slid in).
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

  testWidgets('the first frame is the group, not a spinner', (tester) async {
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

    // Before storage answers.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Weekend'), findsWidgets);
    expect(find.text('Dinner'), findsOneWidget);

    // Let the read from storage finish before the test ends.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Dinner'), findsOneWidget);
  });
}
