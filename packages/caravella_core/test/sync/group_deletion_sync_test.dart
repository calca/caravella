import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

ExpenseGroup _group(String id, {String title = 'Trip'}) {
  final alice = ExpenseParticipant(name: 'Alice', id: '${id}_p0');
  final food = ExpenseCategory(name: 'Food', id: '${id}_c0');
  return ExpenseGroup(
    id: id,
    title: title,
    currency: 'EUR',
    participants: [alice],
    categories: [food],
    expenses: [
      ExpenseDetails(
        id: '${id}_e0',
        category: food,
        amount: 10,
        paidBy: alice,
        date: DateTime(2026, 11, 1),
        name: 'Dinner',
      ),
    ],
    timestamp: DateTime(2026, 11, 1),
    syncEnabled: true,
    pinned: true,
  );
}

/// A phone sharing groups over LAN or Bluetooth, through the same
/// [SyncOrchestrator.handleIncomingDelta] the channels call.
class _Phone {
  _Phone(this.id, this.repo) : manager = SyncManager(repository: repo) {
    sync = SyncOrchestrator(lanChannel: LanSyncChannel(), syncManager: manager);
  }

  final String id;
  final SqliteExpenseGroupRepository repo;
  final SyncManager manager;
  late final SyncOrchestrator sync;

  /// Both phones share one [DeviceIdentity] in a test, so each delta gets
  /// the sender's id here: the receiver checks it against its grants.
  Future<Map<String, dynamic>> _handle(
    Map<String, dynamic> delta,
    _Phone from,
  ) async {
    return sync.handleIncomingDelta(
      delta.isEmpty ? delta : {...delta, 'device_id': from.id},
      from.id,
    );
  }

  /// One exchange started by this phone: it sends its delta, [peer]
  /// applies it and answers with its own, which this phone applies.
  Future<void> syncWith(_Phone peer) async {
    final mine = await _handle(const {}, peer);
    final theirs = await peer._handle(mine, this);
    await _handle(theirs, peer);
  }

  Future<ExpenseGroup?> group(String groupId) async =>
      (await repo.getGroupById(groupId)).unwrap();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory dir;
  late _Phone a;
  late _Phone b;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'sync_device_id': 'phone'});
    DeviceIdentity.reset();
    await DeviceIdentity.initialize();
    dir = Directory.systemTemp.createTempSync('group_deletion_sync');
    a = _Phone(
      'phone-a',
      SqliteExpenseGroupRepository(databasePath: '${dir.path}/a.db'),
    );
    b = _Phone(
      'phone-b',
      SqliteExpenseGroupRepository(databasePath: '${dir.path}/b.db'),
    );
    for (final (phone, peer) in [(a, b), (b, a)]) {
      await phone.manager.start();
      await phone.repo.saveGroup(_group('trip'));
      await SyncDao(
        await phone.repo.database,
      ).grantGroupAccess(peer.id, 'trip');
    }
    // A first exchange, as after pairing.
    await a.syncWith(b);
    await Future<void>.delayed(const Duration(milliseconds: 5));
  });

  tearDown(() async {
    await a.repo.close();
    await b.repo.close();
    dir.deleteSync(recursive: true);
    DeviceIdentity.reset();
  });

  test('deleting a group leaves a tombstone and no expenses', () async {
    await a.repo.deleteGroup('trip');

    expect(await a.group('trip'), isNull);
    expect((await a.repo.getAllGroups()).unwrap(), isEmpty);
    expect((await a.repo.getPinnedGroup()).unwrap(), isNull);

    final db = await a.repo.database;
    final rows = await db.query(
      SqliteExpenseGroupRepository.tableGroups,
      where: 'id = ?',
      whereArgs: ['trip'],
    );
    expect(rows.single['deleted'], 1);
    expect(await db.query('expenses'), isEmpty);
  });

  for (final startedByDeleter in [true, false]) {
    final who = startedByDeleter ? 'deleting phone' : 'other phone';
    test(
      'a deleted group stays deleted on both, sync started by the $who',
      () async {
        await a.repo.deleteGroup('trip');

        startedByDeleter ? await a.syncWith(b) : await b.syncWith(a);

        expect(await a.group('trip'), isNull);
        expect(await b.group('trip'), isNull);
      },
    );

    test(
      'a change goes to the other phone, sync started by the $who',
      () async {
        await a.repo.saveGroup(_group('trip', title: 'Lisbon'));

        startedByDeleter ? await a.syncWith(b) : await b.syncWith(a);

        expect((await b.group('trip'))?.title, 'Lisbon');
      },
    );
  }

  test('a group can be created again after being deleted', () async {
    await a.repo.deleteGroup('trip');
    await a.repo.saveGroup(_group('trip'));

    expect((await a.group('trip'))?.expenses, hasLength(1));
  });
}
