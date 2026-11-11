import 'dart:convert';
import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// The account's `appDataFolder`, in memory: one shard per device.
class _FakeDrive extends CloudRelayChannel {
  final Map<String, String> files = {};
  bool signedIn = true;
  CloudSyncCycle? cycle;

  @override
  String get channelName => 'cloud';

  @override
  Future<void> uploadShard(String deviceId, String jsonPayload) async {
    if (!signedIn) throw const CloudNotSignedInException();
    files[deviceId] = jsonPayload;
  }

  @override
  Future<List<String>> downloadAllShards() async {
    if (!signedIn) throw const CloudNotSignedInException();
    return files.values.toList();
  }

  @override
  Future<void> start({required CloudSyncCycle cycle}) async =>
      this.cycle = cycle;

  @override
  Future<void> stop() async => cycle = null;
}

ExpenseGroup _group(String id, {String title = 'Group'}) {
  final anna = ExpenseParticipant(name: 'Anna', id: '${id}_p');
  final food = ExpenseCategory(name: 'Food', id: '${id}_c');
  return ExpenseGroup(
    id: id,
    title: title,
    currency: '€',
    participants: [anna],
    categories: [food],
    expenses: [
      ExpenseDetails(
        id: '${id}_e',
        name: 'Dinner',
        category: food,
        amount: 30,
        paidBy: anna,
        date: DateTime(2026, 11, 1),
      ),
    ],
    timestamp: DateTime(2026, 11, 1),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late SqliteExpenseGroupRepository phoneA;
  late SqliteExpenseGroupRepository phoneB;
  late SyncManager managerB;
  late _FakeDrive drive;
  late SyncOrchestrator orchestrator;

  /// Phone B's snapshot, as it would upload it.
  Future<void> uploadFromB() async {
    final snapshot = await managerB.getCloudSnapshot();
    snapshot['device_id'] = 'phone-b';
    snapshot['device_name'] = 'Pixel 9';
    drive.files['phone-b'] = jsonEncode(snapshot);
  }

  /// Phone A's shard, applied on phone B.
  Future<SyncResult> downloadOnB() => managerB.syncWithPeer(
    'phone-a',
    jsonDecode(drive.files['phone-a']!) as Map<String, dynamic>,
    'cloud',
    checkGrants: false,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({'sync_device_id': 'phone-a'});
    DeviceIdentity.reset();
    await DeviceIdentity.initialize();
    tempDir = Directory.systemTemp.createTempSync(
      'cloud_sync_${DateTime.now().microsecondsSinceEpoch}',
    );
    phoneA = SqliteExpenseGroupRepository(databasePath: '${tempDir.path}/a.db');
    phoneB = SqliteExpenseGroupRepository(databasePath: '${tempDir.path}/b.db');
    await phoneA.getAllGroups();
    await phoneB.getAllGroups();
    managerB = SyncManager(repository: phoneB);
    await managerB.start();
    drive = _FakeDrive();
    orchestrator = SyncOrchestrator(
      lanChannel: LanSyncChannel(),
      syncManager: SyncManager(repository: phoneA),
      cloudChannel: drive,
    );
    await orchestrator.initialize();
  });

  tearDown(() async {
    await orchestrator.dispose();
    await managerB.stop();
    await phoneA.close();
    await phoneB.close();
    DeviceIdentity.reset();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('takes every group from the other phone, shared or not', () async {
    await phoneB.saveGroup(_group('trip', title: 'Lisbon'));
    await uploadFromB();

    final result = await orchestrator.syncCloudNow();

    expect(result.errors, 0);
    expect(result.applied, 1);
    expect(result.groupIds, {'trip'});
    final trip = (await phoneA.getGroupById('trip')).unwrap();
    expect(trip?.title, 'Lisbon');
    expect(trip?.expenses.single.amount, 30);
  });

  test('uploads its own snapshot, with what it just merged', () async {
    await phoneA.saveGroup(_group('home'));
    await phoneB.saveGroup(_group('trip'));
    await uploadFromB();

    final result = await orchestrator.syncCloudNow();

    final mine = jsonDecode(drive.files['phone-a']!) as Map<String, dynamic>;
    expect(mine['device_id'], 'phone-a');
    expect(mine['schema'], DeltaBuilder.schemaVersion);
    expect([
      for (final g in mine['groups'] as List) g['id'],
    ], unorderedEquals(['home', 'trip']));
    expect(result.sent, 2);

    // And phone B gets phone A's group from it.
    await downloadOnB();
    expect((await phoneB.getGroupById('home')).unwrap(), isNotNull);
  });

  test('its own old shard is not applied again', () async {
    drive.files['phone-a'] = jsonEncode({
      'schema': DeltaBuilder.schemaVersion,
      'device_id': 'phone-a',
      'device_name': 'Me',
      'timestamp': 1,
      'groups': [
        {
          ..._group('ghost').toJson(),
          '_sync': {'device_id': 'phone-a', 'updated_at': 1, 'sync_version': 1},
        },
      ],
      'deleted_groups': <Object>[],
    });

    final result = await orchestrator.syncCloudNow();

    expect(result.applied, 0);
    expect((await phoneA.getGroupById('ghost')).unwrap(), isNull);
  });

  test(
    'a deleted group is deleted on the other phone, and stays deleted',
    () async {
      await phoneB.saveGroup(_group('trip'));
      await uploadFromB();
      await orchestrator.syncCloudNow();
      expect((await phoneA.getGroupById('trip')).unwrap(), isNotNull);

      await Future<void>.delayed(const Duration(milliseconds: 5));
      await phoneA.deleteGroup('trip');
      await orchestrator.syncCloudNow();

      // Phone B's stale shard still has the group: it doesn't come back.
      expect((await phoneA.getGroupById('trip')).unwrap(), isNull);
      final mine = jsonDecode(drive.files['phone-a']!) as Map<String, dynamic>;
      expect(
        [for (final g in mine['deleted_groups'] as List) g['id']],
        ['trip'],
      );

      await downloadOnB();
      expect((await phoneB.getGroupById('trip')).unwrap(), isNull);
    },
  );

  test('a shard from a newer app is skipped, the rest goes on', () async {
    drive.files['phone-b'] = jsonEncode({
      'schema': DeltaBuilder.schemaVersion + 1,
      'device_id': 'phone-b',
      'device_name': 'Pixel 9',
      'timestamp': 1,
      'groups': [
        {
          ..._group('future').toJson(),
          '_sync': {'device_id': 'phone-b', 'updated_at': 1, 'sync_version': 1},
        },
      ],
      'deleted_groups': <Object>[],
    });

    final result = await orchestrator.syncCloudNow();

    expect(result.errors, 1);
    expect((await phoneA.getGroupById('future')).unwrap(), isNull);
    expect(drive.files['phone-a'], isNotNull);
  });

  test('signed out: reported as a Drive problem', () async {
    drive.signedIn = false;

    final result = await orchestrator.syncCloudNow();

    expect(result.errors, greaterThan(0));
    expect(
      orchestrator.problems.map((p) => p.reason),
      contains(SyncProblemReason.cloudUnreachable),
    );

    drive.signedIn = true;
    await orchestrator.syncCloudNow();
    expect(
      orchestrator.problems.map((p) => p.reason),
      isNot(contains(SyncProblemReason.cloudUnreachable)),
    );
  });

  test(
    'turning it on runs a cycle and starts the timer; off stops it',
    () async {
      await phoneA.saveGroup(_group('home'));

      await orchestrator.setCloudSyncEnabled(true);
      await orchestrator.syncCloudNow();

      expect(drive.cycle, isNotNull);
      expect(drive.files['phone-a'], isNotNull);
      expect(await orchestrator.isCloudSyncEnabled(), isTrue);

      await orchestrator.setCloudSyncEnabled(false);
      expect(drive.cycle, isNull);
      expect(await orchestrator.isCloudSyncEnabled(), isFalse);
    },
  );

  test('deleting a group leaves a tombstone without its expenses', () async {
    await phoneA.saveGroup(_group('trip'));
    final db = await phoneA.database;
    final before = (await db.query('groups', where: "id = 'trip'")).single;

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await phoneA.deleteGroup('trip');

    final row = (await db.query('groups', where: "id = 'trip'")).single;
    expect(row['deleted'], 1);
    expect(row['updated_at'] as int, greaterThan(before['updated_at'] as int));
    expect(await db.query('expenses', where: "group_id = 'trip'"), isEmpty);
    expect((await phoneA.getGroupById('trip')).unwrap(), isNull);
    expect((await phoneA.getAllGroups()).unwrap(), isEmpty);
  });
}
