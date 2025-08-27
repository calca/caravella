import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/expense_group_storage_v2.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/model/expense_details.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
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

    test('addExpenseToGroup: invalid expense (unknown category) does not modify group', () async {
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
      final saveResult = await ExpenseGroupStorageV2.repository.saveGroup(group);
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
      expect(reloaded.expenses.any((e) => e.id == invalidExpense.id), isFalse);
    });

    test('updateExpenseToGroup: invalid update (negative amount) does not persist change', () async {
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
      final saveResult = await ExpenseGroupStorageV2.repository.saveGroup(group);
      expect(saveResult.isSuccess, isTrue);

      // Prepare an updated expense with invalid amount
      final updatedExpense = initialExpense.copyWith(amount: -10.0);

      // Attempt to update
      await ExpenseGroupStorageV2.updateExpenseToGroup(group.id, updatedExpense);

      // Reload and verify the original expense amount is still present
      final reloaded = await ExpenseGroupStorageV2.getTripById(group.id);
      expect(reloaded, isNotNull);
      final fetched = reloaded!.expenses.firstWhere((e) => e.id == initialExpense.id);
      expect(fetched.amount, equals(initialExpense.amount));
    });

    test('updateExpenseToGroup: non-existent expense id does not modify group', () async {
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
      final saveResult = await ExpenseGroupStorageV2.repository.saveGroup(group);
      expect(saveResult.isSuccess, isTrue);

      // Create an update for a non-existent expense id
      final updatedExpense = initialExpense.copyWith(id: 'non-existing', amount: 100.0);

      await ExpenseGroupStorageV2.updateExpenseToGroup(group.id, updatedExpense);

      // Verify group remained unchanged
      final reloaded = await ExpenseGroupStorageV2.getTripById(group.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.expenses.length, equals(1));
      expect(reloaded.expenses.first.id, equals(initialExpense.id));
      expect(reloaded.expenses.first.amount, equals(initialExpense.amount));
    });
  });
}
