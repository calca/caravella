import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/file_based_expense_group_repository.dart';
import 'package:org_app_caravella/data/storage_errors.dart';
import 'package:org_app_caravella/data/expense_group.dart';
import 'package:org_app_caravella/data/expense_participant.dart';
import 'package:org_app_caravella/data/expense_category.dart';
import 'package:org_app_caravella/data/expense_details.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  group('FileBasedExpenseGroupRepository', () {
    late FileBasedExpenseGroupRepository repository;
    late ExpenseGroup testGroup;
    late ExpenseParticipant participant1;
    late ExpenseParticipant participant2;
    late ExpenseCategory category;

    setUp(() async {
      repository = FileBasedExpenseGroupRepository();

      // Clean up any existing test data
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/expense_group_storage.json');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors during cleanup
      }

      // Clear cache before each test
      repository.clearCache();

      // Set up test data
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

      test('should handle delete of non-existent group', () async {
        final result = await repository.deleteGroup('non-existent');
        expect(result.isFailure, isTrue);
        expect(result.error, isA<EntityNotFoundError>());
      });
    });

    group('Filtering Operations', () {
      late ExpenseGroup activeGroup;
      late ExpenseGroup archivedGroup;
      late ExpenseGroup pinnedGroup;

      setUp(() async {
        activeGroup = testGroup.copyWith(
          id: 'active-group',
          title: 'Active Group',
          archived: false,
          pinned: false,
        );

        archivedGroup = testGroup.copyWith(
          id: 'archived-group',
          title: 'Archived Group',
          archived: true,
          pinned: false,
        );

        pinnedGroup = testGroup.copyWith(
          id: 'pinned-group',
          title: 'Pinned Group',
          archived: false,
          pinned: true,
        );

        await repository.saveGroup(activeGroup);
        await repository.saveGroup(archivedGroup);
        await repository.saveGroup(pinnedGroup);
      });

      test('should get all groups', () async {
        final result = await repository.getAllGroups();
        expect(result.isSuccess, isTrue);
        expect(result.data!.length, equals(3));
      });

      test('should get only active groups', () async {
        final result = await repository.getActiveGroups();
        expect(result.isSuccess, isTrue);
        expect(result.data!.length, equals(2));
        expect(result.data!.every((group) => !group.archived), isTrue);
      });

      test('should get only archived groups', () async {
        final result = await repository.getArchivedGroups();
        expect(result.isSuccess, isTrue);
        expect(result.data!.length, equals(1));
        expect(result.data!.first.archived, isTrue);
      });

      test('should get pinned group', () async {
        final result = await repository.getPinnedGroup();
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.pinned, isTrue);
        expect(result.data!.id, equals('pinned-group'));
      });
    });

    group('Pin Operations', () {
      late ExpenseGroup group1;
      late ExpenseGroup group2;

      setUp(() async {
        group1 = testGroup.copyWith(
          id: 'group1',
          title: 'Group 1',
          pinned: false,
        );

        group2 = testGroup.copyWith(
          id: 'group2',
          title: 'Group 2',
          pinned: false,
        );

        await repository.saveGroup(group1);
        await repository.saveGroup(group2);
      });

      test('should set pinned group and unpin others', () async {
        // Pin group1
        final pin1Result = await repository.setPinnedGroup('group1');
        expect(pin1Result.isSuccess, isTrue);

        // Verify group1 is pinned
        final group1Result = await repository.getGroupById('group1');
        expect(group1Result.data!.pinned, isTrue);

        // Pin group2 (should unpin group1)
        final pin2Result = await repository.setPinnedGroup('group2');
        expect(pin2Result.isSuccess, isTrue);

        // Verify group2 is pinned and group1 is not
        final updatedGroup1 = await repository.getGroupById('group1');
        final updatedGroup2 = await repository.getGroupById('group2');

        expect(updatedGroup1.data!.pinned, isFalse);
        expect(updatedGroup2.data!.pinned, isTrue);
      });

      test('should remove pin from group', () async {
        // Pin group1
        await repository.setPinnedGroup('group1');

        // Remove pin
        final result = await repository.removePinnedGroup('group1');
        expect(result.isSuccess, isTrue);

        // Verify no group is pinned
        final pinnedResult = await repository.getPinnedGroup();
        expect(pinnedResult.data, isNull);
      });

      test('should not pin archived group', () async {
        // Archive group1
        await repository.archiveGroup('group1');

        // Try to pin archived group
        final result = await repository.setPinnedGroup('group1');
        expect(result.isFailure, isTrue);
        expect(result.error, isA<ValidationError>());
      });
    });

    group('Archive Operations', () {
      test('should archive group and unpin it', () async {
        // Pin the group first
        await repository.setPinnedGroup(testGroup.id);

        // Archive the group
        final result = await repository.archiveGroup(testGroup.id);
        expect(result.isSuccess, isTrue);

        // Verify group is archived and not pinned
        final groupResult = await repository.getGroupById(testGroup.id);
        expect(groupResult.data!.archived, isTrue);
        expect(groupResult.data!.pinned, isFalse);
      });

      test('should unarchive group', () async {
        // Archive the group
        await repository.archiveGroup(testGroup.id);

        // Unarchive the group
        final result = await repository.unarchiveGroup(testGroup.id);
        expect(result.isSuccess, isTrue);

        // Verify group is not archived
        final groupResult = await repository.getGroupById(testGroup.id);
        expect(groupResult.data!.archived, isFalse);
      });
    });

    group('Metadata Update', () {
      test('should update metadata while preserving expenses', () async {
        // Save initial group with expenses
        await repository.saveGroup(testGroup);

        // Create updated group with new metadata but different expenses
        final newParticipant = ExpenseParticipant(name: 'Bob', id: 'p3');
        final updatedGroup = testGroup.copyWith(
          title: 'Updated Title',
          participants: [participant1, participant2, newParticipant],
          expenses: [], // Different expenses (should be ignored)
        );

        // Update metadata
        final result = await repository.updateGroupMetadata(updatedGroup);
        expect(result.isSuccess, isTrue);

        // Verify metadata was updated but expenses preserved
        final retrievedGroup = await repository.getGroupById(testGroup.id);
        expect(retrievedGroup.data!.title, equals('Updated Title'));
        expect(retrievedGroup.data!.participants.length, equals(3));
        expect(
          retrievedGroup.data!.expenses.length,
          equals(1),
        ); // Original expenses preserved
      });

      test('should fail to update non-existent group metadata', () async {
        final result = await repository.updateGroupMetadata(testGroup);
        expect(result.isFailure, isTrue);
        expect(result.error, isA<EntityNotFoundError>());
      });
    });

    group('Validation', () {
      test('should reject invalid group on save', () async {
        final invalidGroup = testGroup.copyWith(title: ''); // Empty title
        final result = await repository.saveGroup(invalidGroup);
        expect(result.isFailure, isTrue);
        expect(result.error, isA<ValidationError>());
      });

      test('should validate group correctly', () async {
        final validResult = repository.validateGroup(testGroup);
        expect(validResult.isSuccess, isTrue);

        final invalidGroup = testGroup.copyWith(title: '');
        final invalidResult = repository.validateGroup(invalidGroup);
        expect(invalidResult.isFailure, isTrue);
      });
    });

    group('Data Integrity', () {
      test('should check data integrity', () async {
        // Save some valid groups
        await repository.saveGroup(testGroup);

        final result = await repository.checkDataIntegrity();
        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty); // No issues
      });
    });

    group('Expense Operations', () {
      test('should get expense by ID', () async {
        await repository.saveGroup(testGroup);

        final result = await repository.getExpenseById(testGroup.id, 'e1');
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.id, equals('e1'));
      });

      test('should return null for non-existent expense', () async {
        await repository.saveGroup(testGroup);

        final result = await repository.getExpenseById(
          testGroup.id,
          'non-existent',
        );
        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });

      test('should fail to get expense from non-existent group', () async {
        final result = await repository.getExpenseById('non-existent', 'e1');
        expect(result.isFailure, isTrue);
        expect(result.error, isA<EntityNotFoundError>());
      });
    });

    group('Caching', () {
      test('should use cache for subsequent reads', () async {
        // Save group
        await repository.saveGroup(testGroup);

        // First read (from file)
        final firstRead = await repository.getGroupById(testGroup.id);
        expect(firstRead.isSuccess, isTrue);

        // Modify file externally to test caching
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/expense_group_storage.json');
        await file.writeAsString('[]'); // Clear file

        // Second read (should use cache, not see the empty file)
        final secondRead = await repository.getGroupById(testGroup.id);
        expect(secondRead.isSuccess, isTrue);
        expect(secondRead.data, isNotNull); // Still cached

        // Force reload should see the change
        repository.forceReload();
        final thirdRead = await repository.getGroupById(testGroup.id);
        expect(thirdRead.data, isNull); // Now sees the empty file
      });

      test('should clear cache correctly', () async {
        // Save group
        await repository.saveGroup(testGroup);

        // Read to populate cache
        await repository.getGroupById(testGroup.id);

        // Clear cache
        repository.clearCache();

        // Modify file externally
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/expense_group_storage.json');
        await file.writeAsString('[]');

        // Next read should see the change (cache was cleared)
        final result = await repository.getGroupById(testGroup.id);
        expect(result.data, isNull);
      });
    });

    group('Error Handling', () {
      test('should handle malformed JSON gracefully', () async {
        // Write malformed JSON to file
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/expense_group_storage.json');
        await file.writeAsString('invalid json');

        final result = await repository.getAllGroups();
        expect(result.isFailure, isTrue);
        expect(result.error, isA<SerializationError>());
      });

      test('should handle empty file gracefully', () async {
        // Write empty file
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/expense_group_storage.json');
        await file.writeAsString('');

        final result = await repository.getAllGroups();
        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
      });

      test('should handle non-existent file gracefully', () async {
        // Ensure file doesn't exist
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/expense_group_storage.json');
        if (await file.exists()) {
          await file.delete();
        }

        final result = await repository.getAllGroups();
        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
      });
    });

    group('Sorting', () {
      test('should sort groups by timestamp (newest first)', () async {
        final now = DateTime.now();

        final oldGroup = testGroup.copyWith(
          id: 'old',
          timestamp: now.subtract(const Duration(days: 2)),
        );

        final newGroup = testGroup.copyWith(id: 'new', timestamp: now);

        final middleGroup = testGroup.copyWith(
          id: 'middle',
          timestamp: now.subtract(const Duration(days: 1)),
        );

        // Save in random order
        await repository.saveGroup(middleGroup);
        await repository.saveGroup(oldGroup);
        await repository.saveGroup(newGroup);

        final result = await repository.getAllGroups();
        expect(result.isSuccess, isTrue);

        final groups = result.data!;
        expect(groups.length, equals(3));
        expect(groups[0].id, equals('new')); // Newest first
        expect(groups[1].id, equals('middle'));
        expect(groups[2].id, equals('old')); // Oldest last
      });
    });
  });
}
