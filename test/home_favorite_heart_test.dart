import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/group_card_header.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// On Home the favorite group shows a heart before its dates, like the group
/// page, instead of a "Favorite" pill.
void main() {
  ExpenseGroup group({required bool pinned, DateTime? start}) => ExpenseGroup(
    id: 'g1',
    title: 'Lisbon',
    expenses: [],
    participants: [ExpenseParticipant(id: '1', name: 'Anna')],
    categories: [],
    currency: '€',
    timestamp: DateTime(2026, 12, 1),
    pinned: pinned,
    startDate: start,
    endDate: start?.add(const Duration(days: 6)),
  );

  Future<gen.AppLocalizations> pump(WidgetTester tester, ExpenseGroup g) async {
    late gen.AppLocalizations loc;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: gen.AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              loc = gen.AppLocalizations.of(context);
              return GroupCardHeader(
                group: g,
                localizations: loc,
                theme: Theme.of(context),
              );
            },
          ),
        ),
      ),
    );
    return loc;
  }

  testWidgets('favorite with dates: a heart, no pill', (tester) async {
    final loc = await pump(
      tester,
      group(pinned: true, start: DateTime(2026, 12, 12)),
    );
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.text(loc.pin), findsNothing);
    expect(find.bySemanticsLabel(loc.pin), findsOneWidget);
  });

  testWidgets('favorite without dates: the heart alone', (tester) async {
    await pump(tester, group(pinned: true));
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.event_outlined), findsNothing);
  });

  testWidgets('not a favorite: no heart', (tester) async {
    await pump(tester, group(pinned: false, start: DateTime(2026, 12, 12)));
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
  });
}
