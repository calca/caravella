import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/group_card_header.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// Under the title on Home, one quiet line read as a phrase: the state first
/// (♥ for the favorite, the sync circle for a shared group), then the type
/// and the dates — "♥ ● ✈ Travel · Dec 12 – 18". No pills, and no gap when
/// a piece is missing.
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
    groupType: ExpenseGroupType.travel,
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

  double x(WidgetTester tester, Finder f) => tester.getCenter(f.first).dx;
  double y(WidgetTester tester, Finder f) => tester.getCenter(f.first).dy;

  final circle = find.byWidgetPredicate(
    (w) =>
        w is DecoratedBox &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).shape == BoxShape.circle,
  );

  testWidgets('favorite, shared, dates: heart, circle, type, dates in a row', (
    tester,
  ) async {
    final loc = await pump(
      tester,
      group(pinned: true, start: DateTime(2026, 12, 12), shared: true),
      width: 700,
    );
    final heart = find.byIcon(Icons.favorite_rounded);
    final type = find.byIcon(ExpenseGroupType.travel.icon);
    final text = find.textContaining('Travel · ');
    expect(text, findsOneWidget);
    expect(find.bySemanticsLabel(loc.pin), findsOneWidget);
    // No pills any more.
    expect(find.text(loc.pin), findsNothing);
    expect(find.text(loc.sync_group_shared), findsNothing);
    final row = y(tester, text);
    for (final f in [heart, circle, type]) {
      expect(y(tester, f), closeTo(row, 2));
    }
    expect(x(tester, heart), lessThan(x(tester, circle)));
    expect(x(tester, circle), lessThan(x(tester, type)));
    expect(x(tester, type), lessThan(x(tester, text)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('nothing but the type: just "Travel"', (tester) async {
    await pump(tester, group(pinned: false));
    expect(find.text('Travel'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    expect(circle, findsNothing);
    // It starts the line, under the title.
    expect(
      tester.getTopLeft(find.byIcon(ExpenseGroupType.travel.icon)).dx,
      lessThan(4),
    );
  });

  testWidgets('tight: the text is cut, the icons stay', (tester) async {
    await pump(
      tester,
      group(pinned: true, start: DateTime(2026, 12, 12), shared: true),
      width: 160,
    );
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(circle, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
