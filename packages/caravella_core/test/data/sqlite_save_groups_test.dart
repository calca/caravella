import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A backup's restore saves all its groups or none: it used to stop half
/// way, keeping the groups saved before the one that failed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory dir;
  late SqliteExpenseGroupRepository repo;

  ExpenseGroup group(String id, String title, ExpenseParticipant who) {
    final food = ExpenseCategory(name: 'Food', id: 'food-$id');
    return ExpenseGroup(
      id: id,
      title: title,
      currency: '€',
      participants: [who],
      categories: [food],
      expenses: [
        ExpenseDetails(
          id: 'e-$id',
          name: 'Dinner',
          category: food,
          amount: 10,
          paidBy: who,
          date: DateTime(2026, 11, 16),
        ),
      ],
      timestamp: DateTime(2026, 11, 1),
    );
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('save_groups');
    repo = SqliteExpenseGroupRepository(databasePath: '${dir.path}/a.db');
  });

  tearDown(() async {
    await repo.close();
    dir.deleteSync(recursive: true);
  });

  test('saves every group', () async {
    (await repo.saveGroups([
      group('a', 'Norway', ExpenseParticipant(name: 'Anna', id: 'anna')),
      group('b', 'Home', ExpenseParticipant(name: 'Bob', id: 'bob')),
    ])).unwrap();
    final all = (await repo.getAllGroups()).unwrap();
    expect(all.map((g) => g.title).toSet(), {'Norway', 'Home'});
  });

  test('one group that fails leaves the others unsaved', () async {
    (await repo.saveGroup(
      group('old', 'Already here', ExpenseParticipant(name: 'Zoe', id: 'z')),
    )).unwrap();

    // The second group has no title: it fails after the first was written.
    final result = await repo.saveGroups([
      group('a', 'Norway', ExpenseParticipant(name: 'Anna', id: 'anna')),
      group('b', '', ExpenseParticipant(name: 'Bob', id: 'bob')),
    ]);

    expect(result.isSuccess, isFalse);
    final all = (await repo.getAllGroups()).unwrap();
    expect(all.map((g) => g.title), ['Already here']);
  });

  test('a write that fails inside the transaction rolls back', () async {
    // The same participant id in two groups breaks the database's keys
    // on the second write, after the first one went in.
    final anna = ExpenseParticipant(name: 'Anna', id: 'anna');
    final result = await repo.saveGroups([
      group('a', 'Norway', anna),
      group('b', 'Home', anna),
    ]);

    expect(result.isSuccess, isFalse);
    expect((await repo.getAllGroups()).unwrap(), isEmpty);
  });
}
