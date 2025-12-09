import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'notification_service.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../manager/details/widgets/expense_entry_sheet.dart';
import '../manager/details/pages/expense_group_detail_page.dart';

/// Helper class to manage notification updates when expense groups change
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationService _notificationService = NotificationService();

  /// Callback that can be set by the group edit page to receive notification disable events
  static void Function(String groupId)? onNotificationDisabled;

  /// Updates the notification for a group if notifications are enabled
  Future<void> updateNotificationForGroup(
    ExpenseGroup group,
    gen.AppLocalizations loc,
  ) async {
    if (group.notificationEnabled) {
      try {
        await _notificationService.showGroupNotification(group, loc);
      } catch (e) {
        debugPrint('Failed to update notification for group ${group.id}: $e');
      }
    }
  }

  /// Cancels the notification for a group
  Future<void> cancelNotificationForGroup() async {
    try {
      await _notificationService.cancelGroupNotification();
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }

  /// Handles the "add expense" action from notification
  /// Navigates to home page and opens the add expense bottom sheet for the group
  static Future<void> handleAddExpenseAction(String groupId) async {
    try {
      // Get the navigation key from the app
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        debugPrint('Cannot navigate: context not available');
        return;
      }

      // Get the notifier before any async operations
      final notifier = Provider.of<ExpenseGroupNotifier>(
        context,
        listen: false,
      );

      // Load the expense group
      final group = await ExpenseGroupStorageV2.getTripById(groupId);
      if (group == null) {
        debugPrint('Group not found: $groupId');
        // Check context is still valid after async operation
        final currentContext = navigatorKey.currentContext;
        if (currentContext != null && currentContext.mounted) {
          AppToast.show(
            currentContext,
            'Gruppo non trovato',
            type: ToastType.error,
          );
        }
        return;
      }

      // Set current group
      notifier.setCurrentGroup(group);

      // Navigate to home if not already there
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        // Pop all routes to get to home
        navigator.popUntil((route) => route.isFirst);

        // Wait a bit for the navigation to complete
        await Future.delayed(const Duration(milliseconds: 300));

        // Check if context is still valid after async gap
        final currentContext = navigatorKey.currentContext;
        if (currentContext != null && currentContext.mounted) {
          _showAddExpenseSheet(currentContext, group, notifier);
        }
      }
    } catch (e) {
      debugPrint('Error handling add expense action: $e');
    }
  }

  /// Handles the "disable" action from notification
  /// Disables the notification setting for the group and cancels the notification
  static Future<void> handleDisableAction(String groupId) async {
    try {
      debugPrint('Handling disable action for group: $groupId');

      // Get context for notifier before async operations
      final context = navigatorKey.currentContext;
      ExpenseGroupNotifier? notifier;

      if (context != null && context.mounted) {
        notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
      }

      // Load the expense group
      final group = await ExpenseGroupStorageV2.getTripById(groupId);
      if (group == null) {
        debugPrint('Group not found: $groupId');
        return;
      }

      // Update the group to disable notifications
      final updatedGroup = group.copyWith(notificationEnabled: false);
      await ExpenseGroupStorageV2.updateGroupMetadata(updatedGroup);

      // Notify the UI about the change
      if (notifier != null) {
        await notifier.refreshGroup();
        notifier.notifyGroupUpdated(groupId);
      }

      // Notify the edit page if it's open via callback
      if (onNotificationDisabled != null) {
        onNotificationDisabled!(groupId);
      }

      // Cancel the notification
      await NotificationService().cancelGroupNotification();

      debugPrint('Notification disabled for group: ${group.title}');
    } catch (e) {
      debugPrint('Error handling disable action: $e');
    }
  }

  /// Handles tapping on the notification body (not action buttons)
  /// Opens the expense group detail page
  static Future<void> handleOpenGroupDetail(String groupId) async {
    try {
      debugPrint('Opening group detail for: $groupId');

      // Get the navigation key from the app
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        debugPrint('Cannot navigate: context not available');
        return;
      }

      // Load the expense group
      final group = await ExpenseGroupStorageV2.getTripById(groupId);
      if (group == null) {
        debugPrint('Group not found: $groupId');
        // Check context is still valid after async operation
        final currentContext = navigatorKey.currentContext;
        if (currentContext != null && currentContext.mounted) {
          AppToast.show(
            currentContext,
            'Gruppo non trovato',
            type: ToastType.error,
          );
        }
        return;
      }

      // Navigate to home if not already there
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        // Pop all routes to get to home
        navigator.popUntil((route) => route.isFirst);

        // Wait a bit for the navigation to complete
        await Future.delayed(const Duration(milliseconds: 300));

        // Navigate to group detail page
        final currentContext = navigatorKey.currentContext;
        if (currentContext != null && currentContext.mounted) {
          await navigator.push(
            MaterialPageRoute(
              builder: (ctx) => ExpenseGroupDetailPage(trip: group),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening group detail: $e');
    }
  }

  /// Shows the add expense bottom sheet
  static void _showAddExpenseSheet(
    BuildContext context,
    ExpenseGroup group,
    ExpenseGroupNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer<ExpenseGroupNotifier>(
        builder: (context, groupNotifier, child) {
          final currentGroup = groupNotifier.currentGroup ?? group;
          return ExpenseEntrySheet(
            group: currentGroup,
            fullEdit: false,
            showGroupHeader: false,
            onExpenseSaved: (expense) async {
              final nav = Navigator.of(sheetContext);
              final gloc = gen.AppLocalizations.of(sheetContext);

              final expenseWithId = expense.copyWith(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
              );

              // Persist using the new storage API
              await ExpenseGroupStorageV2.addExpenseToGroup(
                currentGroup.id,
                expenseWithId,
              );

              // Refresh notifier state and notify UI
              await groupNotifier.refreshGroup();
              groupNotifier.notifyGroupUpdated(currentGroup.id);

              // Check if we should prompt for rating
              RatingService.checkAndPromptForRating();

              if (!sheetContext.mounted) return;
              AppToast.show(
                sheetContext,
                gloc.expense_added_success,
                type: ToastType.success,
              );
              nav.pop();
            },
            onCategoryAdded: (categoryId) {
              // Category was added inline in the form, no need to do anything
              debugPrint('Category added: $categoryId');
            },
          );
        },
      ),
    );
  }
}
