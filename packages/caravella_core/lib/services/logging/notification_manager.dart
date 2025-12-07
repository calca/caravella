import 'package:flutter/foundation.dart';
import '../../model/expense_group.dart';
import 'notification_service.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Helper class to manage notification updates when expense groups change
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationService _notificationService = NotificationService();

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
}
