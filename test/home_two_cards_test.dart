import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/group_card.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Home shows the featured group as two cards: the group (total, today,
/// spending wave) and the last three expenses with "See all".
void main() {
  final anna = ExpenseParticipant(name: 'Anna');
  final food = ExpenseCategory(name: 'Food');
  final today = DateTime.now();

  ExpenseDetails expense(String name, int daysAgo, double amount) =>
      ExpenseDetails(
        name: name,
        amount: amount,
        paidBy: anna,
        category: food,
        date: today.subtract(Duration(days: daysAgo)),
      );

  ExpenseGroup groupWith(List<ExpenseDetails> expenses) => ExpenseGroup(
    title: 'Norway',
    expenses: expenses,
    participants: [anna],
    categories: [food],
    currency: '€',
  );

  Future<List<Route<dynamic>>> pump(
    WidgetTester tester,
    ExpenseGroup group,
  ) async {
    final pushed = <Route<dynamic>>[];
    await tester.binding.setSurfaceSize(const Size(412, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ExpenseGroupNotifier(),
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          navigatorObservers: [_PushObserver(pushed)],
          home: Builder(
            builder: (context) => Scaffold(
              body: SizedBox(
                height: 760,
                child: GroupCard(
                  group: group,
                  localizations: AppLocalizations.of(context),
                  theme: Theme.of(context),
                  onGroupUpdated: () {},
                  showAddButton: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return pushed;
  }

  testWidgets('second card: last three expenses, newest first, and See all', (
    tester,
  ) async {
    final pushed = await pump(
      tester,
      groupWith([
        expense('Oldest', 4, 10),
        expense('Ferry', 2, 86),
        expense('Cabin', 1, 312),
        expense('Soup', 0, 54.5),
      ]),
    );

    expect(find.text('RECENT EXPENSES'), findsOneWidget);
    expect(find.text('Soup'), findsOneWidget);
    expect(find.text('Cabin'), findsOneWidget);
    expect(find.text('Ferry'), findsOneWidget);
    expect(find.text('Oldest'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Soup')).dy,
      lessThan(tester.getTopLeft(find.text('Ferry')).dy),
    );

    final routesBefore = pushed.length;
    await tester.tap(find.text('See all'));
    await tester.pump();
    expect(pushed.length, routesBefore + 1);
  });

  testWidgets('first card: the spending wave from the first day to today', (
    tester,
  ) async {
    await pump(
      tester,
      groupWith([expense('Ferry', 2, 86), expense('Soup', 0, 54.5)]),
    );
    expect(find.byType(SpendingWave), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('one day of spending: no wave', (tester) async {
    await pump(tester, groupWith([expense('Soup', 0, 54.5)]));
    expect(find.byType(SpendingWave), findsNothing);
    expect(find.text('See all'), findsOneWidget);
  });

  testWidgets('no expenses: the getting-started checklist, no See all', (
    tester,
  ) async {
    await pump(tester, groupWith([]));
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('See all'), findsNothing);
    expect(find.byType(SpendingWave), findsNothing);
  });
}

class _PushObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushed;
  _PushObserver(this.pushed);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      pushed.add(route);
}
