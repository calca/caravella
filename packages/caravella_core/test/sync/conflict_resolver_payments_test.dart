import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Payments (Settle up) travel with the group in schema 2 deltas. A 2.4
/// peer sends schema 1 groups without them: the ones this device has stay.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late SqliteExpenseGroupRepository repository;
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('payments_sync_');
    repository = SqliteExpenseGroupRepository(
      databasePath: '${tempDir.path}/test.db',
    );
    await repository.getAllGroups();
  });

  tearDown(() async {
    await repository.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  final anna = ExpenseParticipant(id: 'anna', name: 'Anna');
  final luca = ExpenseParticipant(id: 'luca', name: 'Luca');
  final food = ExpenseCategory(id: 'food', name: 'Food');

  ExpenseGroup trip({String title = 'Norway', List<SettlePayment>? payments}) =>
      ExpenseGroup(
        id: 'g',
        title: title,
        currency: '€',
        participants: [anna, luca],
        categories: [food],
        expenses: [
          ExpenseDetails(
            id: 'e',
            name: 'Hotel',
            amount: 100,
            paidBy: anna,
            category: food,
            date: DateTime(2026, 11, 1),
          ),
        ],
        payments: payments ?? const [],
      );

  final paid = SettlePayment(
    id: 'pay',
    fromId: 'luca',
    toId: 'anna',
    amount: 50,
    date: DateTime(2026, 11, 10),
  );

  Map<String, dynamic> delta(
    ExpenseGroup g, {
    int? schema,
    bool strip = false,
  }) {
    final json = g.toJson();
    if (strip) json.remove('payments');
    json['_sync'] = {
      'device_id': 'peer',
      'updated_at': SyncClock.nowMs() + 1000,
      'sync_version': 1,
    };
    return {
      'schema': ?schema,
      'device_id': 'peer',
      'device_name': 'Pixel 9',
      'timestamp': SyncClock.nowMs(),
      'groups': [json],
      'deleted_groups': <Map<String, dynamic>>[],
    };
  }

  Future<ExpenseGroup> stored() async =>
      (await repository.getGroupById('g')).unwrap()!;

  Future<void> save(ExpenseGroup g) async {
    final r = await repository.saveGroup(g);
    expect(r.isSuccess, isTrue, reason: '${r.error}');
  }

  test('payments are saved and read back', () async {
    await save(trip(payments: [paid]));
    expect((await stored()).payments, [paid]);
  });

  test('a schema 2 delta brings its payments', () async {
    await save(trip());
    final db = await repository.database;
    final dao = SyncDao(db);
    await dao.grantGroupAccess('peer', 'g');
    await ConflictResolver(
      syncDao: dao,
    ).applyDelta(db, delta(trip(payments: [paid]), schema: 2), 'lan');
    expect((await stored()).payments, [paid]);
  });

  test('a schema 2 delta can untick a payment', () async {
    await save(trip(payments: [paid]));
    final db = await repository.database;
    final dao = SyncDao(db);
    await dao.grantGroupAccess('peer', 'g');
    await ConflictResolver(
      syncDao: dao,
    ).applyDelta(db, delta(trip(), schema: 2), 'lan');
    expect((await stored()).payments, isEmpty);
  });

  test('a group from 2.4 (no schema) keeps the payments made here', () async {
    await save(trip(payments: [paid]));
    final db = await repository.database;
    final dao = SyncDao(db);
    await dao.grantGroupAccess('peer', 'g');
    final result = await ConflictResolver(
      syncDao: dao,
    ).applyDelta(db, delta(trip(title: 'Norway 2026'), strip: true), 'lan');
    expect(result.applied, 1);
    final g = await stored();
    expect(g.title, 'Norway 2026');
    expect(g.payments, [paid]);
  });

  test('from 2.4, a payment naming someone removed there goes', () async {
    await save(trip(payments: [paid]));
    final db = await repository.database;
    final dao = SyncDao(db);
    await dao.grantGroupAccess('peer', 'g');
    final withoutLuca = ExpenseGroup.fromJson(
      trip().toJson()..['participants'] = [anna.toJson()],
    );
    await ConflictResolver(
      syncDao: dao,
    ).applyDelta(db, delta(withoutLuca, schema: 1, strip: true), 'lan');
    expect((await stored()).payments, isEmpty);
  });
}
