import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates a unique ExpenseGroup with all entities having unique IDs
ExpenseGroup createUniqueGroup({
  required String groupId,
  String title = 'Test Group',
  String currency = 'USD',
  bool archived = false,
  bool pinned = false,
  List<String>? participantNames,
  List<String>? categoryNames,
  bool includeExpense = true,
}) {
  final names = participantNames ?? ['John', 'Jane'];
  final catNames = categoryNames ?? ['Food'];

  final participants = names
      .asMap()
      .entries
      .map((e) => ExpenseParticipant(name: e.value, id: '${groupId}_p${e.key}'))
      .toList();

  final categories = catNames
      .asMap()
      .entries
      .map((e) => ExpenseCategory(name: e.value, id: '${groupId}_c${e.key}'))
      .toList();

  final expenses = includeExpense
      ? [
          ExpenseDetails(
            id: '${groupId}_e1',
            category: categories.first,
            amount: 50.0,
            paidBy: participants.first,
            date: DateTime.now(),
            name: 'Lunch',
          ),
        ]
      : <ExpenseDetails>[];

  return ExpenseGroup(
    id: groupId,
    title: title,
    currency: currency,
    participants: participants,
    categories: categories,
    expenses: expenses,
    timestamp: DateTime.now(),
    archived: archived,
    pinned: pinned,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SqliteExpenseGroupRepository', () {
    late SqliteExpenseGroupRepository repository;
    late ExpenseGroup testGroup;
    late ExpenseParticipant participant1;
    late ExpenseParticipant participant2;
    late ExpenseCategory category;
    late Directory tempDir;

    setUp(() async {
      // Create a unique temp directory for each test
      tempDir = Directory.systemTemp.createTempSync(
        'sqlite_test_${DateTime.now().millisecondsSinceEpoch}',
      );
      final dbPath = '${tempDir.path}/expense_groups.db';

      repository = SqliteExpenseGroupRepository(databasePath: dbPath);

      // Set up test data with unique IDs
      participant1 = ExpenseParticipant(name: 'John', id: 'p1');
      participant2 = ExpenseParticipant(name: 'Jane', id: 'p2');
      category = ExpenseCategory(name: 'Food', id: 'c1');

      testGroup = ExpenseGroup(
        id: 'test-group-1',
        title: 'Test Group',
        currency: 'USD',
        participants: [participant1, participant2],
        categories: [category],
        expenses: [
          ExpenseDetails(
            id: 'e1',
            category: category,
            amount: 50.0,
            paidBy: participant1,
            date: DateTime.now(),
            name: 'Lunch',
          ),
        ],
        timestamp: DateTime.now(),
      );
    });

    tearDown(() async {
      // Close database connection
      await repository.close();

      // Clean up temp directory
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    group('Basic Operations', () {
      test('should save and retrieve a group', () async {
        // Save group
        final saveResult = await repository.saveGroup(testGroup);
        expect(saveResult.isSuccess, isTrue);

        // Retrieve group
        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.isSuccess, isTrue);

        final retrievedGroup = getResult.data!;
        expect(retrievedGroup, isNotNull);
        expect(retrievedGroup.id, equals(testGroup.id));
        expect(retrievedGroup.title, equals(testGroup.title));
        expect(retrievedGroup.expenses.length, equals(1));
        expect(retrievedGroup.participants.length, equals(2));
        expect(retrievedGroup.categories.length, equals(1));
      });

      test('should return null for non-existent group', () async {
        final result = await repository.getGroupById('non-existent');
        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });

      test('should update existing group', () async {
        // Save initial group
        await repository.saveGroup(testGroup);

        // Update group
        final updatedGroup = testGroup.copyWith(title: 'Updated Title');
        final updateResult = await repository.saveGroup(updatedGroup);
        expect(updateResult.isSuccess, isTrue);

        // Verify update
        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.title, equals('Updated Title'));
      });

      test('should delete a group', () async {
        // Save group
        await repository.saveGroup(testGroup);

        // Verify it exists
        final beforeDelete = await repository.getGroupById(testGroup.id);
        expect(beforeDelete.data, isNotNull);

        // Delete group
        final deleteResult = await repository.deleteGroup(testGroup.id);
        expect(deleteResult.isSuccess, isTrue);

        // Verify it's gone
        final afterDelete = await repository.getGroupById(testGroup.id);
        expect(afterDelete.data, isNull);
      });

      test('should handle multiple groups', () async {
        // Create a second group with completely unique IDs
        final group2 = createUniqueGroup(
          groupId: 'test-group-2',
          title: 'Test Group 2',
        );

        // Save both groups
        await repository.saveGroup(testGroup);
        await repository.saveGroup(group2);

        // Retrieve all groups
        final allResult = await repository.getAllGroups();
        expect(allResult.isSuccess, isTrue);
        expect(allResult.data!.length, equals(2));
      });
    });

    group('Filtering Operations', () {
      late ExpenseGroup activeGroup;
      late ExpenseGroup archivedGroup;
      late ExpenseGroup pinnedGroup;

      setUp(() async {
        // Create groups with completely unique IDs for each entity
        activeGroup = createUniqueGroup(
          groupId: 'active-group',
          title: 'Active Group',
          archived: false,
          pinned: false,
        );

        archivedGroup = createUniqueGroup(
          groupId: 'archived-group',
          title: 'Archived Group',
          archived: true,
          pinned: false,
        );

        pinnedGroup = createUniqueGroup(
          groupId: 'pinned-group',
          title: 'Pinned Group',
          archived: false,
          pinned: true,
        );

        await repository.saveGroup(activeGroup);
        await repository.saveGroup(archivedGroup);
        await repository.saveGroup(pinnedGroup);
      });

      test('should get only active groups', () async {
        final result = await repository.getActiveGroups();
        expect(result.isSuccess, isTrue);

        final groups = result.data!;
        expect(groups.length, equals(2));
        expect(groups.every((g) => !g.archived), isTrue);
      });

      test('should get only archived groups', () async {
        final result = await repository.getArchivedGroups();
        expect(result.isSuccess, isTrue);

        final groups = result.data!;
        expect(groups.length, equals(1));
        expect(groups.first.archived, isTrue);
        expect(groups.first.id, equals('archived-group'));
      });

      test('should get all groups', () async {
        final result = await repository.getAllGroups();
        expect(result.isSuccess, isTrue);
        expect(result.data!.length, equals(3));
      });

      test('should get pinned group', () async {
        final result = await repository.getPinnedGroup();
        expect(result.isSuccess, isTrue);

        final pinned = result.data;
        expect(pinned, isNotNull);
        expect(pinned!.id, equals('pinned-group'));
        expect(pinned.pinned, isTrue);
      });
    });

    group('Pin and Archive Operations', () {
      test('should pin a group', () async {
        await repository.saveGroup(testGroup);

        final pinResult = await repository.setPinnedGroup(testGroup.id);
        expect(pinResult.isSuccess, isTrue);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.pinned, isTrue);
      });

      test('should unpin a group', () async {
        final pinnedGroup = testGroup.copyWith(pinned: true);
        await repository.saveGroup(pinnedGroup);

        final unpinResult = await repository.removePinnedGroup(testGroup.id);
        expect(unpinResult.isSuccess, isTrue);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.pinned, isFalse);
      });

      test('should archive a group', () async {
        await repository.saveGroup(testGroup);

        final archiveResult = await repository.archiveGroup(testGroup.id);
        expect(archiveResult.isSuccess, isTrue);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.archived, isTrue);
        expect(getResult.data!.pinned, isFalse); // Should also unpin
      });

      test('should unarchive a group', () async {
        final archivedGroup = testGroup.copyWith(archived: true);
        await repository.saveGroup(archivedGroup);

        final unarchiveResult = await repository.unarchiveGroup(testGroup.id);
        expect(unarchiveResult.isSuccess, isTrue);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.archived, isFalse);
      });

      test('should enforce single pin constraint', () async {
        // Create two groups with completely unique IDs
        final group1 = createUniqueGroup(groupId: 'group-1', title: 'Group 1');
        final group2 = createUniqueGroup(groupId: 'group-2', title: 'Group 2');

        await repository.saveGroup(group1);
        await repository.saveGroup(group2);

        // Pin first group
        await repository.setPinnedGroup('group-1');

        // Pin second group
        await repository.setPinnedGroup('group-2');

        // Only second group should be pinned
        final pinnedResult = await repository.getPinnedGroup();
        expect(pinnedResult.data!.id, equals('group-2'));

        // First group should not be pinned
        final group1Result = await repository.getGroupById('group-1');
        expect(group1Result.data!.pinned, isFalse);
      });
    });

    group('Expense Operations', () {
      test('should retrieve expense by ID', () async {
        await repository.saveGroup(testGroup);

        final expenseResult = await repository.getExpenseById(
          testGroup.id,
          'e1',
        );

        expect(expenseResult.isSuccess, isTrue);
        expect(expenseResult.data, isNotNull);
        expect(expenseResult.data!.id, equals('e1'));
        expect(expenseResult.data!.name, equals('Lunch'));
      });

      test('should handle non-existent expense', () async {
        await repository.saveGroup(testGroup);

        final result = await repository.getExpenseById(
          testGroup.id,
          'non-existent',
        );

        expect(result.isFailure, isTrue);
      });

      test('should save group with multiple expenses', () async {
        final expense2 = ExpenseDetails(
          id: 'e2',
          category: category,
          amount: 75.0,
          paidBy: participant2,
          date: DateTime.now(),
          name: 'Dinner',
        );

        final groupWithExpenses = testGroup.copyWith(
          expenses: [testGroup.expenses.first, expense2],
        );

        await repository.saveGroup(groupWithExpenses);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.expenses.length, equals(2));
      });
    });

    group('Validation', () {
      test('should validate group before saving', () async {
        final invalidGroup = testGroup.copyWith(title: '');

        final result = await repository.saveGroup(invalidGroup);
        expect(result.isFailure, isTrue);
        expect(result.error, isA<ValidationError>());
      });

      test('should check data integrity', () async {
        await repository.saveGroup(testGroup);

        final integrityResult = await repository.checkDataIntegrity();
        expect(integrityResult.isSuccess, isTrue);
        expect(integrityResult.data!.isEmpty, isTrue);
      });
    });

    group('Metadata Updates', () {
      test('should update only group metadata', () async {
        await repository.saveGroup(testGroup);

        final updatedGroup = testGroup.copyWith(
          title: 'New Title',
          currency: 'EUR',
        );

        final updateResult = await repository.updateGroupMetadata(updatedGroup);
        expect(updateResult.isSuccess, isTrue);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.title, equals('New Title'));
        expect(getResult.data!.currency, equals('EUR'));
        expect(
          getResult.data!.expenses.length,
          equals(1),
        ); // Expenses preserved
      });
    });

    group('Complex Data', () {
      test('should handle group with location data', () async {
        final expenseWithLocation = ExpenseDetails(
          id: 'e_loc',
          category: category,
          amount: 100.0,
          paidBy: participant1,
          date: DateTime.now(),
          name: 'Restaurant',
          location: ExpenseLocation(
            latitude: 40.7128,
            longitude: -74.0060,
            name: 'New York',
          ),
        );

        final groupWithLocation = testGroup.copyWith(
          expenses: [expenseWithLocation],
        );

        await repository.saveGroup(groupWithLocation);

        final getResult = await repository.getGroupById(testGroup.id);
        final retrievedExpense = getResult.data!.expenses.first;

        expect(retrievedExpense.location, isNotNull);
        expect(retrievedExpense.location!.latitude, equals(40.7128));
        expect(retrievedExpense.location!.longitude, equals(-74.0060));
        expect(retrievedExpense.location!.name, equals('New York'));
      });

      test('should handle group with attachment path', () async {
        final expenseWithAttachment = ExpenseDetails(
          id: 'e_att',
          category: category,
          amount: 50.0,
          paidBy: participant1,
          date: DateTime.now(),
          name: 'Receipt',
          attachments: ['/path/to/receipt.jpg'],
        );

        final groupWithAttachment = testGroup.copyWith(
          expenses: [expenseWithAttachment],
        );

        await repository.saveGroup(groupWithAttachment);

        final getResult = await repository.getGroupById(testGroup.id);
        final retrievedExpense = getResult.data!.expenses.first;

        expect(retrievedExpense.attachments, contains('/path/to/receipt.jpg'));
      });
    });
  });
}
