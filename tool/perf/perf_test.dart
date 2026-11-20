import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/main.dart' as app;
import 'package:material_ui/material_ui.dart';

/// Frame times of the group page with a big group, in profile mode (#767).
/// How to run it, and the numbers to compare with: tool/perf/README.md.
///
/// First run (no data): fills the dev app with "Perf 1000" (1,000 expenses
/// over four months, a monthly budget, pinned) and 23 more groups of 40 in
/// the palette's colors, then stops. Second run: opens "Perf 1000", scrolls
/// its expenses, opens Statistics and scrolls it, then scrolls the Groups
/// page (a card each, with its type chip), each under watchPerformance.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('group page with 1,000 expenses', (tester) async {
    final onError = FlutterError.onError;
    app.main();
    await _settle(tester, 40);
    FlutterError.onError = onError;

    final groups = await ExpenseGroupStorageV2.getActiveGroups();
    if (!groups.any((g) => g.title == 'Perf 24')) {
      await _seed();
      binding.reportData = {'seeded': true};
      return;
    }

    Future<void> measure(String key, Future<void> Function() action) =>
        binding.watchPerformance(action, reportKey: key);

    await measure('open_group', () async {
      await tester.tap(find.text('Perf 1000').first);
      await _settle(tester, 12);
    });

    final list = find.byType(Scrollable).first;
    await measure('scroll_expenses', () async {
      for (var i = 0; i < 4; i++) {
        await tester.fling(list, const Offset(0, -900), 4000);
        await _settle(tester, 6);
      }
      for (var i = 0; i < 2; i++) {
        await tester.fling(list, const Offset(0, 900), 4000);
        await _settle(tester, 6);
      }
    });

    // Back to the top, where the section selector is.
    for (var i = 0; i < 8; i++) {
      await tester.fling(list, const Offset(0, 900), 4000);
      await _settle(tester, 3);
    }

    await measure('statistics', () async {
      // In the device's language.
      final statistics = gen.AppLocalizations.of(
        tester.element(find.byType(Scaffold).last),
      ).statistics;
      await tester.tap(find.text(statistics).first);
      await _settle(tester, 10);
      for (var i = 0; i < 3; i++) {
        await tester.fling(
          find.byType(Scrollable).first,
          const Offset(0, -900),
          4000,
        );
        await _settle(tester, 6);
      }
    });

    // Back to Home, then the Groups page: two columns of cards.
    // Back (the group page has its own top bar).
    await tester.state<NavigatorState>(find.byType(Navigator).first).maybePop();
    await _settle(tester, 8);
    final loc = gen.AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    );
    await measure('groups_page', () async {
      // Unselected destinations show only their icon: by their label.
      await tester.tap(find.bySemanticsLabel(loc.nav_groups).first);
      await _settle(tester, 8);
      final grid = find.byType(Scrollable).last;
      for (var i = 0; i < 3; i++) {
        await tester.fling(grid, const Offset(0, -900), 4000);
        await _settle(tester, 6);
      }
      for (var i = 0; i < 3; i++) {
        await tester.fling(grid, const Offset(0, 900), 4000);
        await _settle(tester, 6);
      }
    });
  });
}

Future<void> _settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

Future<void> _seed() async {
  // Participant and category ids are unique across the whole database:
  // each group gets its own.
  List<ExpenseParticipant> peopleOf(String group) => [
    for (final n in ['Anna', 'Bruno', 'Carla', 'Dario'])
      ExpenseParticipant(id: '$group-${n.toLowerCase()}', name: n),
  ];
  List<ExpenseCategory> catsOf(String group) => [
    for (final c in ['Food', 'Transport', 'Home', 'Fun', 'Shopping', 'Health'])
      ExpenseCategory(id: '$group-${c.toLowerCase()}', name: c),
  ];
  final start = DateTime(2026, 7, 20);
  ExpenseGroup group(
    String id,
    String title,
    int count, {
    bool big = false,
    int color = 0,
  }) {
    final people = peopleOf(id);
    final cats = catsOf(id);
    return ExpenseGroup(
      id: id,
      title: title,
      color: color,
      groupType:
          ExpenseGroupType.values[color % ExpenseGroupType.values.length],
      currency: '€',
      participants: people,
      categories: cats,
      pinned: big,
      budget: big
          ? const GroupBudget(amount: 2500, period: BudgetPeriod.monthly)
          : null,
      timestamp: DateTime(2026, 11, 19),
      expenses: [
        for (var i = 0; i < count; i++)
          ExpenseDetails(
            id: '$id-e$i',
            name: 'Expense $i ${cats[i % cats.length].name}',
            amount: 5 + (i * 37 % 120) + (i % 100) / 100,
            date: start.add(Duration(hours: i * 2900 ~/ count)),
            paidBy: people[i % people.length],
            category: cats[i % cats.length],
            note: i % 7 == 0 ? 'A note on expense $i' : null,
          ),
      ],
    );
  }

  // addExpenseGroup replaces a group with the same id: safe to run again.
  await ExpenseGroupStorageV2.addExpenseGroup(
    group('perf-big', 'Perf 1000', 1000, big: true),
  );
  for (var g = 2; g <= 24; g++) {
    await ExpenseGroupStorageV2.addExpenseGroup(
      group('perf-$g', 'Perf $g', 40, color: g % 8),
    );
  }
  await PreferencesService.instance.appState.setIsFirstStart(false);
}
