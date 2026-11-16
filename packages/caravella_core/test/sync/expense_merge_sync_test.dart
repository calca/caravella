import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core/data/sqlite_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final _anna = ExpenseParticipant(name: 'Anna', id: 'anna');
final _food = ExpenseCategory(name: 'Food', id: 'food');

ExpenseDetails _expense(
  String id, {
  double amount = 10,
  ExpenseParticipant? paidBy,
}) => ExpenseDetails(
  id: id,
  name: id,
  category: _food,
  amount: amount,
  paidBy: paidBy ?? _anna,
  date: DateTime(2026, 11, 16),
);

/// A phone sharing the group "trip", syncing through the same
/// [SyncOrchestrator.handleIncomingDelta] the Wi-Fi and Bluetooth channels
/// call.
class _Phone {
  _Phone(this.id, this.repo) : manager = SyncManager(repository: repo) {
    sync = SyncOrchestrator(lanChannel: LanSyncChannel(), syncManager: manager);
  }

  final String id;
  final SqliteExpenseGroupRepository repo;
  final SyncManager manager;
  late final SyncOrchestrator sync;

  /// All phones share one [DeviceIdentity] in a test, so each delta gets the
  /// sender's id here: the receiver checks it against its grants.
  Future<Map<String, dynamic>> _handle(
    Map<String, dynamic> delta,
    _Phone from,
  ) => sync.handleIncomingDelta(
    delta.isEmpty ? delta : {...delta, 'device_id': from.id},
    from.id,
  );

  /// One exchange started by this phone, as the app runs it.
  Future<void> syncWith(_Phone peer) async {
    final mine = await _handle(const {}, peer);
    final theirs = await peer._handle(mine, this);
    await _handle(theirs, peer);
    // Let the clock move past this exchange.
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }

  Future<ExpenseGroup> trip() async =>
      (await repo.getGroupById('trip')).unwrap()!;

  Future<Map<String, double?>> expenses() async => {
    for (final e in (await trip()).expenses) e.id: e.amount,
  };

  /// Saves [change] applied to the group, as the app's screens do.
  Future<void> edit(ExpenseGroup Function(ExpenseGroup) change) async {
    (await repo.saveGroup(change(await trip()))).unwrap();
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }

  Future<void> add(ExpenseDetails e) =>
      edit((g) => g.copyWith(expenses: [...g.expenses, e]));

  Future<void> remove(String expenseId) => edit(
    (g) => g.copyWith(
      expenses: [
        for (final e in g.expenses)
          if (e.id != expenseId) e,
      ],
    ),
  );

  Future<void> setAmount(String expenseId, double amount) => edit(
    (g) => g.copyWith(
      expenses: [
        for (final e in g.expenses)
          e.id == expenseId ? e.copyWith(amount: amount) : e,
      ],
    ),
  );

