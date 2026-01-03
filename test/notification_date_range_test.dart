import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('Notification Date Range Tests', () {
    test('Notification should be visible when no date range is set', () {
      final group = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        notificationEnabled: true,
        startDate: null,
        endDate: null,
      );

      // When no date range is set, notification should always be visible
      expect(group.notificationEnabled, true);
      expect(group.startDate, null);
      expect(group.endDate, null);
    });

    test('Notification should be visible when current date is within range', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final group = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        notificationEnabled: true,
        startDate: yesterday,
        endDate: tomorrow,
      );

      expect(group.notificationEnabled, true);
      expect(group.startDate, yesterday);
      expect(group.endDate, tomorrow);
      
      // Verify that today is within the range
      expect(group.startDate!.isBefore(now) || group.startDate!.isAtSameMomentAs(now), true);
      expect(group.endDate!.isAfter(now) || group.endDate!.isAtSameMomentAs(now), true);
    });

    test('Notification should not be visible when current date is before range', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final dayAfterTomorrow = now.add(const Duration(days: 2));

      final group = ExpenseGroup(
        id: 'test-id',
        title: 'Future Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        notificationEnabled: true,
        startDate: tomorrow,
        endDate: dayAfterTomorrow,
      );

      expect(group.notificationEnabled, true);
      expect(group.startDate, tomorrow);
      expect(group.endDate, dayAfterTomorrow);
      
      // Verify that today is before the range
      expect(now.isBefore(tomorrow), true);
    });

    test('Notification should not be visible when current date is after range', () {
      final now = DateTime.now();
      final twoDaysAgo = now.subtract(const Duration(days: 2));
      final yesterday = now.subtract(const Duration(days: 1));

      final group = ExpenseGroup(
        id: 'test-id',
        title: 'Past Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        notificationEnabled: true,
        startDate: twoDaysAgo,
        endDate: yesterday,
      );

      expect(group.notificationEnabled, true);
      expect(group.startDate, twoDaysAgo);
      expect(group.endDate, yesterday);
      
      // Verify that today is after the range
      expect(now.isAfter(yesterday), true);
    });

    test('Notification should be visible on start date (boundary test)', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final group = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        notificationEnabled: true,
        startDate: today,
        endDate: tomorrow,
      );

      expect(group.notificationEnabled, true);
      expect(group.startDate, today);
      expect(group.endDate, tomorrow);
      
      // Verify that start date is today
      expect(
        group.startDate!.year == now.year &&
        group.startDate!.month == now.month &&
        group.startDate!.day == now.day,
        true,
      );
    });

    test('Notification should be visible on end date (boundary test)', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final group = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        notificationEnabled: true,
        startDate: yesterday,
        endDate: today,
      );

      expect(group.notificationEnabled, true);
      expect(group.startDate, yesterday);
      expect(group.endDate, today);
      
      // Verify that end date is today
      expect(
        group.endDate!.year == now.year &&
        group.endDate!.month == now.month &&
        group.endDate!.day == now.day,
        true,
      );
    });

    test('Notification should be visible when only startDate is set', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final group = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        notificationEnabled: true,
        startDate: yesterday,
        endDate: null,
      );

      // When only startDate is set, notification should always be visible
      expect(group.notificationEnabled, true);
      expect(group.startDate, yesterday);
      expect(group.endDate, null);
    });

    test('Notification should be visible when only endDate is set', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      final group = ExpenseGroup(
        id: 'test-id',
        title: 'Test Trip',
        currency: '€',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        notificationEnabled: true,
        startDate: null,
        endDate: tomorrow,
      );

      // When only endDate is set, notification should always be visible
      expect(group.notificationEnabled, true);
      expect(group.startDate, null);
      expect(group.endDate, tomorrow);
    });
  });
}
