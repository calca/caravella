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

        final rows = await syncDao.getGroupsDeltaSince(0);
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

        await syncDao.softDeleteGroup('shared-deleted');
        await syncDao.softDeleteGroup('private-deleted');

        final rows = await syncDao.getDeletedGroupsSince(0);
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
