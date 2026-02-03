import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Test to verify that updateGroupMetadata properly updates participants and categories
/// in the SQLite repository.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sqflite_common_ffi for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SQLite Repository - Update Participants and Categories', () {
    late SqliteExpenseGroupRepository repository;
    late ExpenseGroup testGroup;
    late ExpenseParticipant participant1;
    late ExpenseCategory category1;

    setUp(() async {
      // Reset factory and create a new in-memory SQLite repository for each test
      ExpenseGroupRepositoryFactory.reset();
      repository = SqliteExpenseGroupRepository(inMemory: true);
      
      participant1 = ExpenseParticipant(name: 'Alice', id: 'p1');
      category1 = ExpenseCategory(name: 'Food', id: 'c1');

      testGroup = ExpenseGroup(
        id: 'test-group-1',
        title: 'Test Trip',
        expenses: [],
        participants: [participant1],
        categories: [category1],
        currency: 'EUR',
      );

      // Save initial group
      await repository.saveGroup(testGroup);
    });

    test('should add new participant when updating group metadata', () async {
      // Arrange: Create a new participant to add
      final participant2 = ExpenseParticipant(name: 'Bob', id: 'p2');
      
      // Create updated group with both participants
      final updatedGroup = testGroup.copyWith(
        participants: [participant1, participant2],
      );

      // Act: Update group metadata
      final updateResult = await repository.updateGroupMetadata(updatedGroup);
      expect(updateResult.isSuccess, isTrue);

      // Assert: Retrieve group and verify both participants are present
      final getResult = await repository.getGroupById(testGroup.id);
      expect(getResult.isSuccess, isTrue);
      expect(getResult.data!.participants.length, equals(2));
      expect(getResult.data!.participants[0].name, equals('Alice'));
      expect(getResult.data!.participants[1].name, equals('Bob'));
    });

    test('should add new category when updating group metadata', () async {
      // Arrange: Create a new category to add
      final category2 = ExpenseCategory(name: 'Transport', id: 'c2');
      
      // Create updated group with both categories
      final updatedGroup = testGroup.copyWith(
        categories: [category1, category2],
      );

      // Act: Update group metadata
      final updateResult = await repository.updateGroupMetadata(updatedGroup);
      expect(updateResult.isSuccess, isTrue);

      // Assert: Retrieve group and verify both categories are present
      final getResult = await repository.getGroupById(testGroup.id);
      expect(getResult.isSuccess, isTrue);
      expect(getResult.data!.categories.length, equals(2));
      expect(getResult.data!.categories[0].name, equals('Food'));
      expect(getResult.data!.categories[1].name, equals('Transport'));
    });

    test('should add both new participant and category together', () async {
      // Arrange: Create new participant and category
      final participant2 = ExpenseParticipant(name: 'Bob', id: 'p2');
      final category2 = ExpenseCategory(name: 'Transport', id: 'c2');
      
      // Create updated group with both new items
      final updatedGroup = testGroup.copyWith(
        participants: [participant1, participant2],
        categories: [category1, category2],
      );

      // Act: Update group metadata
      final updateResult = await repository.updateGroupMetadata(updatedGroup);
      expect(updateResult.isSuccess, isTrue);

      // Assert: Retrieve group and verify all participants and categories
      final getResult = await repository.getGroupById(testGroup.id);
      expect(getResult.isSuccess, isTrue);
      expect(getResult.data!.participants.length, equals(2));
      expect(getResult.data!.participants[0].name, equals('Alice'));
      expect(getResult.data!.participants[1].name, equals('Bob'));
      expect(getResult.data!.categories.length, equals(2));
      expect(getResult.data!.categories[0].name, equals('Food'));
      expect(getResult.data!.categories[1].name, equals('Transport'));
    });

    test('should remove participant when updating group metadata', () async {
      // Arrange: Create updated group with participant removed
      final updatedGroup = testGroup.copyWith(
        participants: [], // Remove all participants
      );

      // Act: Update group metadata
      final updateResult = await repository.updateGroupMetadata(updatedGroup);
      expect(updateResult.isSuccess, isTrue);

      // Assert: Retrieve group and verify participant is removed
      final getResult = await repository.getGroupById(testGroup.id);
      expect(getResult.isSuccess, isTrue);
      expect(getResult.data!.participants.length, equals(0));
    });

    test('should remove category when updating group metadata', () async {
      // Arrange: Create updated group with category removed
      final updatedGroup = testGroup.copyWith(
        categories: [], // Remove all categories
      );

      // Act: Update group metadata
      final updateResult = await repository.updateGroupMetadata(updatedGroup);
      expect(updateResult.isSuccess, isTrue);

      // Assert: Retrieve group and verify category is removed
      final getResult = await repository.getGroupById(testGroup.id);
      expect(getResult.isSuccess, isTrue);
      expect(getResult.data!.categories.length, equals(0));
    });

    test('should preserve expenses when updating participants/categories', () async {
      // Arrange: Add an expense to the group
      final expense = ExpenseDetails(
        id: 'e1',
        name: 'Dinner',
        amount: 50.0,
        paidBy: participant1,
        category: category1,
        date: DateTime.now(),
      );
      
      final groupWithExpense = testGroup.copyWith(expenses: [expense]);
      await repository.saveGroup(groupWithExpense);
      
      // Create updated group with new participant and category
      final participant2 = ExpenseParticipant(name: 'Bob', id: 'p2');
      final category2 = ExpenseCategory(name: 'Transport', id: 'c2');
      
      final updatedGroup = groupWithExpense.copyWith(
        participants: [participant1, participant2],
        categories: [category1, category2],
      );

      // Act: Update group metadata
      final updateResult = await repository.updateGroupMetadata(updatedGroup);
      expect(updateResult.isSuccess, isTrue);

      // Assert: Retrieve group and verify expense is preserved
      final getResult = await repository.getGroupById(testGroup.id);
      expect(getResult.isSuccess, isTrue);
      expect(getResult.data!.expenses.length, equals(1));
      expect(getResult.data!.expenses[0].name, equals('Dinner'));
      expect(getResult.data!.participants.length, equals(2));
      expect(getResult.data!.categories.length, equals(2));
    });
  });
}
