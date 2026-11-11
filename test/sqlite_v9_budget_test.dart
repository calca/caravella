import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core/data/sqlite_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// v9 adds the group budget (`budget_amount`, `budget_period`). A v8
/// database upgrades with no budget and stores one from then on.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late String dbPath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqlite_v9_budget_');
    dbPath = '${tempDir.path}/expense_groups.db';
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Today's schema without the v9 columns, at version 8, with one group.
  Future<void> createV8Database() async {
    final db = await databaseFactoryFfi.openDatabase(dbPath);
    await createSqliteSchema(db);
    await db.execute('ALTER TABLE groups DROP COLUMN budget_amount');
    await db.execute('ALTER TABLE groups DROP COLUMN budget_period');
    await db.insert('groups', {
      'id': 'g',
      'title': 'Norway',
      'currency': '€',
      'timestamp': DateTime(2026, 11, 1).millisecondsSinceEpoch,
    });
    await db.insert('participants', {
      'id': 'anna',
      'group_id': 'g',
      'name': 'Anna',
    });
    await db.insert('participants', {
      'id': 'luca',
      'group_id': 'g',
      'name': 'Luca',
    });
    await db.setVersion(8);
    await db.close();
  }

  test('a v8 database upgrades with no budget, then keeps one', () async {
    await createV8Database();
    final repository = SqliteExpenseGroupRepository(databasePath: dbPath);
    addTearDown(repository.close);

    final group = (await repository.getGroupById('g')).unwrap()!;
    expect(group.title, 'Norway');
    expect(group.budget, isNull);

    const budget = GroupBudget(amount: 600, period: BudgetPeriod.monthly);
    final saved = await repository.saveGroup(group.copyWith(budget: budget));
    expect(saved.isSuccess, isTrue, reason: '${saved.error}');
    expect((await repository.getGroupById('g')).unwrap()!.budget, budget);

    final cleared = await repository.saveGroup(
      group.copyWith(budget: null),
    );
    expect(cleared.isSuccess, isTrue, reason: '${cleared.error}');
    expect((await repository.getGroupById('g')).unwrap()!.budget, isNull);
  });
}
