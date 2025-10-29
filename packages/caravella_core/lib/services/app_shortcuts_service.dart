import 'package:flutter/services.dart';
import 'package:caravella_core/caravella_core.dart';

/// Callback function type for handling shortcut taps
typedef ShortcutTapCallback = void Function(String groupId, String groupTitle);

/// Service to manage Android app shortcuts (Quick Actions)
/// Updates shortcuts when groups are created, modified, or deleted
/// Note: Platform checks are handled by PlatformShortcutsManager
class AppShortcutsService {
  static const MethodChannel _channel = MethodChannel(
    'io.caravella.egm/shortcuts',
  );

  static ShortcutTapCallback? _onShortcutTapped;

  /// Initialize the shortcuts service and set up the callback handler
  static void initialize(ShortcutTapCallback callback) {
    _onShortcutTapped = callback;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle method calls from Android
  static Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onShortcutTapped') {
      final args = call.arguments as Map<dynamic, dynamic>;
      final groupId = args['groupId'] as String?;
      final groupTitle = args['groupTitle'] as String?;

      if (groupId != null && groupTitle != null && _onShortcutTapped != null) {
        _onShortcutTapped!(groupId, groupTitle);
      }
    }
  }

  /// Update shortcuts based on current groups
  /// Shows pinned group + 2-3 most recently updated groups
  static Future<void> updateShortcuts() async {
    try {
      // Get active groups from storage
      final groups = await ExpenseGroupStorageV2.getActiveGroups();

      // Filter and sort groups in Dart - pass only 4 shortcuts to native
      final shortcutsToShow = _selectShortcutsToShow(groups);

      // Convert to format expected by Android
      final shortcutData = shortcutsToShow.map((group) {
        return {
          'id': group.id,
          'title': group.title,
          'isPinned': group.pinned,
          'lastUpdated': group.timestamp.millisecondsSinceEpoch,
        };
      }).toList();

      // Send to Android
      await _channel.invokeMethod('updateShortcuts', shortcutData);
    } catch (e) {
      // Silently fail - shortcuts are not critical
      // In production, you might want to log this
    }
  }

  /// Select up to 4 shortcuts: pinned group first, then 3 most recent
  static List<ExpenseGroup> _selectShortcutsToShow(List<ExpenseGroup> groups) {
    const maxShortcuts = 4;
    final result = <ExpenseGroup>[];

    // Add pinned group first if available
    final pinnedGroup = groups.where((g) => g.pinned).firstOrNull;
    if (pinnedGroup != null) {
      result.add(pinnedGroup);
    }

    // Add up to 3 most recently updated non-pinned groups
    final recentGroups = groups.where((g) => !g.pinned).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final remaining = maxShortcuts - result.length;
    result.addAll(recentGroups.take(remaining));

    return result;
  }

  /// Clear all shortcuts
  static Future<void> clearShortcuts() async {
    try {
      await _channel.invokeMethod('clearShortcuts');
    } catch (e) {
      // Silently fail
    }
  }
}
