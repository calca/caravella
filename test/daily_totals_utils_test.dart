import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/details/pages/tabs/usecase/daily_totals_utils.dart';
import 'package:caravella_core/caravella_core.dart';

ExpenseGroup _group({
  required List<ExpenseDetails> expenses,
  DateTime? start,
  DateTime? end,
}) => ExpenseGroup(
  title: 'G',
  expenses: expenses,
  participants: [ExpenseParticipant(id: 'p1', name: 'P1')],
  startDate: start,
  endDate: end,
  currency: '€',
  categories: [ExpenseCategory(id: 'c', name: 'Cat')],
);

ExpenseDetails _exp(String id, DateTime d, double amt) => ExpenseDetails(
  id: id,
  name: id,
  amount: amt,
  date: d,
  category: ExpenseCategory(id: 'c', name: 'Cat'),
  paidBy: ExpenseParticipant(id: 'p1', name: 'P1'),
);

void main() {
  group('daily_totals_utils', () {
    test('calculateDailyTotalsOptimized single day', () {
      final day = DateTime(2025, 9, 5);
      final g = _group(expenses: [_exp('e1', day, 10)], start: day, end: day);
      final totals = calculateDailyTotalsOptimized(g, day, 1);
      expect(totals, [10]);
    });

    test('buildWeeklySeries returns 7 values', () {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final g = _group(
        expenses: [
          _exp('e1', monday, 5),
          _exp('e2', monday.add(const Duration(days: 3)), 7),
        ],
        start: monday,
        end: monday.add(const Duration(days: 6)),
      );
      final weekly = buildWeeklySeries(g);
      expect(weekly.length, 7);
      expect(weekly.reduce((a, b) => a + b), 12);
    });

    test('buildMonthlySeries spans current month length', () {
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final start = DateTime(now.year, now.month, 1);
      final g = _group(
        expenses: [
          _exp('e1', start, 3),
          _exp('e2', start.add(const Duration(days: 10)), 2),
        ],
        start: start,
        end: start.add(Duration(days: daysInMonth - 1)),
      );
      final monthly = buildMonthlySeries(g);
      expect(monthly.length, daysInMonth);
      expect(monthly.reduce((a, b) => a + b), 5);
    });

    test('buildAdaptiveDateRangeSeries returns empty when >30 days', () {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 2, 15); // >30 days
      final g = _group(expenses: [], start: start, end: end);
      final series = buildAdaptiveDateRangeSeries(g);
      expect(series, isEmpty);
    });

    test('buildAdaptiveDateRangeSeries returns data when <=30 days', () {
      final start = DateTime(2025, 3, 1);
      final end = DateTime(2025, 3, 15); // 15 days
      final g = _group(
        expenses: [
          _exp('e1', start, 4),
          _exp('e2', start.add(const Duration(days: 5)), 6),
        ],
        start: start,
        end: end,
      );
      final series = buildAdaptiveDateRangeSeries(g);
      expect(series.length, 15);
      expect(series.reduce((a, b) => a + b), 10);
    });
  });
}
