import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('repo_v2_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  setUpAll(() {
    // Force use of JSON backend for all tests
    ExpenseGroupRepositoryFactory.reset();
    ExpenseGroupRepositoryFactory.getRepository(useJsonBackend: true);
  });

  group('ExpenseGroupStorageV2 - add/update expense', () {
    const storageFileName = 'expense_group_storage.json';

    setUp(() async {
      // Ensure clean state on disk and cache
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$storageFileName');
        if (await file.exists()) await file.delete();
      } catch (e) {
        // ignore
      }
      ExpenseGroupStorageV2.clearCache();
      ExpenseGroupStorageV2.forceReload();
    });

    test(
      'addExpenseToGroup: invalid expense (unknown category) does not modify group',
      () async {
        final p1 = ExpenseParticipant(name: 'Alice', id: 'p1');
        final p2 = ExpenseParticipant(name: 'Bob', id: 'p2');
        final c1 = ExpenseCategory(name: 'Food', id: 'c1');

        final initialExpense = ExpenseDetails(
          id: 'e1',
          category: c1,
          amount: 20.0,
          paidBy: p1,
          date: DateTime.now(),
          name: 'Initial',
        );

        final group = ExpenseGroup(
          id: 'g1',
          title: 'G1',
          currency: 'USD',
          participants: [p1, p2],
          categories: [c1],
          expenses: [initialExpense],
        );

        // Save initial group
        final saveResult = await ExpenseGroupStorageV2.repository.saveGroup(
          group,
        );
        expect(saveResult.isSuccess, isTrue);

        // Prepare an expense that refers to a category not present in the group
        final unknownCategory = ExpenseCategory(name: 'Travel', id: 'c-non');
        final invalidExpense = ExpenseDetails(
          id: 'e-invalid',
          category: unknownCategory,
          amount: 10.0,
          paidBy: p1,
          date: DateTime.now(),
        );

        // Attempt to add - V2 wrapper swallows errors and prints warnings
        await ExpenseGroupStorageV2.addExpenseToGroup(group.id, invalidExpense);

        // Reload and verify the group was not modified (no invalid expense added)
        final reloaded = await ExpenseGroupStorageV2.getTripById(group.id);
        expect(reloaded, isNotNull);
        expect(reloaded!.expenses.length, equals(1));
        expect(
          reloaded.expenses.any((e) => e.id == invalidExpense.id),
          isFalse,
        );
      },
    );

    test(
      'updateExpenseToGroup: invalid update (negative amount) does not persist change',
      () async {
        final p1 = ExpenseParticipant(name: 'Alice', id: 'p1');
        final p2 = ExpenseParticipant(name: 'Bob', id: 'p2');
        final c1 = ExpenseCategory(name: 'Food', id: 'c1');

        final initialExpense = ExpenseDetails(
          id: 'e1',
          category: c1,
          amount: 50.0,
          paidBy: p2,
          date: DateTime.now(),
          name: 'Dinner',
        );

        final group = ExpenseGroup(
          id: 'g2',
          title: 'G2',
          currency: 'EUR',
          participants: [p1, p2],
          categories: [c1],
          expenses: [initialExpense],
        );

        // Save initial group
        final saveResult = await ExpenseGroupStorageV2.repository.saveGroup(
          group,
        );
        expect(saveResult.isSuccess, isTrue);

        // Prepare an updated expense with invalid amount
        final updatedExpense = initialExpense.copyWith(amount: -10.0);

        // Attempt to update
        await ExpenseGroupStorageV2.updateExpenseToGroup(
          group.id,
          updatedExpense,
        );

        // Reload and verify the original expense amount is still present
        final reloaded = await ExpenseGroupStorageV2.getTripById(group.id);
        expect(reloaded, isNotNull);
        final fetched = reloaded!.expenses.firstWhere(
          (e) => e.id == initialExpense.id,
        );
        expect(fetched.amount, equals(initialExpense.amount));
      },
    );

    test(
      'updateExpenseToGroup: non-existent expense id does not modify group',
      () async {
        final p1 = ExpenseParticipant(name: 'Alice', id: 'p1');
        final c1 = ExpenseCategory(name: 'Food', id: 'c1');

        final initialExpense = ExpenseDetails(
          id: 'e1',
          category: c1,
          amount: 30.0,
          paidBy: p1,
          date: DateTime.now(),
        );

        final group = ExpenseGroup(
          id: 'g3',
          title: 'G3',
          currency: 'EUR',
          participants: [p1],
          categories: [c1],
          expenses: [initialExpense],
        );

        // Save initial group
        final saveResult = await ExpenseGroupStorageV2.repository.saveGroup(
          group,
        );
        expect(saveResult.isSuccess, isTrue);

        // Create an update for a non-existent expense id
        final updatedExpense = initialExpense.copyWith(
          id: 'non-existing',
          amount: 100.0,
        );

        await ExpenseGroupStorageV2.updateExpenseToGroup(
          group.id,
          updatedExpense,
        );

        // Verify group remained unchanged
        final reloaded = await ExpenseGroupStorageV2.getTripById(group.id);
        expect(reloaded, isNotNull);
        expect(reloaded!.expenses.length, equals(1));
        expect(reloaded.expenses.first.id, equals(initialExpense.id));
        expect(reloaded.expenses.first.amount, equals(initialExpense.amount));
      },
    );
  });

  group('ExpenseGroupStorageV2 - getRecentExpenses', () {
    const storageFileName = 'expense_group_storage.json';

    setUp(() async {
      // Ensure clean state on disk and cache
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$storageFileName');
        if (await file.exists()) await file.delete();
      } catch (e) {
        // ignore
      }
      ExpenseGroupStorageV2.clearCache();
      ExpenseGroupStorageV2.forceReload();
    });

    test('getRecentExpenses: returns empty list for non-existent group',
        () async {
      final recentExpenses = await ExpenseGroupStorageV2.getRecentExpenses(
        'non-existent-id',
      );
      expect(recentExpenses, isEmpty);
    });

    test('getRecentExpenses: returns empty list for group with no expenses',
        () async {
      final p1 = ExpenseParticipant(name: 'Alice', id: 'p1');
      final c1 = ExpenseCategory(name: 'Food', id: 'c1');

      final group = ExpenseGroup(
        id: 'g1',
        title: 'Empty Group',
        currency: 'USD',
        participants: [p1],
        categories: [c1],
        expenses: [],
      );

      await ExpenseGroupStorageV2.addExpenseGroup(group);

      final recentExpenses = await ExpenseGroupStorageV2.getRecentExpenses(
        group.id,
      );
      expect(recentExpenses, isEmpty);
    });

    test('getRecentExpenses: returns expenses sorted by date (newest first)',
        () async {
      final p1 = ExpenseParticipant(name: 'Alice', id: 'p1');
      final c1 = ExpenseCategory(name: 'Food', id: 'c1');

      final oldDate = DateTime(2024, 1, 1);
      final middleDate = DateTime(2024, 1, 15);
      final newDate = DateTime(2024, 2, 1);

      final expense1 = ExpenseDetails(
        id: 'e1',
        category: c1,
        amount: 10.0,
        paidBy: p1,
        date: middleDate,
        name: 'Middle',
      );

      final expense2 = ExpenseDetails(
        id: 'e2',
        category: c1,
        amount: 20.0,
        paidBy: p1,
        date: oldDate,
        name: 'Oldest',
      );

      final expense3 = ExpenseDetails(
        id: 'e3',
        category: c1,
        amount: 30.0,
        paidBy: p1,
        date: newDate,
        name: 'Newest',
      );

      final group = ExpenseGroup(
        id: 'g1',
        title: 'Test Group',
        currency: 'USD',
        participants: [p1],
        categories: [c1],
        expenses: [expense1, expense2, expense3],
      );

      await ExpenseGroupStorageV2.addExpenseGroup(group);

      final recentExpenses = await ExpenseGroupStorageV2.getRecentExpenses(
        group.id,
        limit: 2,
      );

      expect(recentExpenses.length, equals(2));
      expect(recentExpenses[0].id, equals('e3')); // Newest first
      expect(recentExpenses[1].id, equals('e1')); // Middle second
    });

    test('getRecentExpenses: respects limit parameter', () async {
      final p1 = ExpenseParticipant(name: 'Alice', id: 'p1');
      final c1 = ExpenseCategory(name: 'Food', id: 'c1');

      // Create 5 expenses
      final expenses = List.generate(5, (i) {
        return ExpenseDetails(
          id: 'e$i',
          category: c1,
          amount: (i + 1) * 10.0,
          paidBy: p1,
          date: DateTime(2024, 1, i + 1),
          name: 'Expense $i',
        );
      });

      final group = ExpenseGroup(
        id: 'g1',
        title: 'Test Group',
        currency: 'USD',
        participants: [p1],
        categories: [c1],
        expenses: expenses,
      );

      await ExpenseGroupStorageV2.addExpenseGroup(group);

      // Test with different limits
      final recent2 = await ExpenseGroupStorageV2.getRecentExpenses(
        group.id,
        limit: 2,
      );
      expect(recent2.length, equals(2));

      final recent3 = await ExpenseGroupStorageV2.getRecentExpenses(
        group.id,
        limit: 3,
      );
      expect(recent3.length, equals(3));

      final recent10 = await ExpenseGroupStorageV2.getRecentExpenses(
        group.id,
        limit: 10,
      );
      expect(recent10.length, equals(5)); // Should return all 5 expenses
    });
  });
}
