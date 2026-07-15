# Android Permissions Documentation

This document explains why each permission is requested and how it's used in the Caravella app.

## Required Permissions

### Storage Permissions
**Permissions**: `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`

**Purpose**: 
- Save expense groups, trips, and financial data locally on the device
- Enable backup and export functionality
- Allow users to select existing photos for group backgrounds

**Usage**:
- Core app functionality - storing user's expense data
- Data export features (CSV, JSON, ZIP backups)
- Optional photo selection for customizing group backgrounds

**User Control**: 
- Required for basic app functionality (data storage)
- Photo selection is optional - users can use the app without ever selecting photos

## Optional Permissions

### Camera Permission
**Permission**: `CAMERA`

**Purpose**: Allow users to take photos for group backgrounds and expense attachments

**Usage**:
- Taking photos for group/trip background images
- Capturing receipts or expense-related photos (future feature)
- Completely optional - app works fully without camera access

**User Control**:
- Only accessed when user explicitly chooses to take a photo
- App functions completely without camera permission
- Permission can be granted/revoked in device settings

**Code Implementation**: 
- Used in `BackgroundPicker` widget (`lib/manager/group/widgets/background_picker.dart`)
- Only triggered by user action (selecting "Take Photo" option)

### Location Permissions
**Permissions**: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`

**Purpose**: Allow users to add location context to expenses for better record-keeping

**Usage**:
- Adding location information to expense records
- Helping users remember where expenses occurred
- Reverse geocoding to get human-readable addresses
- Completely optional - app works fully without location access

**User Control**:
- Only accessed when user explicitly chooses to add location to an expense
- App functions completely without location permission
- Permission can be granted/revoked in device settings
- Each location access requires explicit user action

**Code Implementation**:
- Used in `LocationInputWidget` (`lib/manager/expense/expense_form/location_input_widget.dart`)
- Only triggered when user taps the location button in expense form
- Proper permission checking and user feedback implemented

### Wi-Fi / Bluetooth Permissions (Device Sync)
**Permissions**: `ACCESS_WIFI_STATE`, `CHANGE_WIFI_MULTICAST_STATE`, `BLUETOOTH` / `BLUETOOTH_ADMIN` (legacy, API ≤ 30), `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`, `BLUETOOTH_ADVERTISE` (API 31+), `NEARBY_WIFI_DEVICES` (API 33+)

**Purpose**: Allow a group's expense data to sync directly between the user's own devices, without any account or server

**Usage**:
- Wi-Fi (LAN) sync auto-discovers other Caravella installs on the same network via mDNS, but only exchanges data with a device once the user has paired it by scanning a QR code it displays (`packages/caravella_core/lib/sync/channels/lan_sync_channel.dart`) — unpaired devices are discovered but never synced with
- Bluetooth sync (`lib/sync/bluetooth_sync_channel.dart`) requires the user to manually pick a nearby device each time; nothing happens automatically
- Completely optional — sync is off by default and enabled per group

**User Control**:
- Bluetooth/nearby-device permissions (API 31+/33+) are requested at runtime immediately before starting discovery, not at app install/launch
- Sync itself requires opting in per group (a group-settings toggle) — the app has full functionality with sync never enabled
- Permissions can be granted/revoked in device settings; sync degrades to a clear in-app error if denied, it doesn't crash

**Code Implementation**:
- Runtime permission request: `BluetoothSyncChannel.requestPermissions()` (`lib/sync/bluetooth_sync_channel.dart`)
- LAN discovery/advertising: `LanSyncChannel` (`packages/caravella_core/lib/sync/channels/lan_sync_channel.dart`), using `bonsoir` (mDNS) — no dangerous-permission prompt on Android, since `ACCESS_WIFI_STATE`/`CHANGE_WIFI_MULTICAST_STATE` are normal-protection-level permissions

## Permission Best Practices Implemented

### Runtime Permission Requests
- All optional permissions are requested at runtime when needed
- Users see clear context for why permission is needed
- Graceful handling when permissions are denied

### Permission Checking
```dart
// Example from location widget
LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
  // Handle denial gracefully
}
```

### User Feedback
- Clear error messages when permissions are denied
- App continues to function without optional permissions
- Users can change permission decisions at any time

### Android Manifest Configuration
- Permissions include clear comments explaining their purpose
- Optional hardware features marked as `android:required="false"`
- Appropriate SDK version restrictions for legacy permissions

## Google Play Store Compliance

### Data Safety Section Answers

**Does your app collect or share any of the required user data types?**
- Personal Info: No
- Financial Info: Yes (expense data — stored locally by default; only transmitted at all if the user explicitly enables per-group device sync, and then only to the user's own other devices and/or the user's own Google Drive, never to a server we operate — see "Optional Device Sync" in the privacy policy)
- Location: Yes (optional, when user chooses to add location to expenses)
- Photos and Videos: Yes (optional, when user chooses to add photos)

**Is all of the user data collected by your app encrypted in transit?**
- Expense, participant, and group data is not transmitted at all unless the user enables sync for a group. When it is:
  - **Wi-Fi (LAN) sync**: exchanged over plain HTTP within the local network (not TLS) — the local network itself is the trust boundary here, same as most LAN file-sharing tools; not exposed beyond it
  - **Bluetooth sync**: uses the Nearby Connections API's own authenticated, encrypted channel
  - **Google Drive sync (optional)**: sent over HTTPS to the Drive API, into the signed-in user's own account
- Location coordinates (only when the user searches for a place or uses reverse geocoding) are sent over HTTPS to OpenStreetMap's Nominatim service — see "Network Requests to Third-Party Services" below

**Do you provide a way for users to request that their data is deleted?**
- Yes (users can delete all data through app settings, or delete individual records)

### Privacy Policy Compliance
- Complete privacy policy available at https://calca.github.io/caravella/privacy-policy.html
- Covers all data collection and usage
- Explains user rights and controls
- GDPR and CCPA compliant

### Sensitive Permissions Justification

#### Location Permission
- **Feature**: Optional expense location tagging
- **Justification**: Helps users remember where expenses occurred for better record-keeping
- **User Benefit**: Enhanced expense context and organization
- **Alternative**: App works fully without location access

#### Camera Permission  
- **Feature**: Optional photo capture for backgrounds and attachments
- **Justification**: Allows customization and visual organization of expense groups
- **User Benefit**: Better visual organization and personalization
- **Alternative**: App works fully without camera access, users can select existing photos instead

## Security Measures

### Local Data Storage
- All user data stored locally on device by default
- Cloud synchronization (Google Drive) is opt-in, off by default, and — depending on how the specific build was compiled — may not be available at all; see "Optional Device Sync" in the privacy policy
- User has complete control over their data, including whether sync is ever enabled

### Data Encryption
- Backup files support encryption
- Secure storage practices following Android guidelines
- No sensitive data stored in plain text logs

### Minimal Data Collection
- Only collect data necessary for app functionality
- No analytics or tracking beyond basic app functionality
- No third-party sharing of expense, participant, or group data, with one narrow exception: if the user explicitly enables Google Drive sync, that data is sent to the Google Drive API — into the user's own Google account, never a third party in the ad-tracking/analytics sense, and never accessible to us

### Network Requests to Third-Party Services
Most optional features make direct network requests to third-party services that never include expense, participant, or group data:
- **OpenStreetMap Nominatim** (`nominatim.openstreetmap.org`): place search text and/or GPS coordinates, when the user searches for a location or uses auto-location on an expense
- **OpenStreetMap tile servers** (`tile.openstreetmap.org`): fetched when the map view is displayed
- **Unsplash API** (`api.unsplash.com`): background photo search text, when the user searches for a group background photo (optional, requires a build-time API key)

The one exception: **Google Drive API** (optional, off by default, requires explicit sign-in) — when enabled, this *does* transmit the user's expense/participant/group data for sync-enabled groups, over HTTPS, into a hidden app-private folder inside the signed-in user's own Google Drive. See [google_drive_sync package](../docs/PACKAGE_GOOGLE_DRIVE_SYNC.md) and its [setup guide](../docs/GOOGLE_DRIVE_SYNC_SETUP.md).

## Device Compatibility

### Smartphone-Only Installation
The Caravella app is optimized for smartphone form factors and is restricted to smartphone devices only.

**Supported Devices**:
- Small screen devices (320dp minimum width)
- Normal screen devices (typical smartphones)

**Excluded Devices**:
- Large screen devices (7-inch tablets)
- Extra-large screen devices (10-inch tablets and larger)

**Rationale**:
- The app UI is designed and optimized specifically for smartphone screens
- User experience is best on handheld devices
- This ensures consistent quality across all installations

**Implementation**: The AndroidManifest.xml uses `<supports-screens>` to exclude large and xlarge screens from installation eligibility on the Google Play Store.