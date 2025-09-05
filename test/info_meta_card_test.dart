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
    final start = DateTime(2025, 9, 1);
    final end = DateTime(2025, 9, 5);
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
    // The subtitle may include a newline + participants line; just ensure
    // the date range portion appears somewhere.
    expect(find.textContaining(expectedRange), findsOneWidget);
  });

  testWidgets('Info meta card shows single date when start==end', (
    tester,
  ) async {
    final start = DateTime(2025, 9, 1);
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
      start: DateTime(2025, 9, 1),
      end: DateTime(2025, 9, 2),
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