  Future<int> groupUpdatedAt() async {
    final db = await repo.database;
    return (await db.query(
          kTableGroups,
          where: "id = 'trip'",
        )).single['updated_at']
        as int;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory dir;
  late _Phone a;
  late _Phone b;
  late _Phone c;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'sync_device_id': 'phone'});
    DeviceIdentity.reset();
    await DeviceIdentity.initialize();
    dir = Directory.systemTemp.createTempSync('expense_merge_sync');
    _Phone phone(String id) => _Phone(
      id,
      SqliteExpenseGroupRepository(databasePath: '${dir.path}/$id.db'),
    );
    a = phone('phone-a');
    b = phone('phone-b');
    c = phone('phone-c');
    final trip = ExpenseGroup(
      id: 'trip',
      title: 'Norway',
      currency: '€',
      participants: [_anna],
      categories: [_food],
      expenses: [_expense('soup')],
      timestamp: DateTime(2026, 11, 1),
      syncEnabled: true,
    );
    for (final phone in [a, b, c]) {
      await phone.manager.start();
      await phone.repo.saveGroup(trip);
      final dao = SyncDao(await phone.repo.database);
      for (final peer in [a, b, c]) {
        if (peer != phone) await dao.grantGroupAccess(peer.id, 'trip');
      }
    }
    // A first exchange, as after pairing.
    await a.syncWith(b);
    await a.syncWith(c);
  });

  tearDown(() async {
    for (final phone in [a, b, c]) {
      await phone.repo.close();
    }
    dir.deleteSync(recursive: true);
    DeviceIdentity.reset();
  });

  for (final startedByA in [true, false]) {
    final who = startedByA ? 'A' : 'B';
    test('an expense added on each phone survives, started by $who', () async {
      await a.add(_expense('from-a'));
      await b.add(_expense('from-b'));

      startedByA ? await a.syncWith(b) : await b.syncWith(a);

      expect(
        (await a.expenses()).keys,
        unorderedEquals(['soup', 'from-a', 'from-b']),
      );
      expect(
        (await b.expenses()).keys,
        unorderedEquals(['soup', 'from-a', 'from-b']),
      );
    });
  }

  test('a deletion reaches the other phone and stays', () async {
    await b.add(_expense('from-b'));
    await a.remove('soup');

    await a.syncWith(b);
    await b.syncWith(a);

    expect((await a.expenses()).keys, ['from-b']);
    expect((await b.expenses()).keys, ['from-b']);
  });

  test('an edit made after the deletion brings the expense back', () async {
    await a.remove('soup');
    await b.setAmount('soup', 99);

    await a.syncWith(b);

    expect(await a.expenses(), {'soup': 99});
    expect(await b.expenses(), {'soup': 99});
  });

  test('a deletion made after an edit wins', () async {
    await b.setAmount('soup', 99);
    await a.remove('soup');

    await b.syncWith(a);

    expect(await a.expenses(), isEmpty);
    expect(await b.expenses(), isEmpty);
  });

  test('two edits of one expense: the later one wins', () async {
    await a.setAmount('soup', 20);
    await b.setAmount('soup', 30);

    await a.syncWith(b);

    expect(await a.expenses(), {'soup': 30});
    expect(await b.expenses(), {'soup': 30});
  });

  test(
    'a new name and a new expense on the two phones are both kept',
    () async {
      await a.edit((g) => g.copyWith(title: 'Norway 2026'));
      await b.add(_expense('from-b'));

      await a.syncWith(b);

      for (final phone in [a, b]) {
        final trip = await phone.trip();
        expect(trip.title, 'Norway 2026');
        expect(
          trip.expenses.map((e) => e.id),
          unorderedEquals(['soup', 'from-b']),
        );
      }
    },
  );

  test('a new person and their expense reach the other phone', () async {
    final bruno = ExpenseParticipant(name: 'Bruno', id: 'bruno');
    await b.edit(
      (g) => g.copyWith(
        participants: [...g.participants, bruno],
        expenses: [
          ...g.expenses,
          _expense('ferry', paidBy: bruno),
        ],
      ),
    );
    await a.add(_expense('from-a'));

    await a.syncWith(b);

    final trip = await a.trip();
    expect(
      trip.participants.map((p) => p.name),
      unorderedEquals(['Anna', 'Bruno']),
    );
    expect(
      trip.expenses.firstWhere((e) => e.id == 'ferry').paidBy.name,
      'Bruno',
    );
    expect(
      (await b.expenses()).keys,
      unorderedEquals(['soup', 'ferry', 'from-a']),
    );
  });

  test('changes pass on through a third phone', () async {
    await a.add(_expense('from-a'));
    await c.add(_expense('from-c'));
    await b.remove('soup');

    await a.syncWith(b); // A gets B's deletion, B gets A's expense.
    await b.syncWith(c); // C gets both from B, B gets C's expense.
    await a.syncWith(b); // A gets C's expense through B.

    for (final phone in [a, b, c]) {
      expect(
        (await phone.expenses()).keys,
        unorderedEquals(['from-a', 'from-c']),
        reason: phone.id,
      );
    }
  });

  test('a sync with nothing new writes nothing', () async {
    await a.add(_expense('from-a'));
    await a.syncWith(b);
    final aAt = await a.groupUpdatedAt();
    final bAt = await b.groupUpdatedAt();

    await a.syncWith(b);
    await b.syncWith(a);

    expect(await a.groupUpdatedAt(), aAt);
    expect(await b.groupUpdatedAt(), bAt);
  });

  test('a group from an app before 2.5 still replaces the older one', () async {
    await a.add(_expense('from-a'));
    // What 2.4 sends: the group without expense times.
    final db = await b.repo.database;
    final group = (await b.trip()).copyWith(title: 'From 2.4');
    final delta = {
      'schema': 1,
      'device_id': 'phone-old',
      'device_name': 'Old phone',
      'timestamp': SyncClock.nowMs(),
      'groups': [
        group.toJson()
          ..['_sync'] = {
            'device_id': 'phone-old',
            'updated_at': SyncClock.nowMs() + 1000,
            'sync_version': 1,
          },
      ],
      'deleted_groups': const <Map<String, dynamic>>[],
    };
    final adb = await a.repo.database;
    await SyncDao(adb).grantGroupAccess('phone-old', 'trip');
    await ConflictResolver(syncDao: SyncDao(adb)).applyDelta(adb, delta, 'lan');

    expect((await a.trip()).title, 'From 2.4');
    // Last Writer Wins, as before: the old phone didn't have it.
    expect((await a.expenses()).keys, ['soup']);
    expect(db, isNotNull);
  });
}
