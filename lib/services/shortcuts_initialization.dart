import 'package:flutter/material.dart';
import 'platform_shortcuts_manager.dart';
import '../manager/details/pages/expense_group_detail_page.dart';

/// Global navigator key for deep linking from shortcuts
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Handles shortcuts initialization and deep linking
class ShortcutsInitialization {
  /// Initialize shortcuts service after app starts
  static void initialize() {
    PlatformShortcutsManager.initialize((groupId, groupTitle) {
      // Handle shortcut tap - navigate to expense creation for the specified group
      final context = navigatorKey.currentContext;
      if (context != null) {
        _handleShortcutTap(context, groupId, groupTitle);
      }
    });

    // Update shortcuts with current data
    PlatformShortcutsManager.updateShortcuts();
  }

  static void _handleShortcutTap(
    BuildContext context,
    String groupId,
    String groupTitle,
  ) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    try {
      // Load the group from storage
      final group = await ExpenseGroupStorageV2.getTripById(groupId);

      // Check if context is still mounted after async operation
      if (!context.mounted) return;

      if (group == null) {
        // Group not found, show error
        AppToast.show(
          context,
          'Group not found: $groupTitle',
          type: ToastType.error,
        );
        return;
      }

      // Navigate to ExpenseGroupDetailPage
      await navigator.push(
        MaterialPageRoute(
          builder: (ctx) => ExpenseGroupDetailPage(trip: group),
        ),
      );
    } catch (e) {
      // Check if context is still mounted before showing error
      if (!context.mounted) return;

      // Show generic error
      AppToast.show(context, 'Unable to open group', type: ToastType.error);
    }
  }
}
