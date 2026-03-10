// Android App Functions package – exposes Caravella capabilities to Android AI agents.
//
// Usage:
//   import 'package:android_app_functions/android_app_functions.dart';
//
// Initialise once at app startup (Android only):
//   PlatformAppFunctionsManager.initialize(
//     onAddExpense: (params) {
//       // Navigate to add-expense screen pre-filled with params
//     },
//   );

export 'src/app_functions_service.dart';
export 'src/platform_app_functions_manager.dart';
export 'src/models/add_expense_function_params.dart';
export 'src/models/expense_balance_result.dart';
export 'src/models/recent_expenses_result.dart';
export 'src/models/today_total_result.dart';
