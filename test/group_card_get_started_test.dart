import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/group_card_get_started.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(ExpenseGroup group, VoidCallback onAdd) => MaterialApp(
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Builder(
    builder: (context) => Scaffold(
      body: GroupCardGetStarted(
        group: group,
        theme: Theme.of(context),
        localizations: AppLocalizations.of(context),
        onAddExpense: onAdd,
      ),
    ),
  ),
);

void main() {
  testWidgets('a new group has only the group step done', (tester) async {
    var added = 0;
    final group = ExpenseGroup(
      title: 'Rome',
      expenses: [],
      participants: [ExpenseParticipant(name: 'Anna')],
      currency: '€',
    );
    await tester.pumpWidget(_wrap(group, () => added++));

    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('1 of 4 done'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Add the first expense'));
    expect(added, 1);
  });

  testWidgets('participants and a color tick their steps', (tester) async {
    final group = ExpenseGroup(
      title: 'Rome',
      expenses: [],
      participants: [
        ExpenseParticipant(name: 'Anna'),
        ExpenseParticipant(name: 'Marco'),
      ],
      currency: '€',
      color: 1,
    );
    await tester.pumpWidget(_wrap(group, () {}));

    expect(find.text('3 of 4 done'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
    expect(find.bySemanticsLabel('Add the participants, done'), findsOneWidget);
  });
}
