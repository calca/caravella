# Google Play Store Auto-Update Feature

## Quick Start

### For Users
1. Open the Caravella app
2. Go to **Settings** (⚙️)
3. Scroll to the **Info** section
4. Tap **"Check for updates"** (or **"Controlla aggiornamenti"** in Italian)
5. If an update is available, tap **"Update now"**
6. Wait for the download to complete
7. Restart the app to apply the update

### For Developers

#### Running the App
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run --flavor prod --dart-define=FLAVOR=prod
```

#### Building for Release
```bash
# Build production APK
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod

# Build AAB for Google Play
flutter build appbundle --flavor prod --release --dart-define=FLAVOR=prod
```

#### Testing the Update Feature
**Important**: The in-app update feature only works with apps distributed through Google Play Store. It will not work with debug builds or sideloaded APKs.

1. Upload a version to Google Play Console (internal testing track)
2. Install that version on a test device from Play Store
3. Upload a newer version to Play Console
4. Wait for it to be available (can take a few hours)
5. Open the app on the test device
6. Navigate to Settings > Check for updates
7. Verify the update is detected and can be installed

## Technical Details

### Package Used
- **in_app_update** version 4.2.3
- Official Flutter wrapper for Google Play Core Library
- Handles both flexible and immediate updates

### Architecture
The feature is built in a dedicated package under `lib/updates/`:

```
lib/updates/
├── app_update_service.dart      # Core service with static methods
├── app_update_notifier.dart     # State management with Provider
└── README.md                    # Detailed documentation
```

### Integration Points
1. **Settings Page**: Added new row in Info section
2. **Localization**: 13 new keys in 5 languages (IT, EN, ES, PT, ZH)
3. **Dependencies**: Added in_app_update package

### Update Types
- **Flexible Update** (default): Downloads in background, user continues using app
- **Immediate Update**: Blocks app usage until update completes (not exposed in UI)

### Platform Support
- ✅ **Android**: Full support with Google Play Services
- ❌ **iOS**: Not supported (uses App Store's built-in mechanism)
- ❌ **Other platforms**: Not applicable

## API Reference

### AppUpdateService
Static service class for update operations:

```dart
// Check if update is available
AppUpdateInfo? updateInfo = await AppUpdateService.checkForUpdate();

// Start flexible update
bool success = await AppUpdateService.startFlexibleUpdate();

// Complete flexible update (install)
bool success = await AppUpdateService.completeFlexibleUpdate();

// Start immediate update
bool success = await AppUpdateService.startImmediateUpdate();

// Get detailed status
Map<String, dynamic> status = await AppUpdateService.getUpdateStatus();
```

### AppUpdateNotifier
State management with Provider:

```dart
// Create notifier
final notifier = AppUpdateNotifier();

// Check for update
await notifier.checkForUpdate();

// Access state
bool isChecking = notifier.isChecking;
bool updateAvailable = notifier.updateAvailable;
String? version = notifier.availableVersion;
String? error = notifier.error;

// Start update
await notifier.startFlexibleUpdate();
await notifier.completeFlexibleUpdate();
```

## Localization Keys

New keys added in all supported languages (IT, EN, ES, PT, ZH):
- `check_for_updates` - Main action label
- `check_for_updates_desc` - Description
- `update_available` - Update available title
- `update_available_desc` - Update available description
- `no_update_available` - Up to date message
- `no_update_available_desc` - Up to date description
- `update_now` - Update button
- `update_later` - Postpone button
- `checking_for_updates` - Checking status
- `update_error` - Error message
- `update_downloading` - Download status
- `update_installing` - Install status
- `update_feature_android_only` - Platform limitation message

## UI States

The update button shows different states:

1. **Default**: "Check for updates" with forward arrow
2. **Checking**: Progress indicator with "Checking for updates..."
3. **Available**: "Update available" with "Update now" button (primary color)
4. **Downloading**: Progress indicator with "Downloading..."
5. **Installing**: Progress indicator with "Installing..."
6. **Error**: Error message in red
7. **Up to date**: "App up to date" message
8. **Not available** (non-Android): Disabled with explanation message

## Error Handling

The implementation gracefully handles:
- Missing Google Play Services
- Network errors
- Update download failures
- Installation errors
- Platform limitations (non-Android)
- User cancellations

Errors are displayed to the user via:
- SnackBar notifications
- Status text in the settings row
- Error state in the notifier

## Troubleshooting

### Update not detected
- Verify app is installed from Google Play Store
- Check that newer version is published in Play Console
- Wait a few hours for Play Store to propagate the update
- Try clearing Google Play Store cache

### Update fails to install
- Ensure sufficient storage space
- Check internet connection
- Restart device and try again
- Verify Google Play Services is up to date

### Feature not working
- Confirm device is Android
- Verify Google Play Services is installed and enabled
- Check that app was installed from Play Store (not sideloaded)
- Review logcat for error messages

## License

This implementation uses the MIT-licensed `in_app_update` package and follows the same license as the Caravella app.
