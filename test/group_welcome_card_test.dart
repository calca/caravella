import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_welcome_card.dart';
import 'package:material_ui/material_ui.dart';

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _luca = ExpenseParticipant(id: 'l', name: 'Luca');
final _food = ExpenseCategory(id: 'f', name: 'Food');

final _group = ExpenseGroup(
  title: 'Norway Road Trip',
  participants: [_anna, _luca],
  categories: [_food],
  currency: '€',
  expenses: [
    ExpenseDetails(
      name: 'Ferry',
      amount: 86,
      date: DateTime(2026, 10, 22),
      paidBy: _anna,
      category: _food,
    ),
  ],
);

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('says who shared the group and what is in it', (tester) async {
    var dismissed = 0, added = 0;
    await tester.pumpWidget(
      _wrap(
        GroupWelcomeCard(
          group: _group,
          from: 'Pixel 9',
          onDismiss: () => dismissed++,
          onAddExpense: () => added++,
        ),
      ),
    );
    expect(find.text('You joined this group'), findsOneWidget);
    expect(find.textContaining('Shared by Pixel 9'), findsOneWidget);
    expect(find.textContaining('2 participants'), findsOneWidget);
    expect(find.textContaining('1 expense'), findsOneWidget);
    expect(find.text('P9'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.tap(find.text('Add expense'));
    expect((dismissed, added), (1, 1));
  });

  testWidgets('without the device name it skips "shared by"', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GroupWelcomeCard(
          group: _group,
          from: '',
          onDismiss: () {},
          onAddExpense: () {},
        ),
      ),
    );
    expect(find.textContaining('Shared by'), findsNothing);
    expect(find.byIcon(Icons.group_add_outlined), findsOneWidget);
  });
}
