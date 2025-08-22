import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/file_based_expense_group_repository.dart';
import 'package:org_app_caravella/data/storage_transaction.dart';
import 'package:org_app_caravella/data/storage_errors.dart';
import 'package:org_app_caravella/data/expense_group.dart';
import 'package:org_app_caravella/data/expense_participant.dart';
import 'package:org_app_caravella/data/expense_category.dart';
import 'package:org_app_caravella/data/expense_details.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  group('StorageTransaction', () {
    late FileBasedExpenseGroupRepository repository;
    late ExpenseGroup testGroup1;
    late ExpenseGroup testGroup2;
    late ExpenseParticipant participant;
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

      repository.clearCache();

      // Set up test data
      participant = ExpenseParticipant(name: 'John', id: 'p1');
      category = ExpenseCategory(name: 'Food', id: 'c1');

      testGroup1 = ExpenseGroup(
        id: 'group1',
        title: 'Group 1',
        currency: 'USD',
        participants: [participant],
        categories: [category],
        expenses: [],
        timestamp: DateTime.now(),
      );

      testGroup2 = ExpenseGroup(
        id: 'group2',
        title: 'Group 2',
        currency: 'USD',
        participants: [participant],
        categories: [category],
        expenses: [],
        timestamp: DateTime.now(),
      );
    });

    group('Transaction Building', () {
      test('should create empty transaction', () {
        final transaction = StorageTransaction();
        expect(transaction.isEmpty, isTrue);
        expect(transaction.operationCount, equals(0));
        expect(transaction.isExecuted, isFalse);
      });

      test('should add operations to transaction', () {
        final transaction = StorageTransaction();

        transaction.saveGroup(testGroup1);
        transaction.setPinnedGroup(testGroup1.id);
        transaction.archiveGroup(testGroup2.id);

        expect(transaction.isEmpty, isFalse);
        expect(transaction.operationCount, equals(3));
      });

      test('should prevent operations after execution', () {
        final transaction = StorageTransaction();
        transaction.markExecutedForTest();

        expect(() => transaction.saveGroup(testGroup1), throwsStateError);
        expect(() => transaction.deleteGroup('test'), throwsStateError);
        expect(() => transaction.setPinnedGroup('test'), throwsStateError);
      });
    });

    group('Transaction Execution', () {
      test('should execute empty transaction successfully', () async {
        final result = await repository.executeTransaction((tx) {
          // Empty transaction
        });

        expect(result.isSuccess, isTrue);
      });

      test('should execute save operations', () async {
        final result = await repository.executeTransaction((tx) {
          tx.saveGroup(testGroup1);
          tx.saveGroup(testGroup2);
        });

        expect(result.isSuccess, isTrue);

        // Verify groups were saved
        final group1Result = await repository.getGroupById(testGroup1.id);
        final group2Result = await repository.getGroupById(testGroup2.id);

        expect(group1Result.data, isNotNull);
        expect(group2Result.data, isNotNull);
      });

      test('should execute pin operations atomically', () async {
        // Save groups first
        await repository.saveGroup(testGroup1);
        await repository.saveGroup(testGroup2);

        // Pin both in a transaction (should unpin first when pinning second)
        final result = await repository.executeTransaction((tx) {
          tx.setPinnedGroup(testGroup1.id);
          tx.setPinnedGroup(testGroup2.id); // This should unpin group1
        });

        expect(result.isSuccess, isTrue);

        // Verify only group2 is pinned
        final group1Result = await repository.getGroupById(testGroup1.id);
        final group2Result = await repository.getGroupById(testGroup2.id);

        expect(group1Result.data!.pinned, isFalse);
        expect(group2Result.data!.pinned, isTrue);
      });

      test('should execute archive operations', () async {
        // Save and pin a group
        await repository.saveGroup(testGroup1.copyWith(pinned: true));

        // Archive it (should also unpin)
        final result = await repository.executeTransaction((tx) {
          tx.archiveGroup(testGroup1.id);
        });

        expect(result.isSuccess, isTrue);

        // Verify group is archived and unpinned
        final groupResult = await repository.getGroupById(testGroup1.id);
        expect(groupResult.data!.archived, isTrue);
        expect(groupResult.data!.pinned, isFalse);
      });

      test('should execute delete operations', () async {
        // Save group first
        await repository.saveGroup(testGroup1);

        // Delete it
        final result = await repository.executeTransaction((tx) {
          tx.deleteGroup(testGroup1.id);
        });

        expect(result.isSuccess, isTrue);

        // Verify group is gone
        final groupResult = await repository.getGroupById(testGroup1.id);
        expect(groupResult.data, isNull);
      });

      test('should execute metadata update operations', () async {
        // Save group with expenses first
        final groupWithExpenses = testGroup1.copyWith(
          expenses: [
            ExpenseDetails(
              id: 'e1',
              category: category,
              amount: 50.0,
              paidBy: participant,
              date: DateTime.now(),
              name: 'Lunch',
            ),
          ],
        );
        await repository.saveGroup(groupWithExpenses);

        // Update metadata
        final updatedGroup = testGroup1.copyWith(
          title: 'Updated Title',
          expenses: [], // Should be ignored
        );

        final result = await repository.executeTransaction((tx) {
          tx.updateGroupMetadata(updatedGroup);
        });

        expect(result.isSuccess, isTrue);

        // Verify metadata was updated but expenses preserved
        final groupResult = await repository.getGroupById(testGroup1.id);
        expect(groupResult.data!.title, equals('Updated Title'));
        expect(groupResult.data!.expenses.length, equals(1)); // Preserved
      });

      test('should execute complex multi-operation transaction', () async {
        // Complex transaction: save, pin, archive another, delete third
        final group3 = testGroup1.copyWith(id: 'group3', title: 'Group 3');

        await repository.saveGroup(testGroup2);
        await repository.saveGroup(group3);

        final result = await repository.executeTransaction((tx) {
          tx.saveGroup(testGroup1); // Save new group
          tx.setPinnedGroup(testGroup1.id); // Pin it
          tx.archiveGroup(testGroup2.id); // Archive another
          tx.deleteGroup(group3.id); // Delete third
        });

        expect(result.isSuccess, isTrue);

        // Verify all operations took effect
        final group1Result = await repository.getGroupById(testGroup1.id);
        final group2Result = await repository.getGroupById(testGroup2.id);
        final group3Result = await repository.getGroupById(group3.id);

        expect(group1Result.data!.pinned, isTrue);
        expect(group2Result.data!.archived, isTrue);
        expect(group3Result.data, isNull);
      });
    });

    group('Transaction Validation', () {
      test('should fail if trying to pin non-existent group', () async {
        final result = await repository.executeTransaction((tx) {
          tx.setPinnedGroup('non-existent');
        });

        expect(result.isFailure, isTrue);
        expect(result.error, isA<EntityNotFoundError>());
      });

      test('should fail if trying to pin archived group', () async {
        await repository.saveGroup(testGroup1.copyWith(archived: true));

        final result = await repository.executeTransaction((tx) {
          tx.setPinnedGroup(testGroup1.id);
        });

        expect(result.isFailure, isTrue);
        expect(result.error, isA<ValidationError>());
      });

      test('should fail if trying to delete non-existent group', () async {
        final result = await repository.executeTransaction((tx) {
          tx.deleteGroup('non-existent');
        });

        expect(result.isFailure, isTrue);
        expect(result.error, isA<EntityNotFoundError>());
      });

      test(
        'should fail if trying to update non-existent group metadata',
        () async {
          final result = await repository.executeTransaction((tx) {
            tx.updateGroupMetadata(testGroup1);
          });

          expect(result.isFailure, isTrue);
          expect(result.error, isA<EntityNotFoundError>());
        },
      );

      test('should fail if saving invalid group', () async {
        final invalidGroup = testGroup1.copyWith(title: ''); // Empty title

        final result = await repository.executeTransaction((tx) {
          tx.saveGroup(invalidGroup);
        });

        expect(result.isFailure, isTrue);
        expect(result.error, isA<ValidationError>());
      });

      test(
        'should prevent execution of already executed transaction',
        () async {
          final executor = TransactionExecutor(repository);
          final transaction = StorageTransaction();
          transaction.saveGroup(testGroup1);

          // Execute once
          final firstResult = await executor.execute(transaction);
          expect(firstResult.isSuccess, isTrue);

          // Try to execute again
          final secondResult = await executor.execute(transaction);
          expect(secondResult.isFailure, isTrue);
          expect(secondResult.error, isA<ValidationError>());
        },
      );
    });

    group('Data Integrity', () {
      test('should maintain data integrity across transaction', () async {
        // Transaction that would create multiple pinned groups
        await repository.saveGroup(testGroup1.copyWith(pinned: true));

        final result = await repository.executeTransaction((tx) {
          tx.saveGroup(
            testGroup2.copyWith(pinned: true),
          ); // Would create second pinned
        });

        // Should succeed but enforce pin constraint
        expect(result.isSuccess, isTrue);

        // Verify only one group is pinned
        final allGroups = await repository.getAllGroups();
        final pinnedGroups = allGroups.data!
            .where((g) => g.pinned && !g.archived)
            .toList();
        expect(pinnedGroups.length, equals(1));
      });

      test('should rollback on integrity violation', () async {
        // This would create a validation error during final integrity check
        final invalidGroup = testGroup1.copyWith(
          participants: [
            participant,
            ExpenseParticipant(name: '', id: 'invalid'), // Empty name
          ],
        );

        final result = await repository.executeTransaction((tx) {
          tx.saveGroup(invalidGroup);
        });

        expect(result.isFailure, isTrue);

        // Verify no partial data was saved
        final groupResult = await repository.getGroupById(testGroup1.id);
        expect(groupResult.data, isNull);
      });
    });

    group('Atomicity', () {
      test('should be all-or-nothing', () async {
        // Save one group first
        await repository.saveGroup(testGroup1);

        // Transaction that should fail on second operation
        final result = await repository.executeTransaction((tx) {
          tx.saveGroup(testGroup2); // Should succeed
          tx.deleteGroup('non-existent'); // Should fail
        });

        expect(result.isFailure, isTrue);

        // Verify no partial changes were made (group2 should not exist)
        final group2Result = await repository.getGroupById(testGroup2.id);
        expect(group2Result.data, isNull);

        // Original group should still exist
        final group1Result = await repository.getGroupById(testGroup1.id);
        expect(group1Result.data, isNotNull);
      });
    });
  });
}
