import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/details/tabs/general_overview_tab.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';
import 'package:io_caravella_egm/data/model/expense_details.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/tabs/date_range_formatter.dart';

ExpenseGroup _group({DateTime? start, DateTime? end, int participants = 2}) {
  return ExpenseGroup(
    title: 'Test',
    expenses: [
      ExpenseDetails(
        id: 'e1',
        name: 'Coffee',
        amount: 3.5,
        category: ExpenseCategory(name: 'General', id: 'c1'),
        paidBy: ExpenseParticipant(name: 'Payer', id: 'payer'),
        date: DateTime(2025, 9, 1),
      ),
    ],
    participants: List.generate(
      participants,
      (i) => ExpenseParticipant(name: 'P$i', id: 'p$i'),
    ),
    startDate: start,
    endDate: end,
    currency: '€',
  );
}

Widget _app(Widget child, Locale locale) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: locale,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('Info meta card shows localized full date range', (tester) async {
  // Use a fixed past range not ending today to ensure date range is shown.
  final start = DateTime(2025, 8, 1);
  final end = DateTime(2025, 8, 5);
    final g = _group(start: start, end: end, participants: 3);
    await tester.pumpWidget(
      _app(GeneralOverviewTab(trip: g), const Locale('en')),
    );
    await tester.pumpAndSettle();

    final expectedRange = formatDateRange(
      start: start,
      end: end,
      locale: const Locale('en'),
    );
    // Collect all Text widgets and ensure at least one contains the expected range.
    bool found = false;
    final elementList = <Element>[];
    find.byType(Text).evaluate().forEach(elementList.add);
    for (final el in elementList) {
      final widget = el.widget as Text;
      if ((widget.data ?? '').contains(expectedRange)) {
        found = true;
        break;
      }
    }
    expect(found, isTrue, reason: 'Expected to find date range "$expectedRange" in any Text widget');
  });

  testWidgets('Info meta card shows single date when start==end', (
    tester,
  ) async {
  final start = DateTime(2025, 8, 1);
    final g = _group(start: start, end: start, participants: 1);
    await tester.pumpWidget(
      _app(GeneralOverviewTab(trip: g), const Locale('en')),
    );
    await tester.pumpAndSettle();
    final single = formatDateRange(
      start: start,
      end: start,
      locale: const Locale('en'),
    );
    expect(find.textContaining(' - '), findsNothing);
    expect(find.textContaining(single), findsOneWidget);
  });

  testWidgets('Info meta card shows fallback dash when no dates', (
    tester,
  ) async {
    final g = _group(start: null, end: null, participants: 2);
    await tester.pumpWidget(
      _app(GeneralOverviewTab(trip: g), const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('–'), findsOneWidget);
  });

  testWidgets('Grid contains 4 KPI cards', (tester) async {
    final g = _group(
      start: DateTime(2025, 8, 1),
      end: DateTime(2025, 8, 2),
      participants: 2,
    );
    await tester.pumpWidget(
      _app(GeneralOverviewTab(trip: g), const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Total spent'), findsOneWidget);
    expect(find.text('Info'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
  });
}
