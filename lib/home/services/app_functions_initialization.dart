import 'package:android_app_functions/android_app_functions.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';

import '../../manager/details/pages/expense_group_detail_page.dart';

/// Initialises the Android App Functions service and wires up the UI callbacks.
///
/// Call once from [main] after the app is fully initialised (Android only –
/// [PlatformAppFunctionsManager] is a no-op on other platforms).
class AppFunctionsInitialization {
  /// Set up the [PlatformAppFunctionsManager] with the add-expense callback.
  static void initialize() {
    PlatformAppFunctionsManager.initialize(
      onAddExpense: _handleAddExpense,
    );
  }

  /// Called when an AI agent requests a new expense to be added.
  ///
  /// Guards against the feature being disabled via the privacy toggle before
  /// processing the request.  Navigates to the expense group detail page so
  /// the user can review and confirm the pre-filled expense.  If the group
  /// cannot be found, shows an error snackbar.
  static void _handleAddExpense(AddExpenseFunctionParams params) {
    // Honour the privacy toggle: ignore the request when App Functions are off.
    if (!PreferencesService.instance.appFunctions.isEnabled()) {
      LoggerService.info(
        'App Function addExpense ignored: App Functions disabled by user',
        name: 'app_functions',
      );
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) return;

    _handleAddExpenseAsync(context, params);
  }

  static Future<void> _handleAddExpenseAsync(
    BuildContext context,
    AddExpenseFunctionParams params,
  ) async {
    try {
      final group = await ExpenseGroupStorageV2.getTripById(params.groupId);
      if (!context.mounted) return;

      if (group == null) {
        LoggerService.warning(
          'App Function addExpense: group not found: ${params.groupId}',
          name: 'app_functions',
        );
        return;
      }

      // If the AI agent supplied a valid amount, create the expense immediately
      // and navigate to the group detail so the user can see the result.
      // When no amount is provided (amount == 0.0), navigate to the group detail
      // page only – the user can create the expense manually with the pre-context.
      if (params.amount > 0) {
        final category = _resolveCategory(group, params.categoryName);
        final paidBy = group.participants.isNotEmpty
            ? group.participants.first
            : ExpenseParticipant(name: 'Me');

        final expense = ExpenseDetails(
          category: category,
          amount: params.amount,
          paidBy: paidBy,
          date: DateTime.now(),
          note: params.note,
        );

        await ExpenseGroupStorageV2.addExpenseToGroup(group.id, expense);
        LoggerService.info(
          'App Function addExpense: added ${params.amount} to group ${group.title}',
          name: 'app_functions',
        );
      } else {
        // No amount provided – just open the group so the user can add it manually.
        LoggerService.info(
          'App Function addExpense: opening group ${group.title} (no amount pre-filled)',
          name: 'app_functions',
        );
      }

      // Always navigate to the group detail page
      final navigator = navigatorKey.currentState;
      if (navigator == null || !context.mounted) return;
      await navigator.push(
        MaterialPageRoute(
          builder: (ctx) => ExpenseGroupDetailPage(trip: group),
        ),
      );
    } catch (e, st) {
      LoggerService.error(
        'App Function addExpense failed',
        name: 'app_functions',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Resolves the category for a new expense.
  ///
  /// If [categoryName] matches an existing category (case-insensitive) in the
  /// group, that category is returned.  Otherwise the first category is used,
  /// or a default one is created.
  static ExpenseCategory _resolveCategory(
    ExpenseGroup group,
    String? categoryName,
  ) {
    if (categoryName != null && group.categories.isNotEmpty) {
      final match = group.categories
          .where(
            (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
          )
          .firstOrNull;
      if (match != null) return match;
    }
    if (group.categories.isNotEmpty) return group.categories.first;
    return ExpenseCategory(name: 'Other');
  }
}
