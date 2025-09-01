import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/data/expense_group_storage_v2.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_details.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('repo_v2_diff_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

// These tests are lightweight smoke tests that validate the diff-based
// reference update helpers operate without throwing and perform expected
// substitutions into in-memory repository used by the FileBased repo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();
  test('updateParticipantReferencesFromDiff replaces paidBy names', () async {
    // Create a minimal group with one expense referencing a participant
    final participant = ExpenseParticipant(id: 'p1', name: 'Alice');
    final participantUpdated = participant.copyWith(name: 'Alicia');

    final category = ExpenseCategory(id: 'c1', name: 'Cat');

    final expense = ExpenseDetails(
      id: 'e1',
      name: 'Lunch',
      amount: 10.0,
      paidBy: participant,
      category: category,
      date: DateTime.now(),
    );

    final group = ExpenseGroup(
      id: 'g-diff-test',
      title: 'G',
      participants: [participant],
      categories: [category],
      expenses: [expense],
      timestamp: DateTime.now(),
      currency: 'EUR',
    );

    // Add group
    await ExpenseGroupStorageV2.addExpenseGroup(group);

    // Apply diff update
    await ExpenseGroupStorageV2.updateParticipantReferencesFromDiff(
      group.id,
      [participant],
      [participantUpdated],
    );

    final loaded = await ExpenseGroupStorageV2.getTripById(group.id);
    expect(loaded, isNotNull);
    expect(loaded!.expenses.first.paidBy.name, equals('Alicia'));
  });

  test('updateCategoryReferencesFromDiff replaces category names', () async {
    final participant = ExpenseParticipant(id: 'p2', name: 'Bob');
    final category = ExpenseCategory(id: 'c2', name: 'OldCat');
    final categoryUpdated = category.copyWith(name: 'NewCat');

    final expense = ExpenseDetails(
      id: 'e2',
      name: 'Taxi',
      amount: 20.0,
      paidBy: participant,
      category: category,
      date: DateTime.now(),
    );

    final group = ExpenseGroup(
      id: 'g-diff-test-2',
      title: 'G2',
      participants: [participant],
      categories: [category],
      expenses: [expense],
      timestamp: DateTime.now(),
      currency: 'EUR',
    );

    await ExpenseGroupStorageV2.addExpenseGroup(group);

    await ExpenseGroupStorageV2.updateCategoryReferencesFromDiff(
      group.id,
      [category],
      [categoryUpdated],
    );

    final loaded = await ExpenseGroupStorageV2.getTripById(group.id);
    expect(loaded, isNotNull);
    expect(loaded!.expenses.first.category.name, equals('NewCat'));
  });
}
