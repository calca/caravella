import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Regression test: `ConflictResolver` must persist the `createdBy`/
/// `updatedBy` authorship snapshot on expenses received over sync, not just
/// carry them through the in-memory `ExpenseGroup.fromJson` step.
///
/// Before this was fixed, `ConflictResolver._saveGroupInTransaction` wrote a
/// hardcoded column map that didn't know about the new columns, so the
/// fields would parse correctly but be silently dropped on persistence.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('ConflictResolver — expense authorship', () {
    late SqliteExpenseGroupRepository repo;
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync(
        'conflict_resolver_authorship_${DateTime.now().millisecondsSinceEpoch}',
      );
      repo = SqliteExpenseGroupRepository(
        databasePath: '${tempDir.path}/repo.db',
      );
      await repo.getAllGroups(); // trigger DB creation
    });

    tearDown(() async {
      await repo.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test(
      'applyDelta persists createdBy/updatedBy on the incoming expense',
      () async {
        const author = ExpenseAuthor(
          deviceId: 'device-remote',
          deviceName: 'Remote Phone',
          userName: 'Luigi',
        );

        final participant = ExpenseParticipant(name: 'Alice', id: 'p0');
        final category = ExpenseCategory(name: 'Food', id: 'c0');
        final group = ExpenseGroup(
          id: 'remote-group-1',
          title: 'Remote Group',
          currency: 'EUR',
          participants: [participant],
          categories: [category],
          expenses: [
            ExpenseDetails(
              id: 'e0',
              category: category,
              amount: 42.0,
              paidBy: participant,
              date: DateTime(2026, 1, 1),
              name: 'Remote Expense',
              createdBy: author,
              updatedBy: author,
            ),
          ],
          timestamp: DateTime(2026, 1, 1),
        );

        final json = group.toJson();
        json['_sync'] = {
          'device_id': 'device-remote',
          'updated_at': SyncClock.nowMs(),
          'sync_version': 1,
          'deleted': false,
        };

        final delta = {
          'device_id': 'device-remote',
          'device_name': 'Remote Phone',
          'timestamp': SyncClock.nowMs(),
          'groups': [json],
          'deleted_groups': [],
        };

        final db = await repo.database;
        final syncDao = SyncDao(db);
        // Mirrors a completed pairing handshake having already granted
        // this peer access to the group — required by the per-group grant
        // boundary `ConflictResolver` enforces before accepting a delta.
        await syncDao.grantGroupAccess('device-remote', 'remote-group-1');
        final resolver = ConflictResolver(syncDao: syncDao);

        final result = await resolver.applyDelta(db, delta, 'lan');
        expect(result.errors, equals(0));

        final reloaded = await repo.getGroupById('remote-group-1');
        final persistedGroup = reloaded.unwrap();
        expect(persistedGroup, isNotNull);

        final persistedExpense = persistedGroup!.expenses.firstWhere(
          (e) => e.id == 'e0',
        );
        expect(persistedExpense.createdBy, equals(author));
        expect(persistedExpense.updatedBy, equals(author));
      },
    );
  });
}
