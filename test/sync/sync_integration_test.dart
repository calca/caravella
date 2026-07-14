import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates a unique ExpenseGroup for testing.
ExpenseGroup _createGroup({
  required String id,
  String title = 'Group',
  String currency = 'EUR',
}) {
  final participants = [
    ExpenseParticipant(name: 'Alice', id: '${id}_p0'),
  ];
  final categories = [
    ExpenseCategory(name: 'Food', id: '${id}_c0'),
  ];
  return ExpenseGroup(
    id: id,
    title: title,
    currency: currency,
    participants: participants,
    categories: categories,
    expenses: [
      ExpenseDetails(
        id: '${id}_e0',
        category: categories.first,
        amount: 10.0,
        paidBy: participants.first,
        date: DateTime.now(),
        name: 'Expense',
      ),
    ],
    timestamp: DateTime.now(),
  );
}

/// Builds a delta payload from a list of groups and deleted group entries.
Map<String, dynamic> _buildDelta({
  required String deviceId,
  String deviceName = 'Test',
  required List<Map<String, dynamic>> groupEntries,
  List<Map<String, dynamic>> deletedGroups = const [],
}) {
  return {
    'device_id': deviceId,
    'device_name': deviceName,
    'timestamp': SyncClock.nowMs(),
    'groups': groupEntries,
    'deleted_groups': deletedGroups,
  };
}

Map<String, dynamic> _groupEntry(
  ExpenseGroup group, {
  required int updatedAt,
  String deviceId = 'device',
}) {
  final json = group.toJson();
  json['_sync'] = {
    'device_id': deviceId,
    'updated_at': updatedAt,
    'sync_version': 1,
    'deleted': false,
  };
  return json;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Sync Integration — bidirectional exchange', () {
    late SqliteExpenseGroupRepository repoA;
    late SqliteExpenseGroupRepository repoB;
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync(
        'sync_integ_${DateTime.now().millisecondsSinceEpoch}',
      );
      repoA = SqliteExpenseGroupRepository(
        databasePath: '${tempDir.path}/a.db',
      );
      repoB = SqliteExpenseGroupRepository(
        databasePath: '${tempDir.path}/b.db',
      );
      // Trigger DB creation on both
      await repoA.getAllGroups();
      await repoB.getAllGroups();
    });

    tearDown(() async {
      await repoA.close();
      await repoB.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('two devices converge after bidirectional sync', () async {
      final now = SyncClock.nowMs();

      // Device A: 5 unique groups
      for (var i = 0; i < 5; i++) {
        await repoA.saveGroup(_createGroup(id: 'a-only-$i', title: 'A-$i'));
      }

      // Device B: 3 unique groups
      for (var i = 0; i < 3; i++) {
        await repoB.saveGroup(_createGroup(id: 'b-only-$i', title: 'B-$i'));
      }

      // Both devices have a shared group — B's version is newer
      await repoA.saveGroup(
        _createGroup(id: 'shared-1', title: 'Shared-A'),
      );
      await repoB.saveGroup(
        _createGroup(id: 'shared-1', title: 'Shared-B'),
      );

      // Set B's version to be newer
      final dbB = await repoB.database;
      await dbB.update(
        SqliteExpenseGroupRepository.tableGroups,
        {'updated_at': now + 50000},
        where: 'id = ?',
        whereArgs: ['shared-1'],
      );

      // --- Sync A → B ---
      final dbA = await repoA.database;
      // Read A's groups as delta entries
      final aGroups = await dbA.query(
        SqliteExpenseGroupRepository.tableGroups,
        where: 'deleted = 0',
      );
      final aEntries = <Map<String, dynamic>>[];
      for (final row in aGroups) {
        final groupResult = await repoA.getGroupById(row['id'] as String);
        final group = groupResult.unwrap();
        if (group != null) {
          aEntries.add(_groupEntry(
            group,
            updatedAt: row['updated_at'] as int? ?? 0,
            deviceId: 'device-A',
          ));
        }
      }

      final deltaAtoB = _buildDelta(
        deviceId: 'device-A',
        deviceName: 'Device A',
        groupEntries: aEntries,
      );

      final syncDaoB = SyncDao(dbB);
      final resolverB = ConflictResolver(
        syncDao: syncDaoB,
      );
      final resultAtoB = await resolverB.applyDelta(dbB, deltaAtoB, 'lan');
      expect(resultAtoB.errors, equals(0));

      // --- Sync B → A ---
      final bGroups = await dbB.query(
        SqliteExpenseGroupRepository.tableGroups,
        where: 'deleted = 0',
      );
      final bEntries = <Map<String, dynamic>>[];
      for (final row in bGroups) {
        final groupResult = await repoB.getGroupById(row['id'] as String);
        final group = groupResult.unwrap();
        if (group != null) {
          bEntries.add(_groupEntry(
            group,
            updatedAt: row['updated_at'] as int? ?? 0,
            deviceId: 'device-B',
          ));
        }
      }

      final deltaBtoA = _buildDelta(
        deviceId: 'device-B',
        deviceName: 'Device B',
        groupEntries: bEntries,
      );

      final syncDaoA = SyncDao(dbA);
      final resolverA = ConflictResolver(
        syncDao: syncDaoA,
      );
      final resultBtoA = await resolverA.applyDelta(dbA, deltaBtoA, 'lan');
      expect(resultBtoA.errors, equals(0));

      // --- Verify convergence ---
      final finalA = await repoA.getAllGroups();
      final finalB = await repoB.getAllGroups();
      final groupsA = finalA.unwrap();
      final groupsB = finalB.unwrap();

      // 5 (A-only) + 3 (B-only) + 1 (shared) = 9
      expect(groupsA.length, equals(9));
      expect(groupsB.length, equals(9));

      // Shared group should have B's version (newer)
      final sharedA = groupsA.firstWhere((g) => g.id == 'shared-1');
      final sharedB = groupsB.firstWhere((g) => g.id == 'shared-1');
      expect(sharedA.title, equals('Shared-B'));
      expect(sharedB.title, equals('Shared-B'));

      // Both repos should have the same set of group IDs
      final idsA = groupsA.map((g) => g.id).toSet();
      final idsB = groupsB.map((g) => g.id).toSet();
      expect(idsA, equals(idsB));
    });
  });
}
