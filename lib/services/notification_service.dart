import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

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

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

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

  /// Extracts initials from the expense group title
  String _getInitials(String title) {
    if (title.isEmpty) return '?';

    final words = title.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';

    if (words.length == 1) {
      // Single word: take first 2 characters
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    } else {
      // Multiple words: take first character of first two words
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
  }

  /// Generates a bitmap image with the initials as a large icon
  Future<Uint8List?> _generateInitialsIcon(
    String initials,
    Color? groupColor,
  ) async {
    try {
      final size = 192.0; // Android notification large icon size
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Use group color or default teal color
      final bgColor = groupColor ?? const Color(0xFF009688);

      // Draw circle background
      final paint = Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

      // Draw text
      final textPainter = TextPainter(
        text: TextSpan(
          text: initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();

      final textOffset = Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      );
      textPainter.paint(canvas, textOffset);

      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error generating initials icon: $e');
      return null;
    }
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

    // Generate large icon with initials
    final initials = _getInitials(title);
    final iconColor = group.color != null ? Color(group.color!) : null;
    final largeIconBytes = await _generateInitialsIcon(initials, iconColor);
    final largeIcon = largeIconBytes != null
        ? ByteArrayAndroidBitmap(largeIconBytes)
        : null;

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
      // Large icon with expense group initials
      largeIcon: largeIcon,
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
