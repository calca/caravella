import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:io_caravella_egm/data/hive_expense_group_repository.dart';
import 'package:io_caravella_egm/data/services/hive_initialization_service.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';
import 'package:io_caravella_egm/data/model/expense_details.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HiveExpenseGroupRepository', () {
    late HiveExpenseGroupRepository repository;
    late ExpenseGroup testGroup;
    late ExpenseParticipant participant1;
    late ExpenseParticipant participant2;
    late ExpenseCategory category;
    late Directory tempDir;

    setUp(() async {
      // Create temporary directory for Hive
      tempDir = Directory.systemTemp.createTempSync('hive_test');
      
      // Initialize Hive with temporary path
      Hive.init(tempDir.path);
      await HiveInitializationService.initialize();
      
      repository = HiveExpenseGroupRepository();

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

    tearDown(() async {
      // Close repository and clean up
      await repository.close();
      await HiveInitializationService.closeAll();
      
      // Clean up temporary directory
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
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

        // Retrieve and verify
        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.title, equals('Updated Title'));
      });

      test('should delete a group', () async {
        // Save group
        await repository.saveGroup(testGroup);

        // Delete group
        final deleteResult = await repository.deleteGroup(testGroup.id);
        expect(deleteResult.isSuccess, isTrue);

        // Verify deletion
        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data, isNull);
      });
    });

    group('Group Listing', () {
      test('should list all groups', () async {
        final group1 = testGroup;
        final group2 = testGroup.copyWith(id: 'test-group-2', title: 'Group 2');

        await repository.saveGroup(group1);
        await repository.saveGroup(group2);

        final result = await repository.getAllGroups();
        expect(result.isSuccess, isTrue);
        expect(result.data!.length, equals(2));
      });

      test('should list active groups only', () async {
        final activeGroup = testGroup;
        final archivedGroup = testGroup.copyWith(
          id: 'test-group-2',
          archived: true,
        );

        await repository.saveGroup(activeGroup);
        await repository.saveGroup(archivedGroup);

        final result = await repository.getActiveGroups();
        expect(result.isSuccess, isTrue);
        expect(result.data!.length, equals(1));
        expect(result.data!.first.archived, isFalse);
      });

      test('should list archived groups only', () async {
        final activeGroup = testGroup;
        final archivedGroup = testGroup.copyWith(
          id: 'test-group-2',
          archived: true,
        );

        await repository.saveGroup(activeGroup);
        await repository.saveGroup(archivedGroup);

        final result = await repository.getArchivedGroups();
        expect(result.isSuccess, isTrue);
        expect(result.data!.length, equals(1));
        expect(result.data!.first.archived, isTrue);
      });
    });

    group('Pin Management', () {
      test('should pin a group', () async {
        await repository.saveGroup(testGroup);

        final result = await repository.setPinnedGroup(testGroup.id);
        expect(result.isSuccess, isTrue);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.pinned, isTrue);
      });

      test('should unpin other groups when pinning a new one', () async {
        final group1 = testGroup.copyWith(pinned: true);
        final group2 = testGroup.copyWith(id: 'test-group-2');

        await repository.saveGroup(group1);
        await repository.saveGroup(group2);

        await repository.setPinnedGroup('test-group-2');

        final result1 = await repository.getGroupById(testGroup.id);
        final result2 = await repository.getGroupById('test-group-2');

        expect(result1.data!.pinned, isFalse);
        expect(result2.data!.pinned, isTrue);
      });

      test('should not allow pinning archived groups', () async {
        final archivedGroup = testGroup.copyWith(archived: true);
        await repository.saveGroup(archivedGroup);

        final result = await repository.setPinnedGroup(testGroup.id);
        expect(result.isFailure, isTrue);
      });

      test('should remove pin from a group', () async {
        final pinnedGroup = testGroup.copyWith(pinned: true);
        await repository.saveGroup(pinnedGroup);

        final result = await repository.removePinnedGroup(testGroup.id);
        expect(result.isSuccess, isTrue);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.pinned, isFalse);
      });

      test('should get pinned group', () async {
        final pinnedGroup = testGroup.copyWith(pinned: true);
        await repository.saveGroup(pinnedGroup);

        final result = await repository.getPinnedGroup();
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.id, equals(testGroup.id));
      });
    });

    group('Archive Management', () {
      test('should archive a group', () async {
        await repository.saveGroup(testGroup);

        final result = await repository.archiveGroup(testGroup.id);
        expect(result.isSuccess, isTrue);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.archived, isTrue);
        expect(getResult.data!.pinned, isFalse);
      });

      test('should unarchive a group', () async {
        final archivedGroup = testGroup.copyWith(archived: true);
        await repository.saveGroup(archivedGroup);

        final result = await repository.unarchiveGroup(testGroup.id);
        expect(result.isSuccess, isTrue);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.archived, isFalse);
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

        final result = await repository.getExpenseById(testGroup.id, 'non-existent');
        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });
    });

    group('Validation', () {
      test('should validate valid group', () {
        final result = repository.validateGroup(testGroup);
        expect(result.isSuccess, isTrue);
      });

      test('should reject group with empty title', () {
        final invalidGroup = testGroup.copyWith(title: '');
        final result = repository.validateGroup(invalidGroup);
        expect(result.isFailure, isTrue);
      });

      test('should reject group with empty currency', () {
        final invalidGroup = testGroup.copyWith(currency: '');
        final result = repository.validateGroup(invalidGroup);
        expect(result.isFailure, isTrue);
      });
    });

    group('Data Integrity', () {
      test('should check data integrity successfully', () async {
        await repository.saveGroup(testGroup);

        final result = await repository.checkDataIntegrity();
        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
      });

      test('should detect multiple pinned groups', () async {
        final group1 = testGroup.copyWith(pinned: true);
        final group2 = testGroup.copyWith(id: 'test-group-2', pinned: true);

        await repository.saveGroup(group1);
        await repository.saveGroup(group2);

        final result = await repository.checkDataIntegrity();
        expect(result.isFailure, isTrue);
      });
    });

    group('Metadata Update', () {
      test('should update metadata while preserving expenses', () async {
        await repository.saveGroup(testGroup);

        final updatedGroup = testGroup.copyWith(
          title: 'New Title',
          expenses: [], // Should be ignored
        );

        final result = await repository.updateGroupMetadata(updatedGroup);
        expect(result.isSuccess, isTrue);

        final getResult = await repository.getGroupById(testGroup.id);
        expect(getResult.data!.title, equals('New Title'));
        expect(getResult.data!.expenses.length, equals(1)); // Original expenses preserved
      });
    });

    group('Cache Operations', () {
      test('should clear cache', () async {
        await repository.saveGroup(testGroup);
        repository.clearCache();
        
        // Verify data is still accessible after cache clear
        final result = await repository.getGroupById(testGroup.id);
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
      });

      test('should force reload', () async {
        await repository.saveGroup(testGroup);
        repository.forceReload();
        
        // Verify data is still accessible after force reload
        final result = await repository.getGroupById(testGroup.id);
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
      });
    });
  });
}
