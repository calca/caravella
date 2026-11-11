import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// The budget travels with the group in schema 2 deltas. A 2.4 peer sends
/// schema 1 groups without it: the one this device has stays.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late SqliteExpenseGroupRepository repository;
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('budget_sync_');
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

  ExpenseGroup trip({String title = 'Norway', GroupBudget? budget}) =>
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
        budget: budget,
      );

  const budget = GroupBudget(amount: 1500, period: BudgetPeriod.total);

  Map<String, dynamic> delta(
    ExpenseGroup g, {
    int? schema,
    bool strip = false,
  }) {
    final json = g.toJson();
    if (strip) json.remove('budget');
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

  Future<void> apply(Map<String, dynamic> d) async {
    final db = await repository.database;
    final dao = SyncDao(db);
    await dao.grantGroupAccess('peer', 'g');
    final result = await ConflictResolver(
      syncDao: dao,
    ).applyDelta(db, d, 'lan');
    expect(result.applied, 1);
  }

  test('the budget survives the group JSON', () {
    expect(ExpenseGroup.fromJson(trip(budget: budget).toJson()).budget, budget);
    expect(ExpenseGroup.fromJson(trip().toJson()).budget, isNull);
  });

  test('a schema 2 delta brings its budget', () async {
    await save(trip());
    await apply(delta(trip(budget: budget), schema: 2));
    expect((await stored()).budget, budget);
  });

  test('a schema 2 delta can remove the budget', () async {
    await save(trip(budget: budget));
    await apply(delta(trip(), schema: 2));
    expect((await stored()).budget, isNull);
  });

  test('a group from 2.4 (no schema) keeps the budget set here', () async {
    await save(trip(budget: budget));
    await apply(delta(trip(title: 'Norway 2026'), strip: true));
    final g = await stored();
    expect(g.title, 'Norway 2026');
    expect(g.budget, budget);
  });
}
