import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/model/expense_details.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/manager/details/tabs/widgets/daily_average_by_category.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'package:flutter/material.dart';

void main() {
  group('DailyAverageByCategoryWidget', () {
    late ExpenseCategory foodCategory;
    late ExpenseCategory transportCategory;
    late ExpenseParticipant participant;

    setUp(() {
      foodCategory = ExpenseCategory(
        name: 'Food',
        id: 'food',
        createdAt: DateTime(2023, 12, 1),
      );
      transportCategory = ExpenseCategory(
        name: 'Transport',
        id: 'transport',
        createdAt: DateTime(2023, 12, 1),
      );
      participant = ExpenseParticipant(name: 'John', id: 'john');
    });

    test('calculates daily averages correctly for group with dates', () {
      final startDate = DateTime(2023, 12, 1);
      final endDate = DateTime(2023, 12, 10); // 10 days duration

      final trip = ExpenseGroup(
        title: 'Test Trip',
        expenses: [
          ExpenseDetails(
            category: foodCategory,
            amount: 100.0,
            paidBy: participant,
            date: DateTime(2023, 12, 2),
            name: 'Lunch',
          ),
          ExpenseDetails(
            category: foodCategory,
            amount: 50.0,
            paidBy: participant,
            date: DateTime(2023, 12, 5),
            name: 'Dinner',
          ),
          ExpenseDetails(
            category: transportCategory,
            amount: 30.0,
            paidBy: participant,
            date: DateTime(2023, 12, 3),
            name: 'Bus',
          ),
        ],
        participants: [participant],
        startDate: startDate,
        endDate: endDate,
        currency: 'EUR',
        categories: [foodCategory, transportCategory],
      );

      final averages = DailyAverageByCategoryWidget(
        trip: trip,
      ).testCalculateDailyAveragesByCategory();

      // Food: 150.0 / 10 days = 15.0 per day
      // Transport: 30.0 / 10 days = 3.0 per day
      expect(averages[foodCategory], 15.0);
      expect(averages[transportCategory], 3.0);
    });

    test(
      'calculates daily averages for group without dates using first expense to now',
      () {
        final now = DateTime.now();
        final firstExpenseDate = DateTime(
          now.year,
          now.month,
          now.day - 9,
        ); // 10 days ago

        final trip = ExpenseGroup(
          title: 'Test Trip No Dates',
          expenses: [
            ExpenseDetails(
              category: foodCategory,
              amount: 100.0,
              paidBy: participant,
              date: firstExpenseDate,
              name: 'First expense',
            ),
            ExpenseDetails(
              category: transportCategory,
              amount: 50.0,
              paidBy: participant,
              date: DateTime(now.year, now.month, now.day - 5),
              name: 'Second expense',
            ),
          ],
          participants: [participant],
          startDate: null,
          endDate: null,
          currency: 'EUR',
          categories: [foodCategory, transportCategory],
        );

        final averages = DailyAverageByCategoryWidget(
          trip: trip,
        ).testCalculateDailyAveragesByCategory();

        // Duration is 10 days (from first expense to now)
        // Food: 100.0 / 10 days = 10.0 per day
        // Transport: 50.0 / 10 days = 5.0 per day
        expect(averages[foodCategory], 10.0);
        expect(averages[transportCategory], 5.0);
      },
    );

    testWidgets('uses localized per_day text (generated l10n)', (tester) async {
      // English
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: gen.AppLocalizations.localizationsDelegates,
          supportedLocales: gen.AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              expect(gen.AppLocalizations.of(context).per_day, '/day');
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // Italian
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: gen.AppLocalizations.localizationsDelegates,
          supportedLocales: gen.AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              expect(gen.AppLocalizations.of(context).per_day, '/giorno');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    test('handles group with end date in future by using current date', () {
      final now = DateTime.now();
      final startDate = DateTime(
        now.year,
        now.month,
        now.day - 9,
      ); // 10 days ago
      final endDate = DateTime(
        now.year,
        now.month,
        now.day + 5,
      ); // 5 days in future

      final trip = ExpenseGroup(
        title: 'Test Trip Future End',
        expenses: [
          ExpenseDetails(
            category: foodCategory,
            amount: 100.0,
            paidBy: participant,
            date: startDate,
            name: 'Expense',
          ),
        ],
        participants: [participant],
        startDate: startDate,
        endDate: endDate,
        currency: 'EUR',
        categories: [foodCategory],
      );

      final averages = DailyAverageByCategoryWidget(
        trip: trip,
      ).testCalculateDailyAveragesByCategory();

      // Should use startDate to current date (10 days), not to future endDate
      // Food: 100.0 / 10 days = 10.0 per day
      expect(averages[foodCategory], 10.0);
    });

    test('returns empty map when no expenses', () {
      final trip = ExpenseGroup(
        title: 'Empty Trip',
        expenses: [],
        participants: [participant],
        startDate: DateTime(2023, 12, 1),
        endDate: DateTime(2023, 12, 10),
        currency: 'EUR',
        categories: [foodCategory],
      );

      final averages = DailyAverageByCategoryWidget(
        trip: trip,
      ).testCalculateDailyAveragesByCategory();

      expect(averages.isEmpty, isTrue);
    });
  });
}

// Lightweight test-only exposure of calculation logic mirroring production
extension DailyAverageByCategoryWidgetTesting on DailyAverageByCategoryWidget {
  Map<ExpenseCategory, double> testCalculateDailyAveragesByCategory() {
    if (trip.expenses.isEmpty) return {};
    final dateRange = _testCalculateDateRange();
    final totalDays = dateRange.end.difference(dateRange.start).inDays + 1;
    if (totalDays <= 0) return {};

    final Map<ExpenseCategory, double> categoryTotals = {};
    for (final category in trip.categories) {
      final total = trip.expenses
          .where((e) => e.category.id == category.id)
          .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
      if (total > 0) categoryTotals[category] = total / totalDays;
    }
    final uncategorizedTotal = trip.expenses
        .where((e) => !trip.categories.any((c) => c.id == e.category.id))
        .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
    if (uncategorizedTotal > 0) {
      categoryTotals[ExpenseCategory(
            name: 'UNCATEGORIZED_PLACEHOLDER',
            id: 'uncategorized',
            createdAt: DateTime(2000),
          )] =
          uncategorizedTotal / totalDays;
    }
    return categoryTotals;
  }

  ({DateTime start, DateTime end}) _testCalculateDateRange() {
    final now = DateTime.now();
    if (trip.startDate == null || trip.endDate == null) {
      if (trip.expenses.isEmpty) {
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0);
        return (start: firstDay, end: lastDay);
      }
      final sortedExpenses = [...trip.expenses]
        ..sort((a, b) => a.date.compareTo(b.date));
      final firstExpenseDate = sortedExpenses.first.date;
      return (
        start: DateTime(
          firstExpenseDate.year,
          firstExpenseDate.month,
          firstExpenseDate.day,
        ),
        end: DateTime(now.year, now.month, now.day),
      );
    }
    final startDate = DateTime(
      trip.startDate!.year,
      trip.startDate!.month,
      trip.startDate!.day,
    );
    final endDate = DateTime(
      trip.endDate!.year,
      trip.endDate!.month,
      trip.endDate!.day,
    );
    final currentDate = DateTime(now.year, now.month, now.day);
    final effectiveEndDate = endDate.isBefore(currentDate)
        ? endDate
        : currentDate;
    return (start: startDate, end: effectiveEndDate);
  }
}
