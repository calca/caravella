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
  static void initialize({required AddExpenseCallback onAddExpense}) {
    if (!Platform.isAndroid) return;
    AppFunctionsService.initialize(onAddExpense: onAddExpense);
  }
}
