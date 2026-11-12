import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_balances_view.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_detail_header.dart';
import 'package:io_caravella_egm/manager/expense/components/expense_form_component.dart';
import 'package:io_caravella_egm/manager/expense/components/expense_form_config.dart';
import 'package:io_caravella_egm/manager/group/group_type/group_type_card.dart';
import 'package:material_ui/material_ui.dart';

/// What the non-regression pass on v2.5.0-rc.1 found (docs/NRT.md).
void main() {
  final anna = ExpenseParticipant(id: 'a', name: 'Anna');
  final sofia = ExpenseParticipant(id: 's', name: 'Sofia');
  final food = ExpenseCategory(id: 'f', name: 'Food');

  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );

  /// TalkBack can activate it: the node has a tap action, not only a
  /// label. Then performs it, as a double tap with TalkBack does.
  void tapWithTalkBack(WidgetTester tester, String label) {
    final node = tester.getSemantics(find.bySemanticsLabel(label));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    tester.semantics.tap(find.semantics.byLabel(label));
  }

  testWidgets('a group type card can be picked with TalkBack', (tester) async {
    final handle = tester.ensureSemantics();
    var picked = false;
    await tester.pumpWidget(
      wrap(
        SizedBox(
          width: 200,
          height: 200,
          child: GroupTypeCard(
            icon: Icons.flight_takeoff,
            title: 'Travel',
            subtitle: 'Holidays',
            selected: false,
            onTap: () => picked = true,
          ),
        ),
      ),
    );
    tapWithTalkBack(tester, 'Travel, Holidays');
    expect(picked, isTrue);
    handle.dispose();
  });

  testWidgets('"in kr" under the amount can be activated with TalkBack', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        ExpenseFormComponent(
          config: ExpenseFormConfig(
            participants: [anna],
            categories: [food],
            onExpenseAdded: (_) {},
            onCategoryAdded: (_) {},
            groupId: 'g',
            currency: '€',
            secondCurrency: const SecondCurrency(
              code: 'NOK',
              symbol: 'kr',
              rate: 11.63,
            ),
            autoLocationEnabled: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final loc = AppLocalizations.of(
      tester.element(find.byType(ExpenseFormComponent)),
    );
    tapWithTalkBack(tester, loc.entry_in_currency_label('kr'));
    await tester.pump();
    expect(find.text(loc.entry_in_currency('€')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('Today with a budget can be opened with TalkBack', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var opened = false;
    await tester.pumpWidget(
      wrap(
        GroupDetailHeader(
          group: ExpenseGroup(
            title: 'Norway',
            currency: '€',
            participants: [anna],
            categories: [food],
            budget: const GroupBudget(amount: 60, period: BudgetPeriod.daily),
            expenses: [
              ExpenseDetails(
                name: 'Ferry',
                amount: 93.19,
                paidBy: anna,
                category: food,
                date: DateTime(2026, 11, 12, 10),
              ),
            ],
          ),
          foreground: Colors.black,
          today: DateTime(2026, 11, 12, 18),
          onOpenBudget: () => opened = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final loc = AppLocalizations.of(
      tester.element(find.byType(GroupDetailHeader)),
    );
    tapWithTalkBack(tester, loc.budget_today_over('93.19 €', '60.00 €'));
    expect(opened, isTrue);
    handle.dispose();
  });

  testWidgets('balances say who paid back in Settle up', (tester) async {
    final group = ExpenseGroup(
      title: 'Norway',
      currency: '€',
      participants: [anna, sofia],
      categories: [food],
      expenses: [
        ExpenseDetails(
          name: 'Dinner',
          amount: 40,
          paidBy: anna,
          category: food,
          date: DateTime(2026, 11, 12),
        ),
      ],
      payments: [
        SettlePayment(
          id: 'p',
          fromId: 's',
          toId: 'a',
          amount: 20,
          date: DateTime(2026, 11, 12),
        ),
      ],
    );
    await tester.pumpWidget(wrap(GroupBalancesView(group: group)));
    await tester.pumpAndSettle();
    final loc = AppLocalizations.of(
      tester.element(find.byType(GroupBalancesView)),
    );
    expect(
      find.text(loc.balance_paid_and_settled('0.00 €', '20.00 €')),
      findsOneWidget,
    );
    expect(
      find.text(loc.balance_paid_and_received('40.00 €', '20.00 €')),
      findsOneWidget,
    );
  });

  testWidgets('a recent expense shows the receipt amount under it', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const ExpenseAmountCard(
          title: 'Ferry',
          amount: 38.69,
          checked: true,
          secondaryAmount: '450.00 kr',
        ),
      ),
    );
    expect(find.text('450.00 kr'), findsOneWidget);
  });
}
