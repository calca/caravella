import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates a unique ExpenseGroup for testing.
ExpenseGroup _createGroup({
  required String id,
  String title = 'Test Group',
  bool syncEnabled = false,
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
    currency: 'EUR',
    participants: participants,
    categories: categories,
    expenses: const [],
    timestamp: DateTime.now(),
    syncEnabled: syncEnabled,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SyncDao — sync_enabled boundary', () {
    late SqliteExpenseGroupRepository repository;
    late Directory tempDir;
    late SyncDao syncDao;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync(
        'sync_dao_test_${DateTime.now().millisecondsSinceEpoch}',
      );
      repository = SqliteExpenseGroupRepository(
        databasePath: '${tempDir.path}/test.db',
      );
      // Trigger DB creation
      await repository.getAllGroups();
      final db = await repository.database;
      syncDao = SyncDao(db);
    });

    tearDown(() async {
      await repository.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test(
      'getGroupsDeltaSince only returns groups explicitly marked as shared',
      () async {
        await repository.saveGroup(
          _createGroup(id: 'shared', syncEnabled: true),
        );
        await repository.saveGroup(
          _createGroup(id: 'private', syncEnabled: false),
        );
        // Grant the peer both groups so the sync_enabled boundary is what's
        // under test here, not the per-group grant boundary (covered below).
        await syncDao.grantGroupAccess('peer-a', 'shared');
        await syncDao.grantGroupAccess('peer-a', 'private');

        final rows = await syncDao.getGroupsDeltaSince(0, 'peer-a');
        final ids = rows.map((r) => r['id'] as String).toSet();

        expect(ids, contains('shared'));
        expect(
          ids,
          isNot(contains('private')),
          reason: 'groups never marked sync_enabled must never leave the '
              'device in an outgoing delta',
        );
      },
    );

    test(
      'getDeletedGroupsSince only returns deletions of previously-shared '
      'groups',
      () async {
        await repository.saveGroup(
          _createGroup(id: 'shared-deleted', syncEnabled: true),
        );
        await repository.saveGroup(
          _createGroup(id: 'private-deleted', syncEnabled: false),
        );
        await syncDao.grantGroupAccess('peer-a', 'shared-deleted');
        await syncDao.grantGroupAccess('peer-a', 'private-deleted');

        await syncDao.softDeleteGroup('shared-deleted');
        await syncDao.softDeleteGroup('private-deleted');

        final rows = await syncDao.getDeletedGroupsSince(0, 'peer-a');
        final ids = rows.map((r) => r['id'] as String).toSet();

        expect(ids, contains('shared-deleted'));
        expect(
          ids,
          isNot(contains('private-deleted')),
          reason: 'deletion of a group that was never shared must not leak '
              'to peers either',
        );
      },
    );
  });

  group('SyncDao — per-group pairing grants', () {
    late SqliteExpenseGroupRepository repository;
    late Directory tempDir;
    late SyncDao syncDao;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync(
        'sync_dao_grants_test_${DateTime.now().millisecondsSinceEpoch}',
      );
      repository = SqliteExpenseGroupRepository(
        databasePath: '${tempDir.path}/test.db',
      );
      await repository.getAllGroups();
      final db = await repository.database;
      syncDao = SyncDao(db);
    });

    tearDown(() async {
      await repository.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test(
      'a sync-enabled group is excluded from the delta until the peer is '
      'granted access to it',
      () async {
        await repository.saveGroup(
          _createGroup(id: 'g1', syncEnabled: true),
        );

        final beforeGrant = await syncDao.getGroupsDeltaSince(0, 'peer-a');
        expect(
          beforeGrant.map((r) => r['id']),
          isNot(contains('g1')),
          reason: 'pairing alone must not imply access to every group — '
              'only an explicit grant does',
        );

        await syncDao.grantGroupAccess('peer-a', 'g1');

        final afterGrant = await syncDao.getGroupsDeltaSince(0, 'peer-a');
        expect(afterGrant.map((r) => r['id']), contains('g1'));
      },
    );

    test('a grant for one group does not leak a different group', () async {
      await repository.saveGroup(_createGroup(id: 'g1', syncEnabled: true));
      await repository.saveGroup(_createGroup(id: 'g2', syncEnabled: true));

      await syncDao.grantGroupAccess('peer-a', 'g1');

      final rows = await syncDao.getGroupsDeltaSince(0, 'peer-a');
      final ids = rows.map((r) => r['id'] as String).toSet();

      expect(ids, contains('g1'));
      expect(ids, isNot(contains('g2')));
    });

    test('isGroupGranted reflects grant/revoke state', () async {
      expect(await syncDao.isGroupGranted('peer-a', 'g1'), isFalse);

      await syncDao.grantGroupAccess('peer-a', 'g1');
      expect(await syncDao.isGroupGranted('peer-a', 'g1'), isTrue);

      await syncDao.revokeGroupAccess('peer-a', 'g1');
      expect(await syncDao.isGroupGranted('peer-a', 'g1'), isFalse);
    });

    test('getGrantedGroupIds returns every group granted to a peer', () async {
      await syncDao.grantGroupAccess('peer-a', 'g1');
      await syncDao.grantGroupAccess('peer-a', 'g2');
      await syncDao.grantGroupAccess('peer-b', 'g1');

      expect(
        await syncDao.getGrantedGroupIds('peer-a'),
        containsAll(['g1', 'g2']),
      );
      expect(await syncDao.getGrantedGroupIds('peer-b'), equals(['g1']));
    });

    test(
      'getPairedDevicesForGroup only returns devices granted that group',
      () async {
        await syncDao.addPairedDevice(
          deviceId: 'device-a',
          deviceName: 'Pixel 9',
          platform: 'android',
        );
        await syncDao.addPairedDevice(
          deviceId: 'device-b',
          deviceName: 'iPhone 16',
          platform: 'ios',
        );
        await syncDao.grantGroupAccess('device-a', 'g1');

        final devices = await syncDao.getPairedDevicesForGroup('g1');

        expect(devices, hasLength(1));
        expect(devices.first.deviceId, equals('device-a'));
      },
    );

    test(
      'removePairedDevice also revokes every group grant that device had',
      () async {
        await syncDao.addPairedDevice(
          deviceId: 'device-a',
          deviceName: 'Pixel 9',
          platform: 'android',
        );
        await syncDao.grantGroupAccess('device-a', 'g1');

        await syncDao.removePairedDevice('device-a');

        expect(await syncDao.isGroupGranted('device-a', 'g1'), isFalse);
        expect(await syncDao.getGrantedGroupIds('device-a'), isEmpty);
      },
    );
  });

  group('SyncDao — paired devices', () {
    late SqliteExpenseGroupRepository repository;
    late Directory tempDir;
    late SyncDao syncDao;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync(
        'sync_dao_paired_test_${DateTime.now().millisecondsSinceEpoch}',
      );
      repository = SqliteExpenseGroupRepository(
        databasePath: '${tempDir.path}/test.db',
      );
      await repository.getAllGroups();
      final db = await repository.database;
      syncDao = SyncDao(db);
    });

    tearDown(() async {
      await repository.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('a device is not paired until addPairedDevice is called', () async {
      expect(await syncDao.isPaired('device-a'), isFalse);
    });

    test('addPairedDevice makes isPaired return true', () async {
      await syncDao.addPairedDevice(
        deviceId: 'device-a',
        deviceName: 'Pixel 9',
        platform: 'android',
      );

      expect(await syncDao.isPaired('device-a'), isTrue);
    });

    test('getPairedDevices returns paired devices, most recent first', () async {
      await syncDao.addPairedDevice(
        deviceId: 'device-a',
        deviceName: 'Pixel 9',
        platform: 'android',
      );
      await syncDao.addPairedDevice(
        deviceId: 'device-b',
        deviceName: 'iPhone 16',
        platform: 'ios',
      );

      final devices = await syncDao.getPairedDevices();

      expect(devices, hasLength(2));
      expect(devices.first.deviceId, equals('device-b'));
      expect(devices.last.deviceId, equals('device-a'));
    });

    test('addPairedDevice persists the peer public key', () async {
      await syncDao.addPairedDevice(
        deviceId: 'device-a',
        deviceName: 'Pixel 9',
        platform: 'android',
        publicKey: 'base64-public-key',
      );

      final devices = await syncDao.getPairedDevices();
      expect(devices.single.publicKey, equals('base64-public-key'));
    });

    test('removePairedDevice revokes the pairing', () async {
      await syncDao.addPairedDevice(
        deviceId: 'device-a',
        deviceName: 'Pixel 9',
        platform: 'android',
      );

      await syncDao.removePairedDevice('device-a');

      expect(await syncDao.isPaired('device-a'), isFalse);
      expect(await syncDao.getPairedDevices(), isEmpty);
    });
  });
}
