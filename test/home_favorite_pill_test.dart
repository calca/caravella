import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/group_card_header.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// On Home the favorite group shows a "♥ Favorite" pill like the "Shared"
/// one (a heart alone under the title looked lost). Dates at the start,
/// pills at the end, on one line: when it's tight the favorite pill keeps
/// only its heart instead of wrapping.
void main() {
  ExpenseGroup group({
    required bool pinned,
    DateTime? start,
    bool shared = false,
  }) => ExpenseGroup(
    id: 'g1',
    title: 'Lisbon',
    expenses: [],
    participants: [ExpenseParticipant(id: '1', name: 'Anna')],
    categories: [],
    currency: '€',
    timestamp: DateTime(2026, 12, 1),
    pinned: pinned,
    syncEnabled: shared,
    startDate: start,
    endDate: start?.add(const Duration(days: 6)),
  );

  Future<gen.AppLocalizations> pump(
    WidgetTester tester,
    ExpenseGroup g, {
    double width = 350,
  }) async {
    late gen.AppLocalizations loc;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: gen.AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: Builder(
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
        ),
      ),
    );
    return loc;
  }

  double centerY(WidgetTester tester, Finder f) => tester.getCenter(f.first).dy;

  testWidgets('favorite alone: a pill that says so', (tester) async {
    final loc = await pump(tester, group(pinned: true));
    expect(find.text(loc.pin), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.event_outlined), findsNothing);
    // Without dates it starts the line, under the title.
    expect(
      tester.getTopLeft(find.byIcon(Icons.favorite_rounded)).dx,
      lessThan(40),
    );
  });

  testWidgets('favorite, dates and shared: all on one line', (tester) async {
    final loc = await pump(
      tester,
      group(pinned: true, start: DateTime(2026, 12, 12), shared: true),
      // The test font's letters are wide squares: room as on a phone.
      width: 700,
    );
    final row = centerY(tester, find.byIcon(Icons.event_outlined));
    expect(centerY(tester, find.text(loc.pin)), closeTo(row, 2));
    expect(centerY(tester, find.text(loc.sync_group_shared)), closeTo(row, 2));
    // Dates first, then the pills.
    expect(
      tester.getCenter(find.byIcon(Icons.event_outlined)).dx,
      lessThan(tester.getCenter(find.text(loc.pin)).dx),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tight: the favorite pill keeps its heart, no wrapping', (
    tester,
  ) async {
    final loc = await pump(
      tester,
      group(pinned: true, start: DateTime(2026, 12, 12), shared: true),
      width: 240,
    );
    expect(find.text(loc.pin), findsNothing);
    expect(find.bySemanticsLabel(loc.pin), findsOneWidget);
    final row = centerY(tester, find.byIcon(Icons.event_outlined));
    expect(
      centerY(tester, find.byIcon(Icons.favorite_rounded)),
      closeTo(row, 2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('not a favorite: no heart', (tester) async {
    await pump(tester, group(pinned: false, start: DateTime(2026, 12, 12)));
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
  });
}
