# Android Quick Actions (App Shortcuts)

This feature implements Android App Shortcuts (Quick Actions) that appear when the user long-presses the Caravella app icon on the launcher.

## Overview

The Quick Actions show:
1. **Pinned Group** (if available) - Marked with a 📌 emoji
2. **2-3 Most Recently Updated Groups** - Sorted by timestamp

When tapped, each shortcut opens the app and navigates directly to the expense detail page for that group, allowing users to quickly add expenses.

## Implementation

### Android Side (Kotlin)

**ShortcutManager.kt**
- Manages dynamic shortcuts using AndroidX ShortcutManagerCompat
- Creates shortcut entries with group information
- Supports up to 4 shortcuts (1 pinned + 3 recent)
- Uses `ic_menu_add` icon for all shortcuts
- Requires Android 7.1 (API 25) or higher

**MainActivity.kt**
- Handles shortcut intent actions (`io.caravella.egm.ADD_EXPENSE`)
- Sets up MethodChannel communication with Flutter
- Forwards shortcut tap events to Flutter side

### Flutter Side (Dart)

**app_shortcuts_service.dart**
- Service to manage shortcuts from Flutter
- Provides methods to update and clear shortcuts
- Handles communication with Android via MethodChannel
- Only active on Android platform

**Integration Points:**
1. **main.dart** - Initializes shortcuts on app startup and handles navigation
2. **ExpenseGroupNotifier** - Triggers shortcut updates when groups are modified
3. **HomePage** - Updates shortcuts when data is loaded

## Usage

Shortcuts are automatically managed:
- **Created/Updated**: When groups are created, modified, or loaded
- **Cleared**: When the app is uninstalled or data is cleared
- **Tapped**: Opens the app and navigates to the group detail page

## Technical Details

### Communication Flow

1. User taps shortcut on launcher
2. Android launches MainActivity with intent action
3. MainActivity extracts groupId and groupTitle
4. Intent data sent to Flutter via MethodChannel
5. Flutter loads group from storage
6. Navigator pushes ExpenseGroupDetailPage

### Shortcut Update Triggers

Shortcuts are updated when:
- App starts (HomePage initialization)
- Group metadata is updated (pin status, title, etc.)
- Group is created or deleted
- Group timestamp changes

## Testing

To test shortcuts:
1. Build and install the app on an Android 7.1+ device/emulator
2. Create some expense groups
3. Pin one group (optional)
4. Long-press the app icon on the launcher
5. Verify shortcuts appear with correct titles
6. Tap a shortcut to verify navigation works

## Limitations

- Maximum 4 shortcuts (Android system limit for dynamic shortcuts)
- Only available on Android 7.1 (API 25) and higher
- Shortcuts are cleared when app data is cleared
- Short labels are truncated to 25 characters
- Long labels are truncated to 125 characters
