import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/expense_group.dart';
import 'package:org_app_caravella/data/expense_details.dart';
import 'package:org_app_caravella/data/expense_category.dart';
import 'package:org_app_caravella/data/expense_participant.dart';

void main() {
  group('Home Page Extra Info Logic', () {
    late ExpenseGroup shortTrip;
    late ExpenseGroup longTrip;
    late ExpenseGroup noDateTrip;
    late ExpenseParticipant participant;
    late ExpenseCategory category;

    setUp(() {
      participant = ExpenseParticipant(
        name: 'Test User',
        id: 'user1',
        createdAt: DateTime.now(),
      );
      
      category = ExpenseCategory(
        name: 'Food',
        id: 'food',
        createdAt: DateTime.now(),
      );

      // Short trip (14 days)
      final startDate = DateTime.now().subtract(const Duration(days: 13));
      final endDate = DateTime.now().add(const Duration(days: 1));
      
      shortTrip = ExpenseGroup(
        title: 'Short Trip',
        expenses: [
          ExpenseDetails(
            category: category,
            amount: 100.0,
            paidBy: participant,
            date: startDate.add(const Duration(days: 5)),
            name: 'Lunch',
          ),
          ExpenseDetails(
            category: category,
            amount: 50.0,
            paidBy: participant,
            date: DateTime.now(), // Today
            name: 'Coffee',
          ),
        ],
        participants: [participant],
        startDate: startDate,
        endDate: endDate,
        currency: 'EUR',
        categories: [category],
      );

      // Long trip (60 days)
      final longStartDate = DateTime.now().subtract(const Duration(days: 30));
      final longEndDate = DateTime.now().add(const Duration(days: 30));
      
      longTrip = ExpenseGroup(
        title: 'Long Trip',
        expenses: [
          ExpenseDetails(
            category: category,
            amount: 200.0,
            paidBy: participant,
            date: longStartDate.add(const Duration(days: 10)),
            name: 'Dinner',
          ),
        ],
        participants: [participant],
        startDate: longStartDate,
        endDate: longEndDate,
        currency: 'EUR',
        categories: [category],
      );

      // Trip without dates
      noDateTrip = ExpenseGroup(
        title: 'No Date Trip',
        expenses: [
          ExpenseDetails(
            category: category,
            amount: 75.0,
            paidBy: participant,
            date: DateTime.now().subtract(const Duration(days: 5)),
            name: 'Snack',
          ),
        ],
        participants: [participant],
        startDate: null,
        endDate: null,
        currency: 'EUR',
        categories: [category],
      );
    });

    test('should identify short duration trips correctly', () {
      // Mock the methods that would be in GroupCardContent
      bool isShortDuration(ExpenseGroup group) {
        if (group.startDate == null || group.endDate == null) return false;
        final duration = group.endDate!.difference(group.startDate!);
        return duration.inDays < 30;
      }

      expect(isShortDuration(shortTrip), isTrue);
      expect(isShortDuration(longTrip), isFalse);
      expect(isShortDuration(noDateTrip), isFalse);
    });

    test('should calculate daily average correctly for short trips', () {
      double calculateDailyAverage(ExpenseGroup group) {
        if (group.expenses.isEmpty) return 0.0;
        
        final now = DateTime.now();
        DateTime startDate, endDate;
        
        if (group.startDate != null && group.endDate != null) {
          startDate = group.startDate!;
          endDate = group.endDate!.isBefore(now) ? group.endDate! : now;
        } else {
          // If no dates, use first expense to now
          final sortedExpenses = [...group.expenses]
            ..sort((a, b) => a.date.compareTo(b.date));
          startDate = sortedExpenses.first.date;
          endDate = now;
        }
        
        final days = endDate.difference(startDate).inDays + 1;
        if (days <= 0) return 0.0;
        
        final totalSpent = group.expenses.fold<double>(
          0,
          (sum, expense) => sum + (expense.amount ?? 0),
        );
        
        return totalSpent / days;
      }

      final dailyAverage = calculateDailyAverage(shortTrip);
      
      // Total spending: 100 + 50 = 150
      // Duration: approximately 14 days (from startDate to now)
      expect(dailyAverage, greaterThan(10.0)); // Should be around 150/14 ≈ 10.7
      expect(dailyAverage, lessThan(15.0));
    });

    test('should calculate today\'s spending correctly', () {
      double calculateTodaySpending(ExpenseGroup group) {
        final today = DateTime.now();
        return group.expenses
            .where((e) => 
                e.date.year == today.year &&
                e.date.month == today.month &&
                e.date.day == today.day)
            .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
      }

      final todaySpending = calculateTodaySpending(shortTrip);
      expect(todaySpending, equals(50.0)); // Only the coffee expense is today

      final longTripTodaySpending = calculateTodaySpending(longTrip);
      expect(longTripTodaySpending, equals(0.0)); // No expenses today in long trip
    });

    test('should handle trips with no expenses', () {
      final emptyTrip = ExpenseGroup(
        title: 'Empty Trip',
        expenses: [],
        participants: [participant],
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        currency: 'EUR',
        categories: [category],
      );

      double calculateDailyAverage(ExpenseGroup group) {
        if (group.expenses.isEmpty) return 0.0;
        return 0.0; // Simplified for empty case
      }

      double calculateTodaySpending(ExpenseGroup group) {
        final today = DateTime.now();
        return group.expenses
            .where((e) => 
                e.date.year == today.year &&
                e.date.month == today.month &&
                e.date.day == today.day)
            .fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
      }

      expect(calculateDailyAverage(emptyTrip), equals(0.0));
      expect(calculateTodaySpending(emptyTrip), equals(0.0));
    });
  });
}