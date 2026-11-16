import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core/data/sqlite_schema.dart';
import 'package:caravella_core/data/sqlite_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// The database enforces its foreign keys (they were declared but never
/// switched on), and the upgrade removes the rows old group deletions left
/// behind.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory dir;
  late SqliteExpenseGroupRepository repo;

  final anna = ExpenseParticipant(name: 'Anna', id: 'anna');
  final food = ExpenseCategory(name: 'Food', id: 'food');
  final group = ExpenseGroup(
    id: 'g',
    title: 'Norway',
    currency: '€',
    participants: [anna],
    categories: [food],
    expenses: [
      ExpenseDetails(
        id: 'a',
        name: 'a',
        category: food,
        amount: 10,
        paidBy: anna,
        date: DateTime(2026, 11, 16),
        attachments: ['one.jpg'],
      ),
    ],
    timestamp: DateTime(2026, 11, 1),
  );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('foreign_keys');
    repo = SqliteExpenseGroupRepository(databasePath: '${dir.path}/a.db');
  });

  tearDown(() async {
    await repo.close();
    dir.deleteSync(recursive: true);
  });

  test(
    'foreign keys are on: a row needs its parent, deletes cascade',
    () async {
      final db = await repo.database;
      expect(
        (await db.rawQuery('PRAGMA foreign_keys')).single.values.single,
        1,
      );
      (await repo.saveGroup(group)).unwrap();

      // An expense of a group that doesn't exist is refused.
      await expectLater(
        db.insert(kTableExpenses, {
          'id': 'x',
          'group_id': 'nope',
          'name': 'x',
          'date': 1,
          'category_id': 'food',
          'paid_by_id': 'anna',
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Removing an expense takes its attachments; removing a group, the rest.
      await db.delete(kTableExpenses, where: "id = 'a'");
      expect(await db.query(kTableAttachments), isEmpty);
      await db.delete(kTableGroups, where: "id = 'g'");
      expect(await db.query(kTableParticipants), isEmpty);
      expect(await db.query(kTableCategories), isEmpty);
    },
  );

  test('saving, changing people and deleting still work', () async {
    (await repo.saveGroup(group)).unwrap();
    final bruno = ExpenseParticipant(name: 'Bruno', id: 'bruno');
    // The payer changes and the old one leaves, in one save.
    (await repo.saveGroup(
      group.copyWith(
        participants: [bruno],
        expenses: [group.expenses.single.copyWith(paidBy: bruno)],
      ),
    )).unwrap();
    (await repo.updateGroupMetadata(
      group.copyWith(
        participants: [ExpenseParticipant(name: 'Bruno B.', id: 'bruno')],
      ),
    )).unwrap();
    final loaded = (await repo.getGroupById('g')).unwrap()!;
    expect(loaded.expenses.single.paidBy.name, 'Bruno B.');

    (await repo.deleteGroup('g')).unwrap();
    final db = await repo.database;
    expect(await db.query(kTableExpenses), isEmpty);
    expect(await db.query(kTableAttachments), isEmpty);
  });

  test('the upgrade removes rows left by groups deleted long ago', () async {
    await repo.close();
    final path = '${dir.path}/old.db';
    // Version 12, foreign keys off as they always were: group "gone" was
    // deleted by removing its row only.
    final old = await openDatabase(
      path,
      version: 12,
      onCreate: (db, _) async {
        await createSqliteSchema(db);
        await db.insert(kTableGroups, {
          'id': 'g',
          'title': 'Norway',
          'currency': '€',
          'timestamp': 1,
        });
        for (final g in ['g', 'gone']) {
          await db.insert(kTableParticipants, {
            'id': 'p-$g',
            'group_id': g,
            'name': 'Anna',
          });
          await db.insert(kTableCategories, {
            'id': 'c-$g',
            'group_id': g,
            'name': 'Food',
          });
          await db.insert(kTableExpenses, {
            'id': 'e-$g',
            'group_id': g,
            'name': 'Dinner',
            'amount': 10.0,
            'date': 1,
            'category_id': 'c-$g',
            'paid_by_id': 'p-$g',
          });
          await db.insert(kTableAttachments, {
            'expense_id': 'e-$g',
            'file_path': '$g.jpg',
          });
        }
      },
    );
    await old.close();

    repo = SqliteExpenseGroupRepository(databasePath: path);
    final db = await repo.database;

    for (final table in [
      kTableParticipants,
      kTableCategories,
      kTableExpenses,
    ]) {
      expect((await db.query(table)).map((r) => r['group_id']), [
        'g',
      ], reason: table);
    }
    expect((await db.query(kTableAttachments)).single['file_path'], 'g.jpg');
    final loaded = (await repo.getGroupById('g')).unwrap()!;
    expect(loaded.expenses.single.attachments, ['g.jpg']);
  });
}
