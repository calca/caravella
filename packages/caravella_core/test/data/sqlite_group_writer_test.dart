import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core/data/sqlite_schema.dart';
import 'package:caravella_core/data/sqlite_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Saving a group writes only the rows that changed (#730): each expense
/// keeps its own `updated_at`, deletions leave a tombstone, and attachments
/// are not duplicated.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory dir;
  late SqliteExpenseGroupRepository repo;
  late Database db;

  final anna = ExpenseParticipant(name: 'Anna', id: 'anna');
  final bruno = ExpenseParticipant(name: 'Bruno', id: 'bruno');
  final food = ExpenseCategory(name: 'Food', id: 'food');
  ExpenseDetails expense(
    String id, {
    double amount = 10,
    List<String> attachments = const [],
    ExpenseParticipant? paidBy,
  }) => ExpenseDetails(
    id: id,
    name: id,
    category: food,
    amount: amount,
    paidBy: paidBy ?? anna,
    date: DateTime(2026, 11, 16),
    attachments: attachments,
  );
  ExpenseGroup group(List<ExpenseDetails> expenses) => ExpenseGroup(
    id: 'g',
    title: 'Norway',
    currency: '€',
    participants: [anna, bruno],
    categories: [food],
    expenses: expenses,
    timestamp: DateTime(2026, 11, 1),
  );

  Future<Map<String, int>> stamps() async => {
    for (final row in await db.query(kTableExpenses))
      row['id'] as String: row['updated_at'] as int,
  };

  /// Saves, making sure the clock has moved since the last save.
  Future<void> save(ExpenseGroup g) async {
    await Future<void>.delayed(const Duration(milliseconds: 3));
    (await repo.saveGroup(g)).unwrap();
  }

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('group_writer');
    repo = SqliteExpenseGroupRepository(databasePath: '${dir.path}/a.db');
    db = await repo.database;
  });

  tearDown(() async {
    await repo.close();
    dir.deleteSync(recursive: true);
  });

  test('adding an expense leaves the others as they were', () async {
    await save(group([expense('a'), expense('b')]));
    final before = await stamps();

    await save(group([expense('a'), expense('b'), expense('c')]));
    final after = await stamps();

    expect(after['a'], before['a']);
    expect(after['b'], before['b']);
    expect(after['c'], greaterThan(before['a']!));
    final groupRow = (await db.query(kTableGroups)).single;
    expect(groupRow['updated_at'], after['c']);
  });

  test('a changed expense gets a new time, the rest keep theirs', () async {
    await save(group([expense('a'), expense('b')]));
    final before = await stamps();

    await save(group([expense('a', amount: 12), expense('b')]));
    final after = await stamps();

    expect(after['a'], greaterThan(before['a']!));
    expect(after['b'], before['b']);
    final loaded = (await repo.getGroupById('g')).unwrap()!;
    expect(loaded.expenses.firstWhere((e) => e.id == 'a').amount, 12);
  });

  test('a deleted expense leaves a tombstone, gone if it comes back', () async {
    await save(group([expense('a'), expense('b')]));
    await save(group([expense('a')]));

    final tombstones = await db.query(kTableExpenseTombstones);
    expect(tombstones.single['expense_id'], 'b');
    expect(tombstones.single['group_id'], 'g');
    expect(tombstones.single['deleted_at'], isPositive);
    expect((await stamps()).keys, ['a']);

    await save(group([expense('a'), expense('b')]));
    expect(await db.query(kTableExpenseTombstones), isEmpty);
  });

  test('attachments are not duplicated by saving again', () async {
    final g = group([
      expense('a', attachments: ['one.jpg', 'two.jpg']),
    ]);
    await save(g);
    await save(g);
    await save(g);

    expect(await db.query(kTableAttachments), hasLength(2));
    final loaded = (await repo.getGroupById('g')).unwrap()!;
    expect(loaded.expenses.single.attachments, ['one.jpg', 'two.jpg']);

    await save(
      group([
        expense('a', attachments: ['two.jpg']),
      ]),
    );
    expect((await db.query(kTableAttachments)).single['file_path'], 'two.jpg');

    await save(group([]));
    expect(await db.query(kTableAttachments), isEmpty);
  });

  test('people and categories are renamed, added and removed', () async {
    await save(group([expense('a')]));
    final carla = ExpenseParticipant(name: 'Carla', id: 'carla');
    final renamed = group([expense('a', paidBy: carla)]).copyWith(
      participants: [
        ExpenseParticipant(name: 'Anna B.', id: 'anna'),
        carla,
      ],
      categories: [ExpenseCategory(name: 'Meals', id: 'food')],
    );
    await save(renamed);

    final loaded = (await repo.getGroupById('g')).unwrap()!;
    expect(
      {for (final p in loaded.participants) p.id: p.name},
      {'anna': 'Anna B.', 'carla': 'Carla'},
    );
    expect(loaded.categories.single.name, 'Meals');
    expect(loaded.expenses.single.paidBy.name, 'Carla');
  });

  test('deleting a group removes its attachments and tombstones', () async {
    await save(
      group([
        expense('a', attachments: ['one.jpg']),
        expense('b'),
      ]),
    );
    await save(
      group([
        expense('a', attachments: ['one.jpg']),
      ]),
    );
    (await repo.deleteGroup('g')).unwrap();

    expect(await db.query(kTableAttachments), isEmpty);
    expect(await db.query(kTableExpenseTombstones), isEmpty);
    expect(await db.query(kTableExpenses), isEmpty);
  });

  test('a version 10 database is upgraded', () async {
    await repo.close();
    final path = '${dir.path}/old.db';
    // A version 10 database: today's schema without what v11 adds, with the
    // duplicated and orphan attachment rows old saves left behind.
    final old = await openDatabase(
      path,
      version: 10,
      onCreate: (db, _) async {
        await createSqliteSchema(db);
        await db.execute('DROP TABLE $kTableExpenseTombstones');
        await db.execute('ALTER TABLE $kTableExpenses DROP COLUMN updated_at');
        await db.insert(kTableGroups, {
          'id': 'g',
          'title': 'Norway',
          'currency': '€',
          'timestamp': 1,
          'updated_at': 4242,
        });
        await db.insert(kTableParticipants, {
          'id': 'anna',
          'group_id': 'g',
          'name': 'Anna',
        });
        await db.insert(kTableCategories, {
          'id': 'food',
          'group_id': 'g',
          'name': 'Food',
        });
        await db.insert(kTableExpenses, {
          'id': 'a',
          'group_id': 'g',
          'name': 'a',
          'amount': 10.0,
          'date': 1,
          'category_id': 'food',
          'paid_by_id': 'anna',
        });
        for (final row in [
          ('a', 'one.jpg'),
          ('a', 'one.jpg'),
          ('a', 'one.jpg'),
          ('a', 'two.jpg'),
          ('gone', 'old.jpg'),
        ]) {
          await db.insert(kTableAttachments, {
            'expense_id': row.$1,
            'file_path': row.$2,
          });
        }
      },
    );
    await old.close();

    repo = SqliteExpenseGroupRepository(databasePath: path);
    db = await repo.database;

    expect(await stamps(), {'a': 4242});
    expect(await db.query(kTableExpenseTombstones), isEmpty);
    final loaded = (await repo.getGroupById('g')).unwrap()!;
    expect(loaded.expenses.single.attachments, ['one.jpg', 'two.jpg']);
    expect(await db.query(kTableAttachments), hasLength(2));
  });
}
