import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates a unique ExpenseGroup for testing.
ExpenseGroup _createGroup({
  required String id,
  String title = 'Test Group',
  String currency = 'EUR',
  DateTime? timestamp,
  bool syncEnabled = false,
}) {
  final participants = [
    ExpenseParticipant(name: 'Alice', id: '${id}_p0'),
  ];
  final categories = [
    ExpenseCategory(name: 'Food', id: '${id}_c0'),
  ];
  final expenses = [
    ExpenseDetails(
      id: '${id}_e0',
      category: categories.first,
      amount: 25.0,
      paidBy: participants.first,
      date: DateTime.now(),
      name: 'Expense',
    ),
  ];

  return ExpenseGroup(
    id: id,
    title: title,
    currency: currency,
    participants: participants,
    categories: categories,
    expenses: expenses,
    timestamp: timestamp ?? DateTime.now(),
    syncEnabled: syncEnabled,
  );
}

/// Builds a sync delta payload map for testing.
Map<String, dynamic> _buildDelta({
  required String deviceId,
  String deviceName = 'Test Device',
  List<Map<String, dynamic>> groups = const [],
  List<Map<String, dynamic>> deletedGroups = const [],
}) {
  return {
    'device_id': deviceId,
    'device_name': deviceName,
    'timestamp': SyncClock.nowMs(),
    'groups': groups,
    'deleted_groups': deletedGroups,
  };
}

