import 'package:hive_flutter/hive_flutter.dart';
import '../model/expense_location_adapter.dart';
import '../model/expense_category_adapter.dart';
import '../model/expense_participant_adapter.dart';
import '../model/expense_details_adapter.dart';
import '../model/expense_group_adapter.dart';

/// Service to initialize Hive with all necessary type adapters
class HiveInitializationService {
  static bool _initialized = false;
  
  /// Initializes Hive with all type adapters
  /// Safe to call multiple times - will only initialize once
  static Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register type adapters
    Hive.registerAdapter(ExpenseLocationAdapter());
    Hive.registerAdapter(ExpenseCategoryAdapter());
    Hive.registerAdapter(ExpenseParticipantAdapter());
    Hive.registerAdapter(ExpenseDetailsAdapter());
    Hive.registerAdapter(ExpenseGroupAdapter());
    
    _initialized = true;
  }
  
  /// Closes all Hive boxes (useful for cleanup in tests)
  static Future<void> closeAll() async {
    await Hive.close();
    _initialized = false;
  }
  
  /// Check if Hive has been initialized
  static bool get isInitialized => _initialized;
}
