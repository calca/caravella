import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Points the app's storage ([ExpenseGroupStorageV2] and everything going
/// through [ExpenseGroupRepositoryFactory]) at a new, empty SQLite database
/// in a temporary file, and returns it.
SqliteExpenseGroupRepository useTestDatabase() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final dir = Directory.systemTemp.createTempSync('caravella_test_db');
  final repository = SqliteExpenseGroupRepository(
    databasePath: '${dir.path}/expense_groups.db',
  );
  ExpenseGroupRepositoryFactory.useForTesting(repository);
  return repository;
}
