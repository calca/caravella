// Android App Functions package – the Dart side of Caravella's App Functions.
//
// The functions themselves are native (Kotlin, `android/app`); this package
// only receives what they hand to a running app: an agent's link to open a
// group, and the news that an agent added an expense.
//
// Initialise once at app startup (Android only):
//   PlatformAppFunctionsManager.initialize(
//     onAddExpense: (params) { /* open params.groupId */ },
//     onExpenseAdded: (groupId) { /* reload the group */ },
//   );

export 'src/app_functions_service.dart';
export 'src/platform_app_functions_manager.dart';
export 'src/models/add_expense_function_params.dart';
