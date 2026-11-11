import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/budget/budget_detail_sheet.dart';
import 'package:io_caravella_egm/manager/budget/budget_settings_sheet.dart';
import 'package:io_caravella_egm/manager/details/pages/group_settings_page.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_detail_header.dart';
import 'helpers/test_database.dart';
import 'package:material_ui/material_ui.dart';

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _food = ExpenseCategory(id: 'f', name: 'Food');
final _today = DateTime(2026, 11, 11, 18);

ExpenseGroup _home({GroupBudget? budget, Map<DateTime, double>? expenses}) =>
    ExpenseGroup(
      title: 'Via Tortona',
      currency: '€',
      participants: [_anna],
      categories: [_food],
      budget: budget,
      expenses: [
        for (final e
            in (expenses ??
                    {
                      DateTime(2026, 9, 3): 642,
                      DateTime(2026, 10, 12): 560,
                      DateTime(2026, 11, 2): 205.9,
                      DateTime(2026, 11, 11, 9): 8.4,
                    })
                .entries)
          ExpenseDetails(
            name: 'x',
            amount: e.value,
            date: e.key,
            paidBy: _anna,
            category: _food,
          ),
      ],
    );

/// The amounts are [CurrencyDisplay]s, as everywhere in the app.
Finder _amount(double value) => find.byWidgetPredicate(
  (w) => w is CurrencyDisplay && (w.value - value).abs() < 1e-9,
);

const _monthly = GroupBudget(amount: 600, period: BudgetPeriod.monthly);

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('without a budget Today has no ring and does nothing', (
    tester,
  ) async {
    var opened = 0;
    await tester.pumpWidget(
      _wrap(
        GroupDetailHeader(
          group: _home(),
          foreground: Colors.black,
          today: _today,
          onOpenBudget: () => opened++,
        ),
      ),
    );
    expect(find.byType(BudgetRing), findsNothing);
    await tester.tap(find.text('Today'));
    expect(opened, 0);
  });

  testWidgets('with a budget Today has the ring and opens the budget', (
    tester,
  ) async {
    var opened = 0;
    await tester.pumpWidget(
      _wrap(
        GroupDetailHeader(
          group: _home(budget: _monthly),
          foreground: Colors.black,
          today: _today,
          onOpenBudget: () => opened++,
        ),
      ),
    );
    final ring = tester.widget<BudgetRing>(find.byType(BudgetRing));
    expect(ring.over, isFalse);
    // 394.10 left this morning over 20 days: 19.705 a day, 8.40 spent.
    expect(ring.fraction, closeTo(8.4 / 19.705, 1e-9));
    expect(
      find.bySemanticsLabel(
        'Today 8.40 €, within the 19.71 € planned for today. Open the budget',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byType(BudgetRing));
    expect(opened, 1);
  });

  testWidgets('over today: a full amber ring', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GroupDetailHeader(
          group: _home(
            budget: const GroupBudget(amount: 40, period: BudgetPeriod.daily),
            expenses: {DateTime(2026, 11, 11, 9): 52},
          ),
          foreground: Colors.black,
          today: _today,
          onOpenBudget: () {},
        ),
      ),
    );
    expect(tester.widget<BudgetRing>(find.byType(BudgetRing)).over, isTrue);
  });

  testWidgets('the detail sheet: today, the month and the months before', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        BudgetDetailSheet(
          group: _home(budget: _monthly),
          today: _today,
        ),
      ),
    );
    expect(_amount(11.305), findsOneWidget);
    expect(find.text('left today'), findsOneWidget);
    expect(find.text('8.40 € spent of 19.71 € planned'), findsOneWidget);
    expect(find.text('BUDGET · NOVEMBER'), findsOneWidget);
    expect(_amount(385.7), findsOneWidget);
    expect(find.text('left'), findsOneWidget);
    expect(find.text('today · day 11 of 30'), findsOneWidget);
    expect(find.text('THE MONTHS BEFORE'), findsOneWidget);
    // October within, September over (August has no expenses: not shown,
    // being before the first one).
    expect(find.text('October'), findsOneWidget);
    expect(_amount(560), findsOneWidget);
    expect(find.text('September'), findsOneWidget);
    expect(_amount(642), findsOneWidget);
    expect(find.text('42.00 € over'), findsOneWidget);
    expect(find.text('August'), findsNothing);
    expect(find.text('Change budget'), findsOneWidget);
  });

  testWidgets('a total budget has no comparison', (tester) async {
    await tester.pumpWidget(
      _wrap(
        BudgetDetailSheet(
          group: _home(
            budget: const GroupBudget(amount: 1500, period: BudgetPeriod.total),
          ),
          today: _today,
        ),
      ),
    );
    expect(find.text('BUDGET · IN TOTAL'), findsOneWidget);
    expect(find.textContaining('BEFORE'), findsNothing);
    expect(
      find.text(
        'Set the group’s dates to see how much you can spend each day.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the settings sheet saves period and amount', (tester) async {
    BudgetSheetResult? result;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showBudgetSettingsSheet(
              context,
              budget: null,
              currency: '€',
              groupType: ExpenseGroupType.travel,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    // A trip starts on "In total"; no "Remove budget" without one.
    expect(find.text('Amount for the whole group'), findsWidgets);
    expect(find.text('Remove budget'), findsNothing);
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '150,5');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      (result as BudgetSaved).budget,
      const GroupBudget(amount: 150.5, period: BudgetPeriod.weekly),
    );
  });

  testWidgets('the settings sheet removes a budget', (tester) async {
    BudgetSheetResult? result;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showBudgetSettingsSheet(
              context,
              budget: _monthly,
              currency: '€',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove budget'));
    await tester.pumpAndSettle();
    expect(result, isA<BudgetRemoved>());
  });

  group('group settings › Budget', () {
    setUp(useTestDatabase);

    testWidgets('sets, shows and removes the budget', (tester) async {
      final group = _home();
      await tester.runAsync(() => ExpenseGroupStorageV2.addExpenseGroup(group));
      var updates = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: GroupSettingsPage(trip: group, onGroupUpdated: () => updates++),
        ),
      );
      expect(find.text('None'), findsOneWidget);

      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();
      expect(find.text('Amount per month'), findsWidgets);
      await tester.enterText(find.byType(TextFormField), '600');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      for (var i = 0; i < 10 && updates == 0; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.text('600.00 € · Monthly'), findsOneWidget);
      expect(updates, 1);
      final stored = await tester.runAsync(
        () => ExpenseGroupStorageV2.getTripById(group.id),
      );
      expect(stored!.budget, _monthly);
    });
  });
}
