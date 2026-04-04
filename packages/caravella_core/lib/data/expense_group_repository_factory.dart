import 'expense_group_repository.dart';
import 'file_based_expense_group_repository.dart';
import 'sqlite_expense_group_repository.dart';
import '../services/logging/logger_service.dart';

/// Factory to create the appropriate expense group repository based on configuration
class ExpenseGroupRepositoryFactory {
  // Singleton instances
  static IExpenseGroupRepository? _instance;
  
  /// Get the configured repository instance
  static IExpenseGroupRepository getRepository({bool useJsonBackend = false}) {
    if (_instance != null) return _instance!;
    
    if (useJsonBackend) {
      LoggerService.info('Using JSON file-based repository', name: 'storage');
      _instance = FileBasedExpenseGroupRepository();
    } else {
      LoggerService.info('Using SQLite database repository', name: 'storage');
      _instance = SqliteExpenseGroupRepository();
    }
    
    return _instance!;
  }
  
  /// Reset the factory (useful for testing)
  static void reset() {
    _instance = null;
  }
  
  /// Check if using JSON backend
  static bool isUsingJsonBackend() {
    return _instance is FileBasedExpenseGroupRepository;
  }
  
  /// Check if using SQLite backend
  static bool isUsingSqliteBackend() {
    return _instance is SqliteExpenseGroupRepository;
  }
}