/// Converts an ExpenseGroup to a delta group entry with _sync metadata.
Map<String, dynamic> _groupToDeltaEntry(
  ExpenseGroup group, {
  required int updatedAt,
  int syncVersion = 1,
  String deviceId = 'remote-device',
}) {
  final json = group.toJson();
  json['_sync'] = {
    'device_id': deviceId,
    'updated_at': updatedAt,
    'sync_version': syncVersion,
    'deleted': false,
  };
  return json;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('ConflictResolver', () {
    late SqliteExpenseGroupRepository repository;
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync(
        'conflict_test_${DateTime.now().millisecondsSinceEpoch}',
      );
      final dbPath = '${tempDir.path}/test.db';
      repository = SqliteExpenseGroupRepository(databasePath: dbPath);
      // Trigger DB creation
      await repository.getAllGroups();
    });

    tearDown(() async {
      await repository.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('new remote group is inserted', () async {
      final db = await repository.database;
      final syncDao = SyncDao(db);
      final resolver = ConflictResolver(
        syncDao: syncDao,
        repository: repository,
      );

      final group = _createGroup(id: 'new-group');
      final delta = _buildDelta(
        deviceId: 'remote-1',
        groups: [
          _groupToDeltaEntry(group, updatedAt: SyncClock.nowMs()),
        ],
      );

      final result = await resolver.applyDelta(db, delta, 'lan');
      expect(result.applied, equals(1));
      expect(result.skipped, equals(0));
      expect(result.errors, equals(0));

      // Verify the group was saved
      final stored = await repository.getGroupById('new-group');
      expect(stored.isSuccess, isTrue);
      expect(stored.unwrap()?.title, equals('Test Group'));
    });

    test('remote newer wins over local', () async {
      // Save a local group first
      final localGroup = _createGroup(id: 'shared-id', title: 'Local Version');
      await repository.saveGroup(localGroup);

      final db = await repository.database;
      final syncDao = SyncDao(db);
      final resolver = ConflictResolver(
        syncDao: syncDao,
        repository: repository,
      );

      // Remote is newer (future timestamp)
      final remoteGroup = _createGroup(id: 'shared-id', title: 'Remote Version');
      final delta = _buildDelta(
        deviceId: 'remote-1',
        groups: [
          _groupToDeltaEntry(
            remoteGroup,
            updatedAt: SyncClock.nowMs() + 10000, // clearly in the future
          ),
        ],
      );

      final result = await resolver.applyDelta(db, delta, 'lan');
      expect(result.applied, equals(1));

      final stored = await repository.getGroupById('shared-id');
      expect(stored.unwrap()?.title, equals('Remote Version'));
    });

    test('local newer wins — remote skipped', () async {
      final localGroup = _createGroup(id: 'shared-id', title: 'Local Version');
      await repository.saveGroup(localGroup);

      final db = await repository.database;
      final syncDao = SyncDao(db);
      final resolver = ConflictResolver(
        syncDao: syncDao,
        repository: repository,
      );

      // Remote is older
      final remoteGroup = _createGroup(id: 'shared-id', title: 'Old Remote');
      final delta = _buildDelta(
        deviceId: 'remote-1',
        groups: [
          _groupToDeltaEntry(remoteGroup, updatedAt: 1000), // very old
        ],
      );

      final result = await resolver.applyDelta(db, delta, 'lan');
      expect(result.skipped, equals(1));
      expect(result.applied, equals(0));

      final stored = await repository.getGroupById('shared-id');
      expect(stored.unwrap()?.title, equals('Local Version'));
    });

    test('same timestamp — local wins (tie-break)', () async {
      final now = SyncClock.nowMs();

      // Insert local group with a known updated_at
      final localGroup = _createGroup(id: 'tie-id', title: 'Local');
      await repository.saveGroup(localGroup);
      // Manually set updated_at to our fixed value
      final db = await repository.database;
      await db.update(
        SqliteExpenseGroupRepository.tableGroups,
        {'updated_at': now},
        where: 'id = ?',
        whereArgs: ['tie-id'],
      );

      final syncDao = SyncDao(db);
      final resolver = ConflictResolver(
        syncDao: syncDao,
        repository: repository,
      );

      final remoteGroup = _createGroup(id: 'tie-id', title: 'Remote');
      final delta = _buildDelta(
        deviceId: 'remote-1',
        groups: [
          _groupToDeltaEntry(remoteGroup, updatedAt: now), // same timestamp
        ],
      );

      final result = await resolver.applyDelta(db, delta, 'lan');
      expect(result.skipped, equals(1));

      final stored = await repository.getGroupById('tie-id');
      expect(stored.unwrap()?.title, equals('Local'));
    });

    test('remote soft delete applied when remote is newer', () async {
      final localGroup = _createGroup(id: 'del-group', title: 'Will Be Deleted');
      await repository.saveGroup(localGroup);

      final db = await repository.database;
      final syncDao = SyncDao(db);
      final resolver = ConflictResolver(
        syncDao: syncDao,
        repository: repository,
      );

      final delta = _buildDelta(
        deviceId: 'remote-1',
        deletedGroups: [
          {'id': 'del-group', 'updated_at': SyncClock.nowMs() + 10000},
        ],
      );

      final result = await resolver.applyDelta(db, delta, 'lan');
      expect(result.applied, equals(1));

      // Group should be soft-deleted (not visible in normal queries)
      final stored = await repository.getGroupById('del-group');
      expect(stored.unwrap(), isNull);
    });

    test('remote soft delete of non-existent group is skipped', () async {
      final db = await repository.database;
      final syncDao = SyncDao(db);
      final resolver = ConflictResolver(
        syncDao: syncDao,
        repository: repository,
      );

      final delta = _buildDelta(
        deviceId: 'remote-1',
        deletedGroups: [
          {'id': 'never-existed', 'updated_at': SyncClock.nowMs()},
        ],
      );

      final result = await resolver.applyDelta(db, delta, 'lan');
      expect(result.skipped, equals(1));
      expect(result.applied, equals(0));
    });

    test('empty delta produces zero counters', () async {
      final db = await repository.database;
      final syncDao = SyncDao(db);
      final resolver = ConflictResolver(
        syncDao: syncDao,
        repository: repository,
      );

      final delta = _buildDelta(deviceId: 'remote-1');

      final result = await resolver.applyDelta(db, delta, 'lan');
      expect(result.applied, equals(0));
      expect(result.skipped, equals(0));
      expect(result.errors, equals(0));
    });

    test('mixed delta: new, updated, and conflicting groups', () async {
      // Pre-existing local groups
      await repository.saveGroup(
        _createGroup(id: 'existing-1', title: 'Local 1'),
      );
      await repository.saveGroup(
        _createGroup(id: 'existing-2', title: 'Local 2'),
      );

      final db = await repository.database;
      final syncDao = SyncDao(db);
      final resolver = ConflictResolver(
        syncDao: syncDao,
        repository: repository,
      );

      final futureTs = SyncClock.nowMs() + 20000;
      final delta = _buildDelta(
        deviceId: 'remote-1',
        groups: [
          // New group
          _groupToDeltaEntry(
            _createGroup(id: 'brand-new', title: 'New Remote'),
            updatedAt: futureTs,
          ),
          // Updated group (remote newer)
          _groupToDeltaEntry(
            _createGroup(id: 'existing-1', title: 'Updated Remote 1'),
            updatedAt: futureTs,
          ),
          // Conflicting group (remote older)
          _groupToDeltaEntry(
            _createGroup(id: 'existing-2', title: 'Old Remote 2'),
            updatedAt: 1000,
          ),
        ],
      );

      final result = await resolver.applyDelta(db, delta, 'lan');
      expect(result.applied, equals(2)); // new + updated
      expect(result.skipped, equals(1)); // old remote
      expect(result.errors, equals(0));
    });

    test('sync_enabled is preserved when applying a new shared group', () async {
      final db = await repository.database;
      final syncDao = SyncDao(db);
      final resolver = ConflictResolver(
        syncDao: syncDao,
        repository: repository,
      );

      final group = _createGroup(id: 'shared-new', syncEnabled: true);
      final delta = _buildDelta(
        deviceId: 'remote-1',
        groups: [
          _groupToDeltaEntry(group, updatedAt: SyncClock.nowMs()),
        ],
      );

      final result = await resolver.applyDelta(db, delta, 'lan');
      expect(result.applied, equals(1));

      final stored = await repository.getGroupById('shared-new');
      expect(stored.unwrap()?.syncEnabled, isTrue);
    });

    test(
      'sync_enabled is not reset to false when a shared group is updated '
      'by a peer',
      () async {
        // Local group already marked as shared.
        await repository.saveGroup(
          _createGroup(id: 'shared-update', title: 'Local', syncEnabled: true),
        );

        final db = await repository.database;
        final syncDao = SyncDao(db);
        final resolver = ConflictResolver(
          syncDao: syncDao,
          repository: repository,
        );

        final remoteGroup = _createGroup(
          id: 'shared-update',
          title: 'Remote Update',
          syncEnabled: true,
        );
        final delta = _buildDelta(
          deviceId: 'remote-1',
          groups: [
            _groupToDeltaEntry(
              remoteGroup,
              updatedAt: SyncClock.nowMs() + 10000,
            ),
          ],
        );

        final result = await resolver.applyDelta(db, delta, 'lan');
        expect(result.applied, equals(1));

        final stored = await repository.getGroupById('shared-update');
        expect(stored.unwrap()?.title, equals('Remote Update'));
        expect(
          stored.unwrap()?.syncEnabled,
          isTrue,
          reason:
              'sync_enabled must survive the REPLACE upsert, otherwise the '
              'group silently stops being shared after the first inbound '
              'sync',
        );
      },
    );
  });
}
