import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/expense/location/location_service.dart';
import 'package:io_caravella_egm/manager/expense/location/repository/location_repository.dart';
import 'package:io_caravella_egm/manager/expense/pages/expense_form_page.dart';
import 'package:material_ui/material_ui.dart';

class _Geocoder implements LocationRepository {
  int calls = 0;

  @override
  Future<ExpenseLocation?> describe(double latitude, double longitude) async {
    calls++;
    return ExpenseLocation(
      latitude: latitude,
      longitude: longitude,
      locality: 'Milano',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// #607: an expense whose place is bare coordinates (saved before 2.3.0)
/// gets the place's name when it's opened, without counting as an edit.
void main() {
  final anna = ExpenseParticipant(id: 'p1', name: 'Anna');
  final food = ExpenseCategory(id: 'c1', name: 'Food');

  Future<gen.AppLocalizations> open(
    WidgetTester tester,
    ExpenseLocation location,
  ) async {
    final expense = ExpenseDetails(
      id: 'e1',
      name: 'Pizza',
      amount: 12.5,
      paidBy: anna,
      category: food,
      date: DateTime(2025, 6, 1),
      location: location,
    );
    final group = ExpenseGroup(
      id: 'g1',
      title: 'Trip',
      expenses: [expense],
      participants: [anna],
      categories: [food],
      currency: '€',
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          gen.AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExpenseFormPage(
                    group: group,
                    initialExpense: expense,
                    onExpenseSaved: (_) {},
                    onCategoryAdded: (_) {},
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return gen.AppLocalizations.of(
      tester.element(find.byType(ExpenseFormPage)),
    );
  }

  testWidgets('bare coordinates get their name, and it is not an edit', (
    tester,
  ) async {
    final geocoder = _Geocoder();
    LocationService.debugSetRepository(geocoder);

    final l10n = await open(
      tester,
      ExpenseLocation(latitude: 45.4642, longitude: 9.19),
    );
    expect(geocoder.calls, 1);
    expect(find.text('Milano'), findsOneWidget);
    expect(find.textContaining('45.4642'), findsNothing);

    await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pumpAndSettle();
    expect(find.text(l10n.discard_changes_title), findsNothing);
    expect(find.byType(ExpenseFormPage), findsNothing);
  });

  testWidgets('a place with a name is left alone', (tester) async {
    final geocoder = _Geocoder();
    LocationService.debugSetRepository(geocoder);

    await open(
      tester,
      ExpenseLocation(latitude: 45.4642, longitude: 9.19, name: 'Da Gino'),
    );
    expect(geocoder.calls, 0);
    expect(find.text('Da Gino'), findsOneWidget);
  });
}
