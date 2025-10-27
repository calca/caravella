import 'package:flutter/material.dart';
import 'platform_shortcuts_manager.dart';
import '../data/expense_group_storage_v2.dart';
import '../manager/details/pages/expense_group_detail_page.dart';
import '../main/caravella_app.dart';

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
      if (group == null) {
        // Group not found, show error
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Group not found: $groupTitle'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Navigate to ExpenseGroupDetailPage
      await navigator.push(
        MaterialPageRoute(
          builder: (ctx) => ExpenseGroupDetailPage(trip: group),
        ),
      );
    } catch (e) {
      // Silently fail or show generic error
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Unable to open group'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
