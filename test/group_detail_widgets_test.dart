import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/widgets/day_grouped_expense_list.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_balances_view.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_map_card.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_statistics_view.dart';
import 'package:material_ui/material_ui.dart';

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _luca = ExpenseParticipant(id: 'l', name: 'Luca');
final _food = ExpenseCategory(id: 'f', name: 'Food');

ExpenseDetails _expense(
  String name,
  double amount,
  DateTime date,
  ExpenseParticipant by, {
  ExpenseLocation? location,
}) => ExpenseDetails(
  name: name,
  amount: amount,
  date: date,
  paidBy: by,
  category: _food,
  location: location,
);

ExpenseGroup _group(List<ExpenseDetails> expenses) => ExpenseGroup(
  title: 'Rome',
  expenses: expenses,
  participants: [_anna, _luca],
  categories: [_food],
  currency: '€',
);

Widget _wrap(Widget child, {bool sliver = false}) => MaterialApp(
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(
    body: sliver
        ? CustomScrollView(slivers: [child])
        : SingleChildScrollView(child: child),
  ),
);

void main() {
  final day1 = DateTime(2026, 10, 16, 9);
  final day2 = DateTime(2026, 10, 17, 20);

  test('groupByDay groups by calendar day, newest first', () {
    final days = DayGroupedExpenseSliver.groupByDay([
      _expense('Breakfast', 10, day1, _anna),
      _expense('Dinner', 40, day2, _luca),
      _expense('Lunch', 20, day1.add(const Duration(hours: 4)), _luca),
    ]);
    expect(days.map((d) => d.$1.day), [17, 16]);
    expect(days.last.$2.map((e) => e.name), ['Lunch', 'Breakfast']);
  });

  testWidgets('day sections show the day total', (tester) async {
    await tester.pumpWidget(
      _wrap(
        DayGroupedExpenseSliver(
          expenses: [
            _expense('Breakfast', 10, day1, _anna),
            _expense('Lunch', 20, day1.add(const Duration(hours: 4)), _luca),
          ],
          currency: '€',
          onExpenseTap: (_) {},
        ),
        sliver: true,
      ),
    );
    expect(find.text('FRI 16 OCT'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
  });

  testWidgets('balances show who gets back, who owes and how to settle', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        GroupBalancesView(group: _group([_expense('Hotel', 100, day1, _anna)])),
      ),
    );
    expect(find.bySemanticsLabel('Anna gets back 50.00 €'), findsOneWidget);
    expect(find.bySemanticsLabel('Luca owes 50.00 €'), findsOneWidget);
    expect(find.bySemanticsLabel('Luca pays Anna 50.00 €'), findsOneWidget);
  });

  testWidgets('balances say when everyone is even', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GroupBalancesView(
          group: _group([
            _expense('Hotel', 50, day1, _anna),
            _expense('Dinner', 50, day2, _luca),
          ]),
        ),
      ),
    );
    expect(find.text('All settled up'), findsOneWidget);
  });

  test('payer avatars grow with what they paid', () {
    expect(
      GroupPayersBubbles.sizeFor(100, 100),
      greaterThan(GroupPayersBubbles.sizeFor(25, 100)),
    );
    expect(
      GroupPayersBubbles.sizeFor(0, 100),
      GroupPayersBubbles.sizeFor(0, 0),
    );
  });

  test('places are counted once per spot', () {
    ExpenseLocation at(double lat, double lon) =>
        ExpenseLocation(latitude: lat, longitude: lon);
    final group = _group([
      _expense('A', 1, day1, _anna, location: at(45.0001, 9.0001)),
      _expense('B', 1, day1, _anna, location: at(45.0002, 9.0002)),
      _expense('C', 1, day1, _anna, location: at(46, 10)),
      _expense('D', 1, day1, _anna),
    ]);
    expect(groupPlacesCount(group), 2);
    expect(groupPlacesCount(_group([])), 0);
  });

  test('highest expense and most expensive day', () {
    final group = _group([
      _expense('Breakfast', 10, day1, _anna),
      _expense('Lunch', 30, day1.add(const Duration(hours: 4)), _luca),
      _expense('Dinner', 35, day2, _luca),
    ]);
    expect(highestExpense(group)?.name, 'Dinner');
    final (day, total) = mostExpensiveDay(group)!;
    expect(day, DateTime(2026, 10, 16));
    expect(total, 40);
    expect(highestExpense(_group([])), isNull);
    expect(mostExpensiveDay(_group([])), isNull);
  });
}
