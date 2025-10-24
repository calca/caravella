import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/expense_group.dart';
import '../../l10n/app_localizations.dart' as gen;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'expense_tracking_channel';
  static const String _channelName = 'Expense Tracking';
  static const String _channelDescription =
      'Persistent notifications for expense group tracking';
  static const int _notificationId = 1000;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.actionId}');
    // TODO: Handle navigation based on action
    // 'add_expense' -> open add expense page
    // null -> open home page
  }

  Future<void> showGroupNotification(
    ExpenseGroup group,
    gen.AppLocalizations loc,
  ) async {
    await initialize();

    // Calculate daily and total spent
    final totalSpent = group.expenses.fold<double>(
      0.0,
      (sum, expense) => sum + (expense.amount ?? 0.0),
    );

    // Calculate daily average
    double dailyAverage = 0.0;
    if (group.startDate != null && group.endDate != null) {
      final days = group.endDate!.difference(group.startDate!).inDays + 1;
      if (days > 0) {
        dailyAverage = totalSpent / days;
      }
    }

    // Format period
    String period = '';
    if (group.startDate != null && group.endDate != null) {
      final start = '${group.startDate!.day}/${group.startDate!.month}';
      final end = '${group.endDate!.day}/${group.endDate!.month}';
      period = '$start - $end';
    }

    // Build notification content
    final title = group.title.isEmpty ? loc.new_expense_group : group.title;
    final titleWithPeriod = period.isEmpty ? title : '$title ($period)';
    
    final dailyText = loc.notification_daily_spent(
      dailyAverage.toStringAsFixed(2),
      group.currency,
    );
    final totalText = loc.notification_total_spent(
      totalSpent.toStringAsFixed(2),
      group.currency,
    );
    final content = '$dailyText\n$totalText';

    // Calculate progress for groups with start and end dates
    int? progress;
    int? maxProgress;
    bool showProgress = false;
    
    if (group.startDate != null && group.endDate != null) {
      final now = DateTime.now();
      final start = group.startDate!;
      final end = group.endDate!;
      
      // Total days in the trip (inclusive)
      final totalDays = end.difference(start).inDays + 1;
      
      // Days elapsed from start to now (clamped between 0 and totalDays)
      final elapsedDays = now.difference(start).inDays + 1;
      
      if (totalDays > 0) {
        maxProgress = totalDays;
        progress = elapsedDays.clamp(0, totalDays);
        showProgress = true;
      }
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      // Make notification non-dismissible by setting onlyAlertOnce to true
      // and not allowing user to dismiss via swipe
      onlyAlertOnce: true,
      // Progress indicator for date-based tracking
      showProgress: showProgress,
      maxProgress: maxProgress ?? 0,
      progress: progress ?? 0,
      indeterminate: false,
      actions: [
        AndroidNotificationAction(
          'add_expense',
          loc.notification_add_expense,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'close',
          loc.notification_close,
          cancelNotification: true,
        ),
      ],
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      _notificationId,
      titleWithPeriod,
      content,
      details,
    );
  }

  Future<void> cancelGroupNotification() async {
    await _notifications.cancel(_notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
