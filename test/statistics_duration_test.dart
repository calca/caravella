import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/expense_group.dart';
import 'package:org_app_caravella/manager/details/tabs/overview_stats_logic.dart';

void main() {
  group('StatisticsTab Duration Logic', () {
    testWidgets('Should use daily stats for trips ≤ 7 days', (tester) async {
      final startDate = DateTime(2023, 12, 1);
      final endDate = DateTime(2023, 12, 7); // 6 days duration
      
      final trip = ExpenseGroup(
        title: 'Short Trip',
        expenses: [],
        participants: [],
        startDate: startDate,
        endDate: endDate,
        currency: 'EUR',
      );
      
  expect(useWeeklyAggregation(trip), isFalse);
      
      // Access the private method through a test-friendly way
      // For now, we'll test the duration calculation directly
      final duration = endDate.difference(startDate);
      expect(duration.inDays <= 7, isTrue);
    });

    testWidgets('Should use weekly stats for trips > 7 days', (tester) async {
      final startDate = DateTime(2023, 12, 1);
      final endDate = DateTime(2023, 12, 15); // 14 days duration
      
      final trip = ExpenseGroup(
        title: 'Long Trip',
        expenses: [],
        participants: [],
        startDate: startDate,
        endDate: endDate,
        currency: 'EUR',
      );
      
  expect(useWeeklyAggregation(trip), isTrue);
      
      final duration = endDate.difference(startDate);
      expect(duration.inDays > 7, isTrue);
    });

    testWidgets('Should use weekly stats when no dates defined', (tester) async {
      final trip = ExpenseGroup(
        title: 'No Date Trip',
        expenses: [],
        participants: [],
        currency: 'EUR',
      );
      
  expect(useWeeklyAggregation(trip), isTrue);
      
      expect(trip.startDate, isNull);
      expect(trip.endDate, isNull);
    });

    testWidgets('Should show date range chart for trips ≤ 30 days', (tester) async {
      final startDate = DateTime(2023, 12, 1);
      final endDate = DateTime(2023, 12, 25); // 24 days duration
      
      final trip = ExpenseGroup(
        title: 'Medium Trip',
        expenses: [],
        participants: [],
        startDate: startDate,
        endDate: endDate,
        currency: 'EUR',
      );
      
      expect(shouldShowDateRangeChart(trip), isTrue);
      
      final duration = endDate.difference(startDate);
      expect(duration.inDays <= 30, isTrue);
    });

    testWidgets('Should NOT show date range chart for trips > 30 days', (tester) async {
      final startDate = DateTime(2023, 12, 1);
      final endDate = DateTime(2024, 1, 15); // 45 days duration
      
      final trip = ExpenseGroup(
        title: 'Long Trip',
        expenses: [],
        participants: [],
        startDate: startDate,
        endDate: endDate,
        currency: 'EUR',
      );
      
      expect(shouldShowDateRangeChart(trip), isFalse);
      
      final duration = endDate.difference(startDate);
      expect(duration.inDays > 30, isTrue);
    });

    testWidgets('Should NOT show date range chart when no dates defined', (tester) async {
      final trip = ExpenseGroup(
        title: 'No Date Trip',
        expenses: [],
        participants: [],
        currency: 'EUR',
      );
      
      expect(shouldShowDateRangeChart(trip), isFalse);
      
      expect(trip.startDate, isNull);
      expect(trip.endDate, isNull);
    });

    testWidgets('Should show date range chart for same day trip', (tester) async {
      final date = DateTime(2023, 12, 1);
      
      final trip = ExpenseGroup(
        title: 'Same Day Trip',
        expenses: [],
        participants: [],
        startDate: date,
        endDate: date, // 0 days duration
        currency: 'EUR',
      );
      
      expect(shouldShowDateRangeChart(trip), isTrue);
      
      final duration = date.difference(date);
      expect(duration.inDays == 0, isTrue);
    });

    testWidgets('Should show date range chart for exactly 30 days', (tester) async {
      final startDate = DateTime(2023, 12, 1);
      final endDate = DateTime(2023, 12, 31); // 30 days duration
      
      final trip = ExpenseGroup(
        title: 'Month Trip',
        expenses: [],
        participants: [],
        startDate: startDate,
        endDate: endDate,
        currency: 'EUR',
      );
      
      expect(shouldShowDateRangeChart(trip), isTrue);
      
      final duration = endDate.difference(startDate);
      expect(duration.inDays == 30, isTrue);
    });
  });
}