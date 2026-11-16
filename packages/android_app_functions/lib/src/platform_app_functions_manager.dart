import 'dart:io';
import 'app_functions_service.dart';

/// Platform-aware wrapper for [AppFunctionsService].
///
/// Ensures the service is only initialised on Android.
class PlatformAppFunctionsManager {
  /// Initialise the App Functions service (Android only).
  ///
  /// [onAddExpense] is called when an AI agent requests a new expense to be
  /// added.  The callback should navigate to the app's expense-creation screen.
  ///
  /// [onExpenseAdded] is called with the group's id when an agent has added
  /// an expense natively while the app is open, so the group can be reloaded.
  static void initialize({
    required AddExpenseCallback onAddExpense,
    ExpenseAddedCallback? onExpenseAdded,
  }) {
    if (!Platform.isAndroid) return;
    AppFunctionsService.initialize(
      onAddExpense: onAddExpense,
      onExpenseAdded: onExpenseAdded,
    );
  }
}
