import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/group_quick_actions.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('home shortcuts: the usual form and search, no map', (
    tester,
  ) async {
    final group = ExpenseGroup(
      title: 'Rome',
      expenses: [],
      participants: [ExpenseParticipant(name: 'Anna')],
      currency: '€',
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: GroupQuickActions(group: group, onExpenseAdded: () {}),
        ),
      ),
    );
    await tester.pump();
    // Home's "+" writes the expense in one line: the form is a shortcut.
    expect(find.text('New expense'), findsOneWidget);
    expect(find.text('Map'), findsNothing);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Overview'), findsNothing);
    expect(find.text('Share'), findsNothing);
    // No receipt reading in this build (as in F-Droid): a receipt photo
    // instead of the scan, in the same spot.
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Scan'), findsNothing);
  });
}
