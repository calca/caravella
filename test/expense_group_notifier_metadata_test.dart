import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/state/expense_group_notifier.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/model/expense_details.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
import 'package:org_app_caravella/data/expense_group_storage.dart';
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
  // Inject fake path provider to avoid platform channel dependency
  PathProviderPlatform.instance = _FakePathProvider();
  group('ExpenseGroupNotifier Metadata Update', () {
    late ExpenseGroupNotifier notifier;

    setUp(() async {
      notifier = ExpenseGroupNotifier();

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

    test('updateGroupMetadata preserves current group expenses', () async {
      // Create a group with expenses
      final originalGroup = ExpenseGroup(
        id: 'test-group-1',
        title: 'Original Title',
        expenses: [
          ExpenseDetails(
            id: 'expense-1',
            name: 'Test Expense',
            amount: 100.0,
            paidBy: ExpenseParticipant(name: 'user1'),
            category: ExpenseCategory(name: 'food'),
            date: DateTime.now(),
          ),
        ],
        participants: [
          ExpenseParticipant(name: 'user1'),
          ExpenseParticipant(name: 'user2'),
        ],
        categories: [ExpenseCategory(name: 'food')],
        timestamp: DateTime.now(),
        pinned: false,
        archived: false,
        currency: 'EUR',
      );

      // Save and set as current group
      await ExpenseGroupStorage.saveTrip(originalGroup);
      notifier.setCurrentGroup(originalGroup);

      // Create an updated group without expenses
      final updatedGroup = originalGroup.copyWith(
        title: 'Updated Title',
        pinned: true,
        // Note: not specifying expenses - they should be preserved
      );

      // Update using the new metadata method
      await notifier.updateGroupMetadata(updatedGroup);

      // Verify current group state
      expect(notifier.currentGroup, isNotNull);
      expect(notifier.currentGroup!.title, equals('Updated Title'));
      expect(notifier.currentGroup!.pinned, isTrue);
      expect(
        notifier.currentGroup!.expenses.length,
        equals(1),
      ); // Expenses preserved
      expect(notifier.currentGroup!.expenses[0].name, equals('Test Expense'));

      // Verify persistence
      final savedGroup = await ExpenseGroupStorage.getTripById('test-group-1');
      expect(savedGroup, isNotNull);
      expect(savedGroup!.title, equals('Updated Title'));
      expect(savedGroup.pinned, isTrue);
      expect(
        savedGroup.expenses.length,
        equals(1),
      ); // Expenses preserved in storage
    });

    test('updateGroupMetadata updates tracking lists correctly', () async {
      final group = ExpenseGroup(
        id: 'test-group-2',
        title: 'Test Group',
        expenses: [],
        participants: [],
        categories: [],
        timestamp: DateTime.now(),
        pinned: false,
        archived: false,
        currency: 'EUR',
      );

      await ExpenseGroupStorage.saveTrip(group);
      notifier.setCurrentGroup(group);

      // Verify initial state
      expect(notifier.updatedGroupIds, isEmpty);

      // Update metadata
      final updatedGroup = group.copyWith(title: 'Updated Test Group');
      await notifier.updateGroupMetadata(updatedGroup);

      // Verify tracking
      expect(notifier.updatedGroupIds, contains('test-group-2'));
    });

    test('updateGroupMetadata handles group not in current state', () async {
      // Create and save a group
      final group = ExpenseGroup(
        id: 'test-group-3',
        title: 'Remote Group',
        expenses: [
          ExpenseDetails(
            id: 'expense-1',
            name: 'Remote Expense',
            amount: 200.0,
            paidBy: ExpenseParticipant(name: 'user1'),
            category: ExpenseCategory(name: 'food'),
            date: DateTime.now(),
          ),
        ],
        participants: [ExpenseParticipant(name: 'user1')],
        categories: [ExpenseCategory(name: 'food')],
        timestamp: DateTime.now(),
        pinned: false,
        archived: false,
        currency: 'EUR',
      );

      await ExpenseGroupStorage.saveTrip(group);
      // Note: NOT setting as current group

      // Update a different group that's not currently loaded
      final updatedGroup = group.copyWith(title: 'Updated Remote Group');
      await notifier.updateGroupMetadata(updatedGroup);

      // Verify persistence worked (expenses should be preserved)
      final savedGroup = await ExpenseGroupStorage.getTripById('test-group-3');
      expect(savedGroup, isNotNull);
      expect(savedGroup!.title, equals('Updated Remote Group'));
      expect(savedGroup.expenses.length, equals(1)); // Expenses preserved
      expect(savedGroup.expenses[0].name, equals('Remote Expense'));

      // Verify tracking
      expect(notifier.updatedGroupIds, contains('test-group-3'));
    });
  });
}
