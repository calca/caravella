import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/search/group_search_page.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('group_search_expenses_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _stay = ExpenseCategory(id: 's', name: 'Stay');

ExpenseDetails _expense(String name, DateTime date, {String? note}) =>
    ExpenseDetails(
      name: name,
      amount: 100,
      date: date,
      paidBy: _anna,
      category: _stay,
      note: note,
    );

Widget _app() => MaterialApp(
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: ChangeNotifierProvider(
    create: (_) => ExpenseGroupNotifier(),
    child: const GroupSearchPage(),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  setUpAll(() async {
    ExpenseGroupRepositoryFactory.reset();
    ExpenseGroupRepositoryFactory.getRepository(useJsonBackend: true);
    ExpenseGroupStorageV2.clearCache();
    await ExpenseGroupStorageV2.addExpenseGroup(
      ExpenseGroup(
        id: 'chicago',
        title: 'Chicago Conference',
        participants: [_anna],
        categories: [_stay],
        currency: '€',
        expenses: [
          _expense('Hotel 3 nights', DateTime(2026, 9, 27)),
          _expense('Airport taxi', DateTime(2026, 9, 27)),
        ],
      ),
    );
    await ExpenseGroupStorageV2.addExpenseGroup(
      ExpenseGroup(
        id: 'bruges',
        title: 'Weekend in Bruges',
        participants: [_anna],
        categories: [_stay],
        currency: '€',
        archived: true,
        expenses: [
          _expense('Room', DateTime(2026, 10, 9), note: 'Hotel near the canal'),
        ],
      ),
    );
  });

  Future<void> search(WidgetTester tester, String query) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    await tester.enterText(find.byType(TextField), query);
    await tester.pump();
  }

  testWidgets('finds expenses of every group by name or note, newest first', (
    tester,
  ) async {
    await search(tester, 'hotel');

    expect(find.text('EXPENSES · 2'), findsOneWidget);
    // Matched by its note, in an archived group.
    expect(find.text('Room'), findsOneWidget);
    expect(find.textContaining('Weekend in Bruges'), findsOneWidget);
    expect(find.textContaining('Archived'), findsWidgets);
    // Matched by its name; the group title doesn't match, so no group row.
    expect(find.textContaining('Chicago Conference'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Room')).dy,
      lessThan(tester.getTopLeft(find.textContaining('Hotel 3')).dy),
    );
  });

  testWidgets('no match anywhere: the empty state', (tester) async {
    await search(tester, 'zzz');
    expect(find.textContaining('No results'), findsOneWidget);
  });
}
