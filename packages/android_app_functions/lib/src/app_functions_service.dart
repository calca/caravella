import 'package:flutter/services.dart';

import 'models/add_expense_function_params.dart';

/// Callback invoked when the user opens an AI agent's link to add an
/// expense to [AddExpenseFunctionParams.groupId]: the app opens the group.
typedef AddExpenseCallback = void Function(AddExpenseFunctionParams params);

/// Callback invoked when an AI agent has added an expense to [groupId]
/// natively, while the app is open: its screens should reload the group.
typedef ExpenseAddedCallback = void Function(String groupId);

/// Dart-side service for Android App Functions.
///
/// The functions run natively (`CaravellaAppFunctionService`, Kotlin) and
/// read and write the database without Flutter. `MainActivity` calls this
/// app over a [MethodChannel] for two things only: `onAddExpense`, when the
/// user opens an agent's link to a group, and `onExpenseAdded`, when an agent
/// added an expense while the app is open.
///
/// Call [initialize] once at app start-up (Android only).
class AppFunctionsService {
  static const MethodChannel _channel = MethodChannel(
    'io.caravella.egm/app_functions',
  );

  static AddExpenseCallback? _onAddExpense;
  static ExpenseAddedCallback? _onExpenseAdded;

  /// Sets up the method-call handler and registers the callbacks.
  static void initialize({
    required AddExpenseCallback onAddExpense,
    ExpenseAddedCallback? onExpenseAdded,
  }) {
    _onAddExpense = onAddExpense;
    _onExpenseAdded = onExpenseAdded;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handles the calls `MainActivity` forwards.
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAddExpense':
        final args = call.arguments as Map<dynamic, dynamic>;
        final params = AddExpenseFunctionParams.fromMap(args);
        _onAddExpense?.call(params);
        return null;

      case 'onExpenseAdded':
        final args = call.arguments as Map<dynamic, dynamic>;
        _onExpenseAdded?.call(args['groupId'] as String);
        return null;

      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          message: 'App function not implemented: ${call.method}',
        );
    }
  }
}
