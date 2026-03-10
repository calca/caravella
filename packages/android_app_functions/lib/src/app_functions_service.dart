import 'package:flutter/services.dart';
import 'package:caravella_core/caravella_core.dart';

import 'models/add_expense_function_params.dart';
import 'models/expense_balance_result.dart';
import 'models/recent_expenses_result.dart';
import 'models/today_total_result.dart';

/// Number of recent expenses returned by the getRecentExpenses function.
const int kRecentExpensesCount = 3;

/// Callback invoked when an AI agent requests to add a new expense.
/// The app should navigate to the add-expense screen pre-filled with [params].
typedef AddExpenseCallback = void Function(AddExpenseFunctionParams params);

/// Dart-side service for Android App Functions.
///
/// Communicates with the native [CaravellaAppFunctionService] via a
/// [MethodChannel].  The native service handles the read-only functions
/// (balance, recent expenses, today total) directly from Kotlin – it reads
/// the storage JSON without starting the Flutter engine.  For the write
/// function (addExpense) the native side sends a method-call here so that
/// the running Flutter UI can navigate the user to the expense creation screen.
///
/// Call [initialize] once at app start-up (Android only).
class AppFunctionsService {
  static const MethodChannel _channel = MethodChannel(
    'io.caravella.egm/app_functions',
  );

  static AddExpenseCallback? _onAddExpense;

  /// Sets up the method-call handler and registers the [onAddExpense] callback.
  ///
  /// [onAddExpense] is called when an AI agent (e.g. Google Gemini) asks
  /// the app to open the add-expense screen for a given group.
  static void initialize({required AddExpenseCallback onAddExpense}) {
    _onAddExpense = onAddExpense;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handles method calls forwarded by the native [CaravellaAppFunctionService].
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAddExpense':
        final args = call.arguments as Map<dynamic, dynamic>;
        final params = AddExpenseFunctionParams.fromMap(args);
        _onAddExpense?.call(params);
        return null;

      case 'getGroupBalance':
        return await _handleGetGroupBalance(
          call.arguments as Map<dynamic, dynamic>,
        );

      case 'getRecentExpenses':
        return await _handleGetRecentExpenses(
          call.arguments as Map<dynamic, dynamic>,
        );

      case 'getTodayTotal':
        return await _handleGetTodayTotal(
          call.arguments as Map<dynamic, dynamic>,
        );

      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          message: 'App function not implemented: ${call.method}',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Query handlers (used when the Flutter engine IS running)
  // ---------------------------------------------------------------------------

  static Future<Map<String, dynamic>> _handleGetGroupBalance(
    Map<dynamic, dynamic> args,
  ) async {
    final groupId = args['groupId'] as String;
    final group = await ExpenseGroupStorageV2.getTripById(groupId);
    if (group == null) {
      throw PlatformException(
        code: 'GROUP_NOT_FOUND',
        message: 'No group found with id $groupId',
      );
    }
    final total = await ExpenseGroupStorageV2.getTotalExpenses(groupId);
    return ExpenseBalanceResult(
      groupId: group.id,
      groupTitle: group.title,
      totalBalance: total,
      currency: group.currency,
    ).toMap();
  }

  static Future<Map<String, dynamic>> _handleGetRecentExpenses(
    Map<dynamic, dynamic> args,
  ) async {
    final groupId = args['groupId'] as String;
    final group = await ExpenseGroupStorageV2.getTripById(groupId);
    if (group == null) {
      throw PlatformException(
        code: 'GROUP_NOT_FOUND',
        message: 'No group found with id $groupId',
      );
    }
    final recent = await ExpenseGroupStorageV2.getRecentExpenses(
      groupId,
      limit: kRecentExpensesCount,
    );
    final summaries = recent
        .map(
          (e) => ExpenseSummary(
            id: e.id,
            categoryName: e.category.name,
            amount: e.amount,
            paidByName: e.paidBy.name,
            date: e.date,
            note: e.note,
            name: e.name,
          ),
        )
        .toList();
    return RecentExpensesResult(
      groupId: group.id,
      groupTitle: group.title,
      currency: group.currency,
      expenses: summaries,
    ).toMap();
  }

  static Future<Map<String, dynamic>> _handleGetTodayTotal(
    Map<dynamic, dynamic> args,
  ) async {
    final groupId = args['groupId'] as String;
    final group = await ExpenseGroupStorageV2.getTripById(groupId);
    if (group == null) {
      throw PlatformException(
        code: 'GROUP_NOT_FOUND',
        message: 'No group found with id $groupId',
      );
    }
    final today = await ExpenseGroupStorageV2.getTodaySpending(groupId);
    return TodayTotalResult(
      groupId: group.id,
      groupTitle: group.title,
      todayTotal: today,
      currency: group.currency,
    ).toMap();
  }
}
