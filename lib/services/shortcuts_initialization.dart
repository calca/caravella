import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

import '../manager/details/pages/expense_group_detail_page.dart';

/// Service for initializing and managing platform shortcuts
/// This provides the UI-specific implementation for the core shortcuts navigation service
class ShortcutsInitialization {
  /// Initialize shortcuts with the UI-specific navigation callbacks
  static Future<void> initialize() async {
    // Configure the navigation service with UI-specific callbacks
    ShortcutsNavigationService.configure(
      onNavigateToGroup: _navigateToGroup,
      onShowError: _showError,
    );

    // Initialize platform shortcuts manager
    await PlatformShortcutsManager.initialize(
      ShortcutsNavigationService.handleShortcutTap,
    );

    // Update shortcuts with current data
    await PlatformShortcutsManager.updateShortcuts();
  }

  /// Navigate to the group detail page (UI implementation)
  static Future<void> _navigateToGroup(
    BuildContext context,
    ExpenseGroup group,
  ) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    await navigator.push(
      MaterialPageRoute(builder: (ctx) => ExpenseGroupDetailPage(trip: group)),
    );
  }

  /// Show error message using app toast (UI implementation)
  static void _showError(BuildContext context, String message) {
    AppToast.show(context, message, type: ToastType.error);
  }
}
