import 'package:flutter/foundation.dart';

import 'expense_group_repository.dart';
import 'sqlite_expense_group_repository.dart';
import '../services/logging/logger_service.dart';

/// Hands out the app's expense group repository: the SQLite database.
///
/// The JSON file backend is gone (2.5); its old file is only read once, by
/// [StorageMigrationService].
class ExpenseGroupRepositoryFactory {
  static IExpenseGroupRepository? _instance;

  /// The repository instance, created on first use.
  static IExpenseGroupRepository getRepository() {
    if (_instance != null) return _instance!;
    LoggerService.info('Using SQLite database repository', name: 'storage');
    return _instance = SqliteExpenseGroupRepository();
  }

  /// Makes [getRepository] return [repository], e.g. a database in a
  /// temporary file.
  @visibleForTesting
  static void useForTesting(IExpenseGroupRepository repository) {
    _instance = repository;
  }

  /// Reset the factory (useful for testing)
  static void reset() {
    _instance = null;
  }
}
