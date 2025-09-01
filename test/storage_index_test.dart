import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/data/storage_index.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';
import 'package:io_caravella_egm/data/model/expense_details.dart';

void main() {
  group('GroupIndex', () {
    late GroupIndex index;
    late List<ExpenseGroup> testGroups;

    setUp(() {
      index = GroupIndex();

      final participant1 = ExpenseParticipant(name: 'John', id: 'p1');
      final participant2 = ExpenseParticipant(name: 'Jane', id: 'p2');
      final category1 = ExpenseCategory(name: 'Food', id: 'c1');
      final category2 = ExpenseCategory(name: 'Transport', id: 'c2');

      testGroups = [
        ExpenseGroup(
          id: 'group1',
          title: 'Trip to Paris',
          currency: 'EUR',
          participants: [participant1, participant2],
          categories: [category1, category2],
          expenses: [
            ExpenseDetails(
              id: 'e1',
              category: category1,
              amount: 50.0,
              paidBy: participant1,
              date: DateTime.now(),
              name: 'Lunch',
            ),
          ],
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          pinned: true,
          archived: false,
        ),
        ExpenseGroup(
          id: 'group2',
          title: 'Weekend Getaway',
          currency: 'USD',
          participants: [participant1],
          categories: [category2],
          expenses: [],
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          pinned: false,
          archived: false,
        ),
        ExpenseGroup(
          id: 'group3',
          title: 'Old Trip',
          currency: 'GBP',
          participants: [participant2],
          categories: [category1],
          expenses: [],
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          pinned: false,
          archived: true,
        ),
      ];
    });

    test('should rebuild index correctly', () {
      index.rebuild(testGroups);

      expect(index.size, equals(3));
      expect(index.isEmpty, isFalse);
      expect(index.isDirty, isFalse);

      final stats = index.getStats();
      expect(stats['totalGroups'], equals(3));
      expect(stats['activeGroups'], equals(2));
      expect(stats['archivedGroups'], equals(1));
      expect(stats['pinnedGroups'], equals(1));
    });

    test('should get group by ID', () {
      index.rebuild(testGroups);

      final group = index.getById('group1');
      expect(group, isNotNull);
      expect(group!.title, equals('Trip to Paris'));

      final nonExistent = index.getById('non-existent');
      expect(nonExistent, isNull);
    });

    test('should get all groups sorted by timestamp', () {
      index.rebuild(testGroups);

      final groups = index.getAllGroups();
      expect(groups.length, equals(3));
      expect(groups[0].id, equals('group1')); // Most recent
      expect(groups[1].id, equals('group2'));
      expect(groups[2].id, equals('group3')); // Oldest
    });

    test('should get active groups', () {
      index.rebuild(testGroups);

      final activeGroups = index.getActiveGroups();
      expect(activeGroups.length, equals(2));
      expect(activeGroups.every((g) => !g.archived), isTrue);
    });

    test('should get archived groups', () {
      index.rebuild(testGroups);

      final archivedGroups = index.getArchivedGroups();
      expect(archivedGroups.length, equals(1));
      expect(archivedGroups.first.archived, isTrue);
    });

    test('should get pinned group', () {
      index.rebuild(testGroups);

      final pinnedGroup = index.getPinnedGroup();
      expect(pinnedGroup, isNotNull);
      expect(pinnedGroup!.id, equals('group1'));
    });

    test('should get groups by participant', () {
      index.rebuild(testGroups);

      final groupsWithP1 = index.getGroupsByParticipant('p1');
      expect(groupsWithP1.length, equals(2));
      expect(
        groupsWithP1.every((g) => g.participants.any((p) => p.id == 'p1')),
        isTrue,
      );

      final groupsWithP2 = index.getGroupsByParticipant('p2');
      expect(groupsWithP2.length, equals(2));
    });

    test('should get groups by category', () {
      index.rebuild(testGroups);

      final groupsWithC1 = index.getGroupsByCategory('c1');
      expect(groupsWithC1.length, equals(2));
      expect(
        groupsWithC1.every((g) => g.categories.any((c) => c.id == 'c1')),
        isTrue,
      );
    });

    test('should get groups by currency', () {
      index.rebuild(testGroups);

      final eurGroups = index.getGroupsByCurrency('EUR');
      expect(eurGroups.length, equals(1));
      expect(eurGroups.first.currency, equals('EUR'));
    });

    test('should search by title', () {
      index.rebuild(testGroups);

      final parisGroups = index.searchByTitle('Paris');
      expect(parisGroups.length, equals(1));
      expect(parisGroups.first.title, contains('Paris'));

      final tripGroups = index.searchByTitle('trip');
      expect(tripGroups.length, equals(2)); // Case-insensitive
    });

    test('should update group in index', () {
      index.rebuild(testGroups);

      final updatedGroup = testGroups[0].copyWith(title: 'Updated Trip');
      index.updateGroup(updatedGroup);

      final retrieved = index.getById('group1');
      expect(retrieved!.title, equals('Updated Trip'));
    });

    test('should remove group from index', () {
      index.rebuild(testGroups);

      index.removeGroup('group1');

      expect(index.size, equals(2));
      expect(index.getById('group1'), isNull);
      expect(index.getPinnedGroup(), isNull); // Pin should be removed
    });

    test('should update pin status correctly', () {
      index.rebuild(testGroups);

      // Unpin group1 and pin group2
      final unpinnedGroup1 = testGroups[0].copyWith(pinned: false);
      final pinnedGroup2 = testGroups[1].copyWith(pinned: true);

      index.updateGroup(unpinnedGroup1);
      index.updateGroup(pinnedGroup2);

      final pinnedGroup = index.getPinnedGroup();
      expect(pinnedGroup!.id, equals('group2'));
    });

    test('should update archive status correctly', () {
      index.rebuild(testGroups);

      // Archive group1
      final archivedGroup1 = testGroups[0].copyWith(
        archived: true,
        pinned: false,
      );
      index.updateGroup(archivedGroup1);

      expect(index.getActiveGroups().length, equals(1));
      expect(index.getArchivedGroups().length, equals(2));
      expect(
        index.getPinnedGroup(),
        isNull,
      ); // Should be unpinned when archived
    });

    test('should validate consistency', () {
      index.rebuild(testGroups);

      final issues = index.validateConsistency();
      expect(issues, isEmpty); // Should be consistent
    });

    test('should detect consistency issues', () {
      // Enable corruption hook
      // ignore: invalid_use_of_visible_for_testing_member
      (index).enableTestSkipActiveTracking();
      index.rebuild(testGroups);
      final issues = index.validateConsistency();
      expect(issues, isNotEmpty);
      expect(issues.any((issue) => issue.contains('Active group')), isTrue);
      // Disable for safety
      // ignore: invalid_use_of_visible_for_testing_member
      (index).disableTestSkipActiveTracking();
    });

    test('should clear index', () {
      index.rebuild(testGroups);
      expect(index.size, equals(3));

      index.clear();
      expect(index.size, equals(0));
      expect(index.isEmpty, isTrue);
      expect(index.isDirty, isTrue);
    });

    test('should mark as dirty', () {
      index.rebuild(testGroups);
      expect(index.isDirty, isFalse);

      index.markDirty();
      expect(index.isDirty, isTrue);
    });
  });

  group('ExpenseIndex', () {
    late ExpenseIndex index;
    late List<ExpenseGroup> testGroups;

    setUp(() {
      index = ExpenseIndex();

      final participant = ExpenseParticipant(name: 'John', id: 'p1');
      final category = ExpenseCategory(name: 'Food', id: 'c1');

      testGroups = [
        ExpenseGroup(
          id: 'group1',
          title: 'Group 1',
          currency: 'USD',
          participants: [participant],
          categories: [category],
          expenses: [
            ExpenseDetails(
              id: 'expense1',
              category: category,
              amount: 50.0,
              paidBy: participant,
              date: DateTime.now(),
              name: 'Lunch',
            ),
            ExpenseDetails(
              id: 'expense2',
              category: category,
              amount: 25.0,
              paidBy: participant,
              date: DateTime.now(),
              name: 'Coffee',
            ),
          ],
          timestamp: DateTime.now(),
        ),
        ExpenseGroup(
          id: 'group2',
          title: 'Group 2',
          currency: 'USD',
          participants: [participant],
          categories: [category],
          expenses: [
            ExpenseDetails(
              id: 'expense3',
              category: category,
              amount: 100.0,
              paidBy: participant,
              date: DateTime.now(),
              name: 'Dinner',
            ),
          ],
          timestamp: DateTime.now(),
        ),
      ];
    });

    test('should rebuild expense index', () {
      index.rebuild(testGroups);

      final stats = index.getStats();
      expect(stats['totalExpenses'], equals(3));
      expect(stats['groupsWithExpenses'], equals(2));
    });

    test('should find group for expense', () {
      index.rebuild(testGroups);

      final groupId = index.getGroupIdForExpense('expense1');
      expect(groupId, equals('group1'));

      final nonExistent = index.getGroupIdForExpense('non-existent');
      expect(nonExistent, isNull);
    });

    test('should get expense location', () {
      index.rebuild(testGroups);

      final location = index.getExpenseLocation('expense2');
      expect(location, isNotNull);
      expect(location!['groupId'], equals('group1'));
      expect(location['expenseIndex'], equals(1));
    });

    test('should update group in expense index', () {
      index.rebuild(testGroups);

      // Add an expense to group1
      final newExpense = ExpenseDetails(
        id: 'expense4',
        category: testGroups[0].categories.first,
        amount: 75.0,
        paidBy: testGroups[0].participants.first,
        date: DateTime.now(),
        name: 'Snack',
      );

      final updatedGroup = testGroups[0].copyWith(
        expenses: [...testGroups[0].expenses, newExpense],
      );

      index.updateGroup(updatedGroup);

      final location = index.getExpenseLocation('expense4');
      expect(location, isNotNull);
      expect(location!['groupId'], equals('group1'));
      expect(location['expenseIndex'], equals(2));
    });

    test('should remove group from expense index', () {
      index.rebuild(testGroups);

      index.removeGroup('group1');

      expect(index.getGroupIdForExpense('expense1'), isNull);
      expect(index.getGroupIdForExpense('expense2'), isNull);
      expect(
        index.getGroupIdForExpense('expense3'),
        equals('group2'),
      ); // Should remain
    });

    test('should clear expense index', () {
      index.rebuild(testGroups);

      final statsBefore = index.getStats();
      expect(statsBefore['totalExpenses'], equals(3));

      index.clear();

      final statsAfter = index.getStats();
      expect(statsAfter['totalExpenses'], equals(0));
    });
  });
}
