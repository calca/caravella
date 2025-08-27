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
- Financial Info: Yes (expense data - stored locally only, not shared)
- Location: Yes (optional, when user chooses to add location to expenses)
- Photos and Videos: Yes (optional, when user chooses to add photos)

**Is all of the user data collected by your app encrypted in transit?**
- Not applicable (no network transmission of user data)

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
- All user data stored locally on device
- No cloud synchronization or remote storage
- User has complete control over their data

### Data Encryption
- Backup files support encryption
- Secure storage practices following Android guidelines
- No sensitive data stored in plain text logs

### Minimal Data Collection
- Only collect data necessary for app functionality
- No analytics or tracking beyond basic app functionality
- No third-party data sharing