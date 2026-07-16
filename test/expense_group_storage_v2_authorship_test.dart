import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('repo_v2_authorship_test')
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

  group('ExpenseGroupStorageV2 - expense authorship stamping', () {
    const storageFileName = 'expense_group_storage.json';

    setUp(() async {
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
      'addExpenseToGroup stamps createdBy and updatedBy identically',
      () async {
        final p1 = ExpenseParticipant(name: 'Alice', id: 'p1');
        final c1 = ExpenseCategory(name: 'Food', id: 'c1');

        final group = ExpenseGroup(
          id: 'g-authorship-1',
          title: 'G1',
          currency: 'USD',
          participants: [p1],
          categories: [c1],
          expenses: const [],
        );
        await ExpenseGroupStorageV2.addExpenseGroup(group);

        final newExpense = ExpenseDetails(
          id: 'e1',
          category: c1,
          amount: 20.0,
          paidBy: p1,
          date: DateTime.now(),
          name: 'New expense',
        );
        await ExpenseGroupStorageV2.addExpenseToGroup(group.id, newExpense);

        final reloaded = await ExpenseGroupStorageV2.getTripById(group.id);
        final stored = reloaded!.expenses.firstWhere((e) => e.id == 'e1');

        expect(stored.createdBy, isNotNull);
        expect(stored.updatedBy, isNotNull);
        expect(stored.createdBy, equals(stored.updatedBy));
      },
    );

    test(
      'updateExpenseToGroup preserves the original createdBy and only '
      're-stamps updatedBy, even when the incoming expense carries no '
      'authorship at all',
      () async {
        final p1 = ExpenseParticipant(name: 'Alice', id: 'p1');
        final c1 = ExpenseCategory(name: 'Food', id: 'c1');

        final group = ExpenseGroup(
          id: 'g-authorship-2',
          title: 'G2',
          currency: 'USD',
          participants: [p1],
          categories: [c1],
          expenses: const [],
        );
        await ExpenseGroupStorageV2.addExpenseGroup(group);

        final newExpense = ExpenseDetails(
          id: 'e1',
          category: c1,
          amount: 20.0,
          paidBy: p1,
          date: DateTime.now(),
          name: 'New expense',
        );
        await ExpenseGroupStorageV2.addExpenseToGroup(group.id, newExpense);

        final afterAdd = await ExpenseGroupStorageV2.getTripById(group.id);
        final createdByAfterAdd = afterAdd!.expenses
            .firstWhere((e) => e.id == 'e1')
            .createdBy;
        expect(createdByAfterAdd, isNotNull);

        // Simulate a form producing a fresh ExpenseDetails with no
        // createdBy/updatedBy at all (the normal case — forms never set
        // these fields directly).
        final editedExpense = ExpenseDetails(
          id: 'e1',
          category: c1,
          amount: 25.0,
          paidBy: p1,
          date: newExpense.date,
          name: 'Edited expense',
        );
        expect(editedExpense.createdBy, isNull);

        await ExpenseGroupStorageV2.updateExpenseToGroup(
          group.id,
          editedExpense,
        );

        final afterEdit = await ExpenseGroupStorageV2.getTripById(group.id);
        final stored = afterEdit!.expenses.firstWhere((e) => e.id == 'e1');

        expect(stored.amount, equals(25.0));
        expect(stored.createdBy, equals(createdByAfterAdd));
        expect(stored.updatedBy, isNotNull);
      },
    );
  });
}
