# Notifications

Persistent, per-group notifications that respect a group's date range, plus quick actions. Covers `lib/services/notification_manager.dart` and `lib/services/notification_service.dart`.

## `NotificationManager` — orchestration

Singleton sitting between `ExpenseGroupNotifier`/UI and `NotificationService`.

- `_isWithinDateRange(group)` — `true` when either `startDate`/`endDate` is null (no constraint), or today falls inclusively between them.
- `updateNotificationForGroup(group)` — shows the notification only if `group.notificationEnabled` **and** `_isWithinDateRange(group)`; otherwise cancels it. This is what makes the notification "date-range-aware": a group with dates in the past or future won't show a sticky notification even if the toggle is on.
- `restoreNotifications(context)` (static) — reloads all active groups and re-shows notifications for every `notificationEnabled` one. Called exactly once, from `CaravellaHomePage`, right after app startup — see [App: Home](APP_HOME.md).
- `handleAddExpenseAction` / `handleDisableAction` / `handleOpenGroupDetail` (static) — notification-tap/action-button callbacks (see below). `_showAddExpenseSheet` opens `ExpenseEntrySheet` as a modal bottom sheet pre-bound to the group.

The notification-enabled toggle itself lives in `lib/manager/group/pages/expense_group_other_page.dart` — see [Group Management](APP_GROUP_MANAGEMENT.md).

## `NotificationService` — platform notification

Singleton wrapping `flutter_local_notifications`.

- `showGroupNotification` builds an `AndroidNotificationDetails` with `ongoing: true, autoCancel: false, onlyAlertOnce: true` — a sticky, non-dismissible notification.
- Computes a day-based progress bar (`showProgress`/`maxProgress`/`progress`) from `group.startDate`/`endDate` when both are set.
- Adds two `AndroidNotificationAction`s: `add_expense` and `disable`.
- `_onNotificationTap` dispatches by `actionId`: `add_expense` → `NotificationManager.handleAddExpenseAction`, `disable` → `.handleDisableAction`, tap on the body (`actionId == null`) → `.handleOpenGroupDetail`.
- Notification IDs are deterministic per group: `groupId.hashCode.abs() % 100000 + 1001` — so re-showing a notification for the same group always replaces the previous one rather than stacking duplicates.

## See also

- [App: Group Management § standalone edit pages](APP_GROUP_MANAGEMENT.md#standalone-edit-pages) — where notifications are enabled/disabled per group
- [App: Home](APP_HOME.md) — where notifications are restored on startup
- [App: Expense Entry](APP_EXPENSE_ENTRY.md) — voice-added expenses also call `NotificationManager().updateNotificationForGroupById` afterward
