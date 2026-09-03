import 'package:material_ui/material_ui.dart';
import '../../data/expense_group_storage_v2.dart';
import '../../model/expense_group.dart';

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

  /// Waits for [navigatorKey] to have a mounted context, polling briefly.
  ///
  /// Cold-start deep links (home-widget taps, shortcut taps) can be
  /// dispatched during app startup, before `runApp()` has attached the
  /// widget tree — at that point `navigatorKey.currentContext` is still
  /// null. Polling here bridges that gap instead of silently dropping the
  /// action. Returns null if no context becomes available within [timeout].
  static Future<BuildContext?> waitForNavigatorContext({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        return context;
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
    return null;
  }

  /// Handle shortcut tap by loading the group and invoking the navigation callback
  /// This method is synchronous and triggers async operations internally
  static void handleShortcutTap(String groupId, String groupTitle) {
    if (_navigateToGroupCallback == null || _showErrorCallback == null) {
      throw StateError(
        'ShortcutsNavigationService not configured. Call configure() first.',
      );
    }

    // Trigger async operation without blocking
    _handleShortcutTapAsync(groupId, groupTitle);
  }

  /// Internal async handler for shortcut tap
  static Future<void> _handleShortcutTapAsync(
    String groupId,
    String groupTitle,
  ) async {
    final context = await waitForNavigatorContext();
    if (context == null || !context.mounted) return;
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
