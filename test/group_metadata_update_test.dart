import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/model/expense_details.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
import 'package:org_app_caravella/data/expense_group_storage_v2.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('eg_test')
      .path;
  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();
  group('Group Metadata Update', () {
    setUp(() async {
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
    });

    test('updateGroupMetadata preserves existing expenses', () async {
      // Create a group with expenses
      // Define stable category objects with explicit ids to satisfy V2 validation
      final catFood = ExpenseCategory(name: 'food', id: 'cat-food');
      final catTransport = ExpenseCategory(
        name: 'transport',
        id: 'cat-transport',
      );

      final participant1 = ExpenseParticipant(name: 'user1', id: 'p-user1');
      final participant2 = ExpenseParticipant(name: 'user2', id: 'p-user2');

      final originalGroup = ExpenseGroup(
        id: 'test-group-1',
        title: 'Original Title',
        expenses: [
          ExpenseDetails(
            id: 'expense-1',
            name: 'Test Expense',
            amount: 100.0,
            paidBy: participant1,
            category: catFood,
            date: DateTime.now(),
          ),
          ExpenseDetails(
            id: 'expense-2',
            name: 'Another Expense',
            amount: 50.0,
            paidBy: participant2,
            category: catTransport,
            date: DateTime.now(),
          ),
        ],
        participants: [participant1, participant2],
        categories: [catFood, catTransport],
        timestamp: DateTime.now(),
        pinned: false,
        archived: false,
        currency: 'EUR',
      );

      // Save the original group
      await ExpenseGroupStorageV2.saveTrip(originalGroup);

      // Verify the group was saved correctly
      final savedGroup = await ExpenseGroupStorageV2.getTripById(
        'test-group-1',
      );
      expect(savedGroup, isNotNull);
      expect(savedGroup!.expenses.length, equals(2));
      expect(savedGroup.title, equals('Original Title'));

      // Update only the metadata (title, participants, etc.) using new API
      final updatedGroup = originalGroup.copyWith(
        title: 'Updated Title',
        // Preserve original participants (with ids) and add a new one
        participants: [
          participant1,
          participant2,
          ExpenseParticipant(
            name: 'user3',
            id: 'p-user3',
          ), // Add new participant
        ],
        // Preserve original categories (with ids) and add a new one
        categories: [
          catFood,
          catTransport,
          ExpenseCategory(
            name: 'entertainment',
            id: 'cat-ent',
          ), // Add new category
        ],
        pinned: true, // Change pin status
        // Note: we're NOT passing expenses here - they should be preserved
      );

      // Use the new updateGroupMetadata method
      await ExpenseGroupStorageV2.updateGroupMetadata(updatedGroup);

      // Retrieve the updated group
      final retrievedGroup = await ExpenseGroupStorageV2.getTripById(
        'test-group-1',
      );

      // Verify metadata was updated
      expect(retrievedGroup, isNotNull);
      expect(retrievedGroup!.title, equals('Updated Title'));
      expect(retrievedGroup.participants.length, equals(3));
      expect(retrievedGroup.participants.map((p) => p.name), contains('user3'));
      expect(retrievedGroup.categories.length, equals(3));
      expect(
        retrievedGroup.categories.map((c) => c.name),
        contains('entertainment'),
      );
      expect(retrievedGroup.pinned, isTrue);

      // Most importantly: verify expenses were preserved
      expect(retrievedGroup.expenses.length, equals(2));
      expect(retrievedGroup.expenses[0].id, equals('expense-1'));
      expect(retrievedGroup.expenses[0].name, equals('Test Expense'));
      expect(retrievedGroup.expenses[0].amount, equals(100.0));
      expect(retrievedGroup.expenses[1].id, equals('expense-2'));
      expect(retrievedGroup.expenses[1].name, equals('Another Expense'));
      expect(retrievedGroup.expenses[1].amount, equals(50.0));
    });

    test('updateGroupMetadata works with group that has no expenses', () async {
      // Create a group without expenses
      final originalGroup = ExpenseGroup(
        id: 'test-group-2',
        title: 'Empty Group',
        expenses: [], // No expenses
        participants: [ExpenseParticipant(name: 'user1', id: 'p-u1')],
        categories: [ExpenseCategory(name: 'food', id: 'cat-food-2')],
        timestamp: DateTime.now(),
        pinned: false,
        archived: false,
        currency: 'EUR',
      );

      // Save the original group
      await ExpenseGroupStorageV2.saveTrip(originalGroup);

      // Update metadata
      final updatedGroup = originalGroup.copyWith(
        title: 'Updated Empty Group',
        pinned: true,
      );

      // Use the new updateGroupMetadata method
      await ExpenseGroupStorageV2.updateGroupMetadata(updatedGroup);

      // Retrieve and verify
      final retrievedGroup = await ExpenseGroupStorageV2.getTripById(
        'test-group-2',
      );
      expect(retrievedGroup, isNotNull);
      expect(retrievedGroup!.title, equals('Updated Empty Group'));
      expect(retrievedGroup.pinned, isTrue);
      expect(retrievedGroup.expenses.length, equals(0)); // Should remain empty
    });

    test('updateGroupMetadata handles non-existent group gracefully', () async {
      // Try to update a group that doesn't exist
      final nonExistentGroup = ExpenseGroup(
        id: 'non-existent',
        title: 'Does Not Exist',
        expenses: [],
        participants: [],
        categories: [],
        timestamp: DateTime.now(),
        pinned: false,
        archived: false,
        currency: 'EUR',
      );

      // This should not throw an error
      await ExpenseGroupStorageV2.updateGroupMetadata(nonExistentGroup);

      // Verify the group still doesn't exist
      final retrievedGroup = await ExpenseGroupStorageV2.getTripById(
        'non-existent',
      );
      expect(retrievedGroup, isNull);
    });
  });
}
