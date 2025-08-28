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
      .createTempSync('repo_v2_delete_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

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

  test('deleteGroup: removes an existing group from storage', () async {
    final p1 = ExpenseParticipant(name: 'Alice', id: 'p1');
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
      id: 'delete-me',
      title: 'ToDelete',
      currency: 'EUR',
      participants: [p1],
      categories: [c1],
      expenses: [initialExpense],
    );

    // Save initial group
    final saveResult = await ExpenseGroupStorageV2.repository.saveGroup(group);
    expect(saveResult.isSuccess, isTrue);

    // Verify it's present
    final loaded = await ExpenseGroupStorageV2.getTripById(group.id);
    expect(loaded, isNotNull);

    // Delete via V2 wrapper
    await ExpenseGroupStorageV2.deleteGroup(group.id);

    // Verify it's gone
    final after = await ExpenseGroupStorageV2.getTripById(group.id);
    expect(after, isNull);
  });
}
