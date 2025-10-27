# Auto-Update from Google Play Store

This package implements automatic update checking and installation from Google Play Store using the `in_app_update` package.

## Features

- **Automatic Update Check**: Check if a new version is available on Google Play Store
- **Flexible Updates**: Allow users to download updates in the background while continuing to use the app
- **Immediate Updates**: Force users to update before continuing (for critical updates)
- **State Management**: Reactive state management with Provider for UI updates
- **Multi-language Support**: Localized strings for IT, EN, ES, PT, and ZH

## Architecture

### Components

1. **AppUpdateService** (`app_update_service.dart`)
   - Core service for interacting with Google Play In-App Updates API
   - Methods:
     - `checkForUpdate()`: Check if an update is available
     - `startFlexibleUpdate()`: Start a flexible update (background download)
     - `completeFlexibleUpdate()`: Complete and install a flexible update
     - `startImmediateUpdate()`: Start an immediate update (blocking)
     - `getUpdateStatus()`: Get detailed update status information

2. **AppUpdateNotifier** (`app_update_notifier.dart`)
   - State management for update flow using ChangeNotifier
   - Tracks:
     - Update availability
     - Download/installation progress
     - Error states
     - Update metadata (version, priority)

### Integration

The update check is integrated into the Settings page:
- Settings > Info > Check for updates
- Shows current update status
- Allows users to manually trigger update checks
- Displays appropriate UI based on state (checking, available, downloading, etc.)

## Platform Support

- **Android**: Full support with Google Play Services
- **iOS**: Not supported (uses App Store's built-in update mechanism)
- **Other platforms**: Not applicable

## Usage

### Manual Check

Users can manually check for updates from the Settings page:
1. Open Settings
2. Scroll to "Info" section
3. Tap "Check for updates"
4. If an update is available, tap "Update now"

### Update Flow

1. **Check**: App queries Google Play for available updates
2. **Download**: If available, user can start a flexible update (background download)
3. **Install**: Once downloaded, app prompts to complete update (requires restart)

## Implementation Details

### Flexible vs Immediate Updates

- **Flexible**: 
  - User can continue using the app while update downloads
  - Non-blocking experience
  - Recommended for most updates
  
- **Immediate**:
  - Blocks app usage until update is installed
  - Should only be used for critical updates
  - Currently not exposed in UI (can be enabled if needed)

### Error Handling

- Gracefully handles missing Google Play Services
- Silent failure on non-Android platforms
- User-friendly error messages for network or other issues

## Localization Keys

New localization keys added:
- `check_for_updates`: "Check for updates"
- `check_for_updates_desc`: Description text
- `update_available`: "Update available"
- `update_available_desc`: Update available description
- `no_update_available`: "App up to date"
- `no_update_available_desc`: No update description
- `update_now`: "Update now" button
- `update_later`: "Later" button
- `checking_for_updates`: Checking status
- `update_error`: Error message
- `update_downloading`: Download status
- `update_installing`: Install status
- `update_feature_android_only`: Platform limitation message

## Testing

### Unit Tests
- `test/app_update_notifier_test.dart`: Tests for state management

### Manual Testing
To test the update flow:
1. Build and upload a version to Google Play (internal testing track)
2. Install the app on a device
3. Upload a new version with higher version code
4. Open app and go to Settings > Check for updates
5. Verify update detection and installation flow

**Note**: Testing requires actual Google Play Store distribution as the API only works with published apps.

## Dependencies

- `in_app_update: ^4.2.3` - Official Google Play In-App Updates library

## Future Enhancements

Possible future improvements:
- Automatic background checks on app launch
- Configurable update frequency
- Update notification badges
- Support for immediate updates (if needed for critical patches)
- Analytics for update adoption rates
