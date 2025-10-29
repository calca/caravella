import 'package:flutter/material.dart';
import '../../data/expense_group_storage_v2.dart';
import '../../data/model/expense_group.dart';

/// Callback type for handling navigation to expense group detail
typedef NavigateToGroupCallback =
    Future<void> Function(BuildContext context, ExpenseGroup group);

/// Callback type for showing error messages
typedef ShowErrorCallback = void Function(BuildContext context, String message);

/// Global navigator key for deep linking from shortcuts
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Service for handling shortcuts navigation and deep linking
/// This service is decoupled from UI implementation through callbacks
class ShortcutsNavigationService {
  static NavigateToGroupCallback? _navigateToGroupCallback;
  static ShowErrorCallback? _showErrorCallback;

  /// Configure the navigation callbacks
  /// Must be called before using the service
  static void configure({
    required NavigateToGroupCallback onNavigateToGroup,
    required ShowErrorCallback onShowError,
  }) {
    _navigateToGroupCallback = onNavigateToGroup;
    _showErrorCallback = onShowError;
  }

  /// Handle shortcut tap by loading the group and invoking the navigation callback
  /// This method is synchronous and triggers async operations internally
  static void handleShortcutTap(String groupId, String groupTitle) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (_navigateToGroupCallback == null || _showErrorCallback == null) {
      throw StateError(
        'ShortcutsNavigationService not configured. Call configure() first.',
      );
    }

    // Trigger async operation without blocking
    _handleShortcutTapAsync(context, groupId, groupTitle);
  }

  /// Internal async handler for shortcut tap
  static Future<void> _handleShortcutTapAsync(
    BuildContext context,
    String groupId,
    String groupTitle,
  ) async {
    try {
      // Load the group from storage
      final group = await ExpenseGroupStorageV2.getTripById(groupId);

      // Check if context is still mounted after async operation
      if (!context.mounted) return;

      if (group == null) {
        // Group not found, show error
        _showErrorCallback!(context, 'Group not found: $groupTitle');
        return;
      }

      // Navigate using the provided callback
      await _navigateToGroupCallback!(context, group);
    } catch (e) {
      // Check if context is still mounted before showing error
      if (!context.mounted) return;

      // Show generic error
      _showErrorCallback!(context, 'Unable to open group');
    }
  }

  /// Reset configuration (useful for testing)
  static void reset() {
    _navigateToGroupCallback = null;
    _showErrorCallback = null;
  }
}
