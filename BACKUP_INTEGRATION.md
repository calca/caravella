# Native Backup Integration Documentation

## Overview
The automatic backup toggle in Caravella now integrates with native operating system backup functionality:

- **Android**: Uses Android's Auto Backup for Apps feature
- **iOS**: Controls iCloud/iTunes backup inclusion via NSURLIsExcludedFromBackupKey

## Android Implementation

### Auto Backup for Apps
Android's Auto Backup for Apps automatically backs up app data to the user's Google Drive account. Our implementation:

1. **AndroidManifest.xml Configuration**:
   ```xml
   <application
       android:allowBackup="true"
       android:fullBackupContent="@xml/backup_rules">
   ```

2. **Backup Rules** (`android/app/src/main/res/xml/backup_rules.xml`):
   - Includes shared preferences, databases, and app files
   - Excludes sensitive data like FlutterSecureStorage

3. **BackupManager Integration**:
   - `requestBackup()`: Triggers immediate backup to Google Drive
   - `isBackupEnabled()`: Checks if backup is available (always true when allowBackup=true)

### What Gets Backed Up
- SharedPreferences (app settings, user preferences)
- SQLite databases (if any)
- Internal app files
- User data stored in app directories

### User Control
- Users can disable app backup in Android Settings > Google > Backup
- The toggle in Caravella triggers immediate backup when enabled
- Android handles automatic periodic backups in the background

## iOS Implementation

### iCloud/iTunes Backup
iOS automatically backs up app data to iCloud or iTunes. Our implementation controls this via:

1. **NSURLIsExcludedFromBackupKey**:
   - Controls whether app's Documents directory is included in backups
   - Toggle enabled = app data included in iCloud backup
   - Toggle disabled = app data excluded from backups

2. **Documents Directory**:
   - Primary location for user-generated content
   - Automatically backed up to iCloud unless explicitly excluded
   - Restored when user sets up new device or restores from backup

### What Gets Backed Up
- Files in Documents directory (expense groups, settings, user data)
- App-specific data that users would expect to be preserved
- User preferences and app state

### User Control
- Users control iCloud backup in iOS Settings > [User] > iCloud > iCloud Backup
- The toggle in Caravella controls whether THIS app's data is included
- iOS handles automatic daily backups when device is connected to power, Wi-Fi, and locked

## Platform Service Architecture

### BackupService (`lib/settings/backup_service.dart`)
Unified interface for both platforms:

```dart
// Check if backup is enabled
bool enabled = await BackupService.isBackupEnabled();

// Enable/disable backup
bool success = await BackupService.setBackupEnabled(true);

// Request immediate backup (Android only)
bool requested = await BackupService.requestBackup();
```

### Error Handling
- Platform method failures are handled gracefully
- UI toggle reflects actual platform state when possible
- Fallback behavior ensures app continues working even if backup fails

### Method Channels
- **Android**: `org.app.caravella/backup` channel with Kotlin implementation
- **iOS**: Same channel with Swift implementation
- Cross-platform method calls handled transparently by Flutter

## Benefits for Users

### Android Users
- Expense groups and settings automatically backed up to Google Drive
- Seamless restore when setting up new Android device
- No manual backup/restore process needed
- Works across all Android devices signed into same Google account

### iOS Users  
- App data included in iCloud/iTunes backups
- Automatic restore when setting up new iPhone/iPad
- Consistent with other iOS app backup behavior
- Works with both iCloud and iTunes backup methods

## Testing the Feature

### Android Testing
1. Enable the toggle in Caravella settings
2. Go to Android Settings > Google > Backup > App data
3. Verify Caravella is listed and backup is scheduled
4. Force backup in Google backup settings to test immediately

### iOS Testing
1. Enable the toggle in Caravella settings  
2. Check that Documents directory backup exclusion is removed
3. Trigger iCloud backup in iOS Settings
4. Verify app data is included in backup size calculations

### Restore Testing
- Install app on new device
- Sign into same Google/iCloud account
- Restore from backup and verify expense groups are restored
- Settings and preferences should be preserved

## Security Considerations

### What's NOT Backed Up
- FlutterSecureStorage content (excluded on Android)
- Temporary files and caches
- Platform-specific sensitive data

### Privacy
- Backup data is encrypted in transit and at rest
- Only accessible to same user account
- Follows platform security standards (Google/Apple encryption)

### User Control
- Users can disable backup entirely at OS level
- App-level toggle provides granular control for this specific app
- No backup occurs without user's explicit or implied consent