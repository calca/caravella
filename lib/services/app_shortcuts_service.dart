import 'dart:io';
import 'package:flutter/services.dart';
import '../data/model/expense_group.dart';
import '../data/expense_group_storage_v2.dart';

/// Service to manage Android app shortcuts (Quick Actions)
/// Updates shortcuts when groups are created, modified, or deleted
class AppShortcutsService {
  static const MethodChannel _channel =
      MethodChannel('io.caravella.egm/shortcuts');

  /// Callback function type for handling shortcut taps
  typedef ShortcutTapCallback = void Function(String groupId, String groupTitle);

  static ShortcutTapCallback? _onShortcutTapped;

  /// Initialize the shortcuts service and set up the callback handler
  static void initialize(ShortcutTapCallback callback) {
    if (!Platform.isAndroid) return;
    
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
    if (!Platform.isAndroid) return;

    try {
      // Get active groups from storage
      final groups = await ExpenseGroupStorageV2.getActiveGroups();
      
      // Convert to format expected by Android
      final shortcutData = groups.map((group) {
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

  /// Clear all shortcuts
  static Future<void> clearShortcuts() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod('clearShortcuts');
    } catch (e) {
      // Silently fail
    }
  }
}
