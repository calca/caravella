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

  /// Checks if the current date is within the group's date range
  /// Returns true if:
  /// - Both startDate and endDate are null (no date range defined)
  /// - Only one of startDate or endDate is set (partial range - treated as no constraint)
  /// - Both dates are set AND current date is within [startDate, endDate] inclusive
  static bool _isWithinDateRange(ExpenseGroup group) {
    // If either date is missing, treat as no date range constraint
    // This handles: no dates set, or partial dates (only start OR only end)
    if (group.startDate == null || group.endDate == null) {
      return true;
    }

    // Both dates are set - check if today is within the range
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      group.startDate!.year,
      group.startDate!.month,
      group.startDate!.day,
    );
    final end = DateTime(
      group.endDate!.year,
      group.endDate!.month,
      group.endDate!.day,
    );

    // Check if today is within the date range (inclusive)
    return (today.isAfter(start) || today.isAtSameMomentAs(start)) &&
        (today.isBefore(end) || today.isAtSameMomentAs(end));
  }

  /// Updates the notification for a group if notifications are enabled
  /// and the current date is within the group's date range
  Future<void> updateNotificationForGroup(
    ExpenseGroup group,
    gen.AppLocalizations loc,
  ) async {
    if (!group.notificationEnabled) {
      return;
    }

    if (_isWithinDateRange(group)) {
      try {
        await _notificationService.showGroupNotification(group, loc);
      } catch (e) {
        LoggerService.error(
          'Failed to update notification for group ${group.id}',
          name: 'notification',
          error: e,
        );
      }
    } else {
      // Cancel notification if it's outside the date range
      try {
        await cancelNotificationForGroup(group.id);
      } catch (e) {
        LoggerService.error(
          'Failed to cancel notification for group ${group.id}',
          name: 'notification',
          error: e,
        );
      }
    }
  }

  /// Cancels the notification for a specific group
  Future<void> cancelNotificationForGroup(String groupId) async {
    try {
      await _notificationService.cancelGroupNotification(groupId);
    } catch (e) {
      LoggerService.error(
        'Failed to cancel notification for group $groupId',
        name: 'notification',
        error: e,
      );
    }
  }

  /// Restores notifications for all groups that have notifications enabled
  /// and are within their date range (if dates are set).
  /// Should be called at app startup to ensure notifications are displayed
  static Future<void> restoreNotifications(BuildContext context) async {
    try {
      // Get localizations before async operations
      final loc = gen.AppLocalizations.of(context);

      // Get all active (non-archived) groups
      final groups = await ExpenseGroupStorageV2.getActiveGroups();

      // Find all groups with notifications enabled
      final notificationEnabledGroups = groups
          .where((g) => g.notificationEnabled)
          .toList();

      LoggerService.info(
        'Restoring ${notificationEnabledGroups.length} notification(s)',
        name: 'notification',
      );

      // Show notification for each enabled group (date range check is done in updateNotificationForGroup)
      for (final group in notificationEnabledGroups) {
        LoggerService.info(
          'Restoring notification for group: ${group.title}',
          name: 'notification',
        );
        await NotificationManager().updateNotificationForGroup(group, loc);
      }
    } catch (e) {
      LoggerService.error(
        'Failed to restore notifications',
        name: 'notification',
        error: e,
      );
    }
  }

  /// Handles the "add expense" action from notification
  /// Navigates to home page and opens the add expense bottom sheet for the group
  static Future<void> handleAddExpenseAction(String groupId) async {
    try {
      // Get the navigation key from the app
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        LoggerService.warning(
          'Cannot navigate: context not available',
          name: 'notification',
        );
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
        LoggerService.warning(
          'Group not found: $groupId',
          name: 'notification',
        );
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
      LoggerService.error(
        'Error handling add expense action',
        name: 'notification',
        error: e,
      );
    }
  }

  /// Handles the "disable" action from notification
  /// Disables the notification setting for the group and cancels the notification
  static Future<void> handleDisableAction(String groupId) async {
    try {
      LoggerService.info(
        'Handling disable action for group: $groupId',
        name: 'notification',
      );

      // Get context for notifier before async operations
      final context = navigatorKey.currentContext;
      ExpenseGroupNotifier? notifier;

      if (context != null && context.mounted) {
        notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
      }

      // Load the expense group
      final group = await ExpenseGroupStorageV2.getTripById(groupId);
      if (group == null) {
        LoggerService.warning(
          'Group not found: $groupId',
          name: 'notification',
        );
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

      // Cancel the notification for this specific group
      await NotificationService().cancelGroupNotification(groupId);

      LoggerService.info(
        'Notification disabled for group: ${group.title}',
        name: 'notification',
      );
    } catch (e) {
      LoggerService.error(
        'Error handling disable action',
        name: 'notification',
        error: e,
      );
    }
  }

  /// Handles tapping on the notification body (not action buttons)
  /// Opens the expense group detail page
  static Future<void> handleOpenGroupDetail(String groupId) async {
    try {
      LoggerService.info(
        'Opening group detail for: $groupId',
        name: 'notification',
      );

      // Get the navigation key from the app
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        LoggerService.warning(
          'Cannot navigate: context not available',
          name: 'notification',
        );
        return;
      }

      // Load the expense group
      final group = await ExpenseGroupStorageV2.getTripById(groupId);
      if (group == null) {
        LoggerService.warning(
          'Group not found: $groupId',
          name: 'notification',
        );
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
      LoggerService.error(
        'Error opening group detail',
        name: 'notification',
        error: e,
      );
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
              LoggerService.debug(
                'Category added: $categoryId',
                name: 'notification',
              );
            },
          );
        },
      ),
    );
  }
}
