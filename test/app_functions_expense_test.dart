import 'package:android_app_functions/android_app_functions.dart';
import 'package:caravella_core/caravella_core.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/services/app_functions_initialization.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _food = ExpenseCategory(id: 'f', name: 'Food');
final _group = ExpenseGroup(
  id: 'g',
  title: 'Trip',
  currency: 'EUR',
  participants: [_anna],
  categories: [_food],
  expenses: const [],
);

void main() {
  test('the agent note names the expense', () {
    final e = AppFunctionsInitialization.expenseFor(
      _group,
      const AddExpenseFunctionParams(groupId: 'g', amount: 12, note: 'Pizza'),
    );
    expect(e.name, 'Pizza');
    expect(e.category.id, 'f');
    expect(e.paidBy.id, 'a');
  });

  test('without a note the category names it, and it is saved', () async {
    final e = AppFunctionsInitialization.expenseFor(
      _group,
      const AddExpenseFunctionParams(groupId: 'g', amount: 12),
    );
    expect(e.name, 'Food');

    // Unnamed, SQLite refused it (expenses.name is NOT NULL).
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('app_functions_expense');
    final repo = SqliteExpenseGroupRepository(
      databasePath: '${dir.path}/expense_groups.db',
    );
    addTearDown(repo.close);
    final result = await repo.saveGroup(_group.copyWith(expenses: [e]));
    expect(result.isSuccess, isTrue, reason: '${result.error}');
    final saved = (await repo.getGroupById('g')).unwrap();
    expect(saved!.expenses.single.amount, 12);
  });
}
