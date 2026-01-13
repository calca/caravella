import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'notification_manager.dart';

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

  // Generate unique notification ID from group ID
  static int _getNotificationId(String groupId) {
    return groupId.hashCode.abs() % 100000 + 1001;
  }

  Future<void> initialize() async {
    if (_initialized) {
      LoggerService.debug(
        'NotificationService already initialized, skipping re-init',
        name: 'notification',
      );
      return;
    }

    const iconName = 'ic_notification';
    LoggerService.info(
      'Initializing notification plugin (icon=$iconName)',
      name: 'notification',
    );

    const androidSettings = AndroidInitializationSettings(iconName);
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _initialized = initialized ?? true;
      LoggerService.info(
        'Notification plugin initialized (result=$_initialized)',
        name: 'notification',
      );
    } catch (e, st) {
      LoggerService.error(
        'Failed to initialize notification plugin',
        name: 'notification',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
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
    LoggerService.debug(
      'Notification tapped: actionId=${response.actionId}, payload=${response.payload}',
      name: 'notification',
    );

    if (response.payload == null) return;

    final groupId = response.payload!;

    // Handle different actions
    if (response.actionId == 'add_expense') {
      // Add expense action button clicked
      LoggerService.debug('Add expense action triggered', name: 'notification');
      NotificationManager.handleAddExpenseAction(groupId);
    } else if (response.actionId == 'disable') {
      // Disable action button clicked
      LoggerService.debug('Disable action triggered', name: 'notification');
      NotificationManager.handleDisableAction(groupId);
    } else if (response.actionId == null) {
      // Notification body clicked (not an action button)
      LoggerService.debug(
        'Notification body clicked - opening group detail page',
        name: 'notification',
      );
      NotificationManager.handleOpenGroupDetail(groupId);
    }
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
      LoggerService.error(
        'Error generating initials icon',
        name: 'notification',
        error: e,
      );
      return null;
    }
  }

  Future<void> showGroupNotification(
    ExpenseGroup group,
    gen.AppLocalizations loc,
  ) async {
    await initialize();

    // Cancel any existing notification for this group first to prevent duplicates
    await cancelGroupNotification(group.id);

    // Calculate today's spent
    final now = DateTime.now();

    final todaySpent = group.expenses.fold<double>(0.0, (sum, expense) {
      final expenseDate = expense.date;
      // Check if expense is from today by comparing year, month, and day
      if (expenseDate.year == now.year &&
          expenseDate.month == now.month &&
          expenseDate.day == now.day) {
        return sum + (expense.amount ?? 0.0);
      }
      return sum;
    });

    // Build notification content
    final title = group.title.isEmpty ? loc.new_expense_group : group.title;
    final content = loc.notification_daily_spent(
      todaySpent.toStringAsFixed(2),
      group.currency,
    );

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
      // Small icon in notification bar (uses app launcher icon)
      icon: 'ic_notification',
      // Large icon with expense group initials
      largeIcon: largeIcon,
      actions: [
        AndroidNotificationAction(
          'add_expense',
          loc.notification_add_expense,
          showsUserInterface: true,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'disable',
          loc.notification_disable,
          showsUserInterface: true,
        ),
      ],
    );

    final details = NotificationDetails(android: androidDetails);
    final notificationId = _getNotificationId(group.id);

    try {
      await _notifications.show(
        notificationId,
        title,
        content,
        details,
        payload: group.id, // Pass group ID for navigation
      );

      LoggerService.debug(
        'Notification shown for group ${group.id} (id=$notificationId, todaySpent=$todaySpent)',
        name: 'notification',
      );
    } catch (e, st) {
      LoggerService.error(
        'Failed to show notification for group ${group.id}',
        name: 'notification',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> cancelGroupNotification(String groupId) async {
    final notificationId = _getNotificationId(groupId);
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
