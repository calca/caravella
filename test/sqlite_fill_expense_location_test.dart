import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// #607: a place saved before SQLite v7 (2.3.0) is bare coordinates —
/// `location_details` NULL. Naming it later is a local fix, not an edit:
/// the group's `updated_at` (which sync compares) stays as it was.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late SqliteExpenseGroupRepository repository;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('fill_location');
    repository = SqliteExpenseGroupRepository(
      databasePath: '${tempDir.path}/expense_groups.db',
    );
  });

  tearDown(() async {
    await repository.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test(
    'a pre-v7 place reads as bare coordinates and is named in place',
    () async {
      final anna = ExpenseParticipant(name: 'Anna');
      final food = ExpenseCategory(name: 'Food');
      final expense = ExpenseDetails(
        name: 'Dinner',
        amount: 40,
        date: DateTime(2025, 6, 1),
        paidBy: anna,
        category: food,
        location: ExpenseLocation(latitude: 45.4642, longitude: 9.19),
      );
      final group = ExpenseGroup(
        title: 'Milan',
        expenses: [expense],
        participants: [anna],
        categories: [food],
        currency: '€',
      );
      expect((await repository.saveGroup(group)).isSuccess, isTrue);

      // As a v6 row: coordinates only.
      final db = await repository.database;
      await db.update('expenses', {
        'location_details': null,
        'location_name': null,
      });
      Future<int> updatedAt() async =>
          (await db.query(
                'groups',
                columns: ['updated_at'],
              )).first['updated_at']!
              as int;
      final before = await updatedAt();

      final bare = (await repository.getGroupById(
        group.id,
      )).data!.expenses.single.location!;
      expect(bare.isBareCoordinates, isTrue);

      final named = bare.copyWith(locality: 'Milano', country: 'Italia');
      final result = await repository.fillExpenseLocation(
        group.id,
        expense.id,
        named,
      );
      expect(result.isSuccess, isTrue);

      final reloaded = (await repository.getGroupById(group.id)).data!;
      expect(reloaded.expenses.single.location!.locality, 'Milano');
      expect(reloaded.expenses.single.location!.isBareCoordinates, isFalse);
      expect(reloaded.expenses.single.updatedBy, expense.updatedBy);
      expect(await updatedAt(), before);
    },
  );

  test('isBareCoordinates', () {
    expect(
      ExpenseLocation(latitude: 1, longitude: 2).isBareCoordinates,
      isTrue,
    );
    expect(
      ExpenseLocation(latitude: 1, longitude: 2, name: 'Bar').isBareCoordinates,
      isFalse,
    );
    expect(
      ExpenseLocation(
        latitude: 1,
        longitude: 2,
        locality: 'Roma',
      ).isBareCoordinates,
      isFalse,
    );
    expect(ExpenseLocation(name: 'Bar').isBareCoordinates, isFalse);
  });
}
