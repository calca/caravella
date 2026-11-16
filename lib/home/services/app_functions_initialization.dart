import 'package:android_app_functions/android_app_functions.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

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
      onExpenseAdded: _handleExpenseAdded,
    );
  }

  /// An agent added an expense natively while the app is open: tell the
  /// screens that show the group to reload it.
  static void _handleExpenseAdded(String groupId) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    final notifier = context.read<ExpenseGroupNotifier>();
    notifier.notifyGroupUpdated(groupId);
    if (notifier.currentGroup?.id == groupId) notifier.refreshGroup();
  }

  /// The user opened an AI agent's link to add an expense to a group: open
  /// the group, where they add it. Ignored while App Functions are off in
  /// Settings › Privacy.
  static void _handleAddExpense(AddExpenseFunctionParams params) {
    if (!PreferencesService.instance.appFunctions.isEnabled()) {
      LoggerService.info(
        'App Function link ignored: App Functions disabled by user',
        name: 'app_functions',
      );
      return;
    }
    _openGroup(params.groupId);
  }

  static Future<void> _openGroup(String groupId) async {
    try {
      final group = await ExpenseGroupStorageV2.getTripById(groupId);
      if (group == null) {
        LoggerService.warning(
          'App Function link: group not found: $groupId',
          name: 'app_functions',
        );
        return;
      }
      await navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (ctx) => ExpenseGroupDetailPage(trip: group),
        ),
      );
    } catch (e, st) {
      LoggerService.error(
        'App Function link failed',
        name: 'app_functions',
        error: e,
        stackTrace: st,
      );
    }
  }
}
