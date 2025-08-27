import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/model/expense_details.dart';
import 'package:org_app_caravella/data/expense_group_storage_v2.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'dart:io';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('repo_test')
      .path;
  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  // Ensure Flutter bindings are initialized for file/path provider usage in storage
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ExpenseGroupStorageV2 helpers', () {
    setUp(() async {
      ExpenseGroupStorageV2.clearCache();
      ExpenseGroupStorageV2.forceReload();
      // Provide a fake path provider so storage can access a temp dir
      PathProviderPlatform.instance = _FakePathProvider();
    });

    test('pin toggling keeps single pinned group', () async {
      final g1 = ExpenseGroup(
        id: 'g1',
        title: 'Group 1',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
        currency: 'EUR',
      );
      final g2 = ExpenseGroup(
        id: 'g2',
        title: 'Group 2',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now().add(const Duration(seconds: 1)),
        currency: 'EUR',
      );

      await ExpenseGroupStorageV2.saveTrip(g1);
      await ExpenseGroupStorageV2.saveTrip(g2);

      await ExpenseGroupStorageV2.updateGroupPin('g1', true);
      var pinned = await ExpenseGroupStorageV2.getPinnedTrip();
      expect(pinned?.id, 'g1');

      // Pinning g2 should unpin g1
      await ExpenseGroupStorageV2.updateGroupPin('g2', true);
      pinned = await ExpenseGroupStorageV2.getPinnedTrip();
      expect(pinned?.id, 'g2');

      // Unpin g2
      await ExpenseGroupStorageV2.updateGroupPin('g2', false);
      pinned = await ExpenseGroupStorageV2.getPinnedTrip();
      expect(pinned, isNull);
    });

    test('archive toggles archive and unpins', () async {
      final g = ExpenseGroup(
        id: 'g-arc',
        title: 'Archivable',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
        currency: 'EUR',
      );

      await ExpenseGroupStorageV2.saveTrip(g);
      await ExpenseGroupStorageV2.updateGroupPin('g-arc', true);
      var pinned = await ExpenseGroupStorageV2.getPinnedTrip();
      expect(pinned?.id, 'g-arc');

      // Archive should unpin
      await ExpenseGroupStorageV2.updateGroupArchive('g-arc', true);
      pinned = await ExpenseGroupStorageV2.getPinnedTrip();
      expect(pinned, isNull);

      final archived = await ExpenseGroupStorageV2.getArchivedGroups();
      expect(archived.any((a) => a.id == 'g-arc'), isTrue);

      // Unarchive
      await ExpenseGroupStorageV2.updateGroupArchive('g-arc', false);
      final active = await ExpenseGroupStorageV2.getActiveGroups();
      expect(active.any((a) => a.id == 'g-arc'), isTrue);
    });

    test('removeExpenseFromGroup deletes the expense', () async {
      final category = ExpenseCategory(name: 'cat1');
      final payer = ExpenseParticipant(name: 'p1');

      final g = ExpenseGroup(
        id: 'g-exp',
        title: 'HasExpense',
        participants: [payer],
        categories: [category],
        expenses: [],
        timestamp: DateTime.now(),
        currency: 'EUR',
      );

      await ExpenseGroupStorageV2.saveTrip(g);

      final e = ExpenseDetails(
        category: category,
        amount: 10.0,
        paidBy: payer,
        date: DateTime.now(),
        name: 'T1',
        id: 'e1',
      );

      await ExpenseGroupStorageV2.addExpenseToGroup('g-exp', e);
      var reloaded = await ExpenseGroupStorageV2.getTripById('g-exp');
      expect(reloaded?.expenses.any((ex) => ex.id == 'e1'), isTrue);

      await ExpenseGroupStorageV2.removeExpenseFromGroup('g-exp', 'e1');
      reloaded = await ExpenseGroupStorageV2.getTripById('g-exp');
      expect(reloaded?.expenses.any((ex) => ex.id == 'e1'), isFalse);
    });
  });
}
