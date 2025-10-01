# Android Quick Actions - Architecture Overview

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Android Launcher                         │
│                    (Long-press app icon)                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Tap Shortcut
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        MainActivity.kt                           │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ onNewIntent() / onCreate()                                 │  │
│  │   - Extracts groupId & groupTitle from Intent             │  │
│  │   - Stores pending action if Flutter not ready            │  │
│  └─────────────────────┬─────────────────────────────────────┘  │
└────────────────────────┼────────────────────────────────────────┘
                         │ MethodChannel
                         │ "onShortcutTapped"
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   app_shortcuts_service.dart                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ _handleMethodCall()                                        │  │
│  │   - Receives shortcut tap event                           │  │
│  │   - Invokes callback with group info                      │  │
│  └─────────────────────┬─────────────────────────────────────┘  │
└────────────────────────┼────────────────────────────────────────┘
                         │ Callback
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                          main.dart                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ _handleShortcutTap()                                       │  │
│  │   - Loads group from storage                              │  │
│  │   - Navigates to ExpenseGroupDetailPage                   │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow for Shortcut Updates

```
┌─────────────────────────────────────────────────────────────────┐
│                      User Action                                 │
│  (Create/Update/Delete/Pin/Archive Group)                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                 ExpenseGroupStorageV2 / Notifier                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ updateGroupPin() / updateGroupArchive()                    │  │
│  │ notifyGroupUpdated() / notifyGroupDeleted()               │  │
│  │   - Calls _updateShortcuts()                              │  │
│  └─────────────────────┬─────────────────────────────────────┘  │
└────────────────────────┼────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                   AppShortcutsService.dart                       │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ updateShortcuts()                                          │  │
│  │   - Loads active groups from storage                      │  │
│  │   - Converts to shortcut data format                      │  │
│  │   - Sends to Android via MethodChannel                    │  │
│  └─────────────────────┬─────────────────────────────────────┘  │
└────────────────────────┼────────────────────────────────────────┘
                         │ MethodChannel
                         │ "updateShortcuts"
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                        MainActivity.kt                           │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ setMethodCallHandler("updateShortcuts")                    │  │
│  │   - Parses group data                                     │  │
│  │   - Calls ShortcutManager.updateShortcuts()               │  │
│  └─────────────────────┬─────────────────────────────────────┘  │
└────────────────────────┼────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                     ShortcutManager.kt                           │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ updateShortcuts()                                          │  │
│  │   1. Filter pinned group (if any)                         │  │
│  │   2. Sort remaining groups by timestamp                   │  │
│  │   3. Take up to 4 total shortcuts                         │  │
│  │   4. Create ShortcutInfoCompat objects                    │  │
│  │   5. Update dynamic shortcuts via ShortcutManagerCompat   │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Android System                              │
│                  (Displays shortcuts on launcher)                │
└─────────────────────────────────────────────────────────────────┘
```

## Shortcut Priority Logic

```
Priority 1: Pinned Group (📌)
    - Always appears first if exists
    - Marked with pin emoji
    - Excluded from "recent" list

Priority 2-4: Most Recently Updated Groups
    - Sorted by timestamp (descending)
    - Maximum 3 groups
    - Excludes pinned group
    - Only active (non-archived) groups

Total: Maximum 4 shortcuts
```

## Integration Points

1. **Group Creation** → `GroupFormController.save()` → `notifyGroupUpdated()` → Updates shortcuts
2. **Group Update** → `ExpenseGroupStorageV2.updateGroupMetadata()` → Updates shortcuts
3. **Group Deletion** → `GroupFormController.deleteGroup()` → `notifyGroupDeleted()` → Updates shortcuts
4. **Pin Toggle** → `ExpenseGroupStorageV2.updateGroupPin()` → Updates shortcuts
5. **Archive Toggle** → `ExpenseGroupStorageV2.updateGroupArchive()` → Updates shortcuts
6. **App Startup** → `HomePage._loadLocaleAndTrip()` → Updates shortcuts

## Error Handling

- All shortcut operations fail silently
- Shortcuts are non-critical to app functionality
- Platform check ensures Android-only execution
- API level check (Android 7.1+) performed before operations
