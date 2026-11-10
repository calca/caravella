# Privacy Policy for Caravella

**Last updated: November 2026**

## Overview

Caravella is a group expense management application that helps you track shared expenses, trips, and participants. We are committed to protecting your privacy and being transparent about our data practices.

## Information We Collect

### Data You Provide
- **Group and Trip Information**: Names, descriptions, and details of expense groups or trips you create
- **Expense Records**: Details of expenses including amounts, categories, descriptions, and participant assignments
- **Participant Information**: Names and details of people you add to your groups
- **Location Data**: When you choose to add location information to expenses (optional)
- **Photos**: When you choose to add background images to groups or attach images to expenses (optional)
- **Voice Input**: When you choose to dictate an expense (optional)
- **Receipt Images**: When you choose to scan a receipt (optional)

### Data Collected Automatically
- **App Usage Data**: Basic app functionality and performance metrics
- **Device Information**: Basic device identifiers for app functionality

## How We Use Your Information

### Primary Uses
- **Core Functionality**: To provide expense tracking, group management, and calculation features
- **Data Synchronization**: To maintain your data across app sessions, and — only for groups you explicitly mark as shared — across devices (see "Optional Device Sync" below)
- **Backup and Export**: To enable data backup and export features

### Optional Device Sync
Caravella can optionally share a group with other people's devices or keep it in sync across your own. This is off by default, enabled group by group, and works two ways:

- **Direct device-to-device sync (Wi-Fi / Bluetooth)**: expense and group data for a synced group is exchanged directly between paired devices over your local Wi-Fi network or Bluetooth — never through a server we operate. Data is end-to-end encrypted, and each pairing only grants access to the group it was made for. Anyone you share a group with receives that group's data, including its expenses and participant names, on their device.
- **Google Drive relay (optional, off by default even when device sync is used)**: if you choose to also enable cloud sync and sign in with your own Google account, a copy of your synced groups' data is stored in a hidden, app-private folder in *your own* Google Drive (not visible in your normal Drive file list, not accessible to other apps, and not accessible to us — we never receive or store this data on any server we operate). You can disable this and/or sign out at any time from Settings, and the app itself may not even offer this option — it depends on how the specific build you installed was compiled.

### Optional Google Drive Backup
In builds that offer it, you can back up your data to your own Google Drive, on demand or weekly. Backups are stored in the same hidden, app-private folder of your Google account described above, and we never receive them. Google Drive backup is off until you sign in and turn it on.

### Location Information
- **Optional Feature**: Location data is only collected when you explicitly choose to add location information to an expense
- **User Control**: You can use the app without ever providing location access
- **Purpose**: To help you remember where expenses occurred for better record-keeping

### Camera and Photos
- **Optional Feature**: Camera access is only used when you choose to take photos for group backgrounds or expense attachments
- **User Control**: You can use the app without ever providing camera access
- **Local Storage**: Photos are stored locally on your device

### Receipt Scanning
- **Optional Feature**: Receipt scanning only runs when you choose to scan a receipt
- **On-Device Processing**: Text is read from the image on your device; the image is not sent to us or to any third party

### Voice Input
- **Optional Feature**: The microphone is only used while you dictate an expense
- **Speech Recognition**: Caravella uses the speech recognition service of your device. Depending on your device and its settings, that service (for example Google's on most Android devices) may process your voice on the device or on its own servers, under its provider's privacy policy. Caravella does not record or store audio, and we never receive it

## Data Storage and Security

### Local Storage
- **Primary Storage**: All your data is stored locally on your device by default
- **No Automatic Cloud Sync**: Nothing leaves your device unless you explicitly enable sync for a specific group — see "Optional Device Sync" above. There is no company-run backend server; direct device sync stays between paired devices, and the optional Google Drive relay and backup store data only in your own Google account
- **User Control**: You control all data backups, exports, and whether sync is enabled at all

### Security Measures
- **Device Security**: Data security relies on your device's built-in security features
- **Backup Files**: Backup and export files are not encrypted; keep them somewhere safe
- **No Required Accounts**: The app is fully usable with no account of any kind. A Google account is only needed if you specifically opt in to the optional Google Drive sync relay or backup described above

## Data Sharing

### No Third-Party Sharing of Your Personal Data
- We do not share, sell, or transfer your expense, participant, or group data to third parties
- We do not use advertising networks or analytics/tracking services
- We do not have access to your data: it stays on your device, on the devices you pair with, and in your own Google account if you enable Google Drive

### Third-Party Services Used by Optional Features
A small number of features make direct network requests from your device to third-party services. Most of these never include your expense/group/participant data — they only send the minimum needed to fulfill the request (search text, coordinates, or an image request):
- **OpenStreetMap (Nominatim)**: When you search for a location or use auto-location for an expense, the search text or GPS coordinates are sent to `nominatim.openstreetmap.org` to resolve place names/addresses. See the [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/).
- **OpenStreetMap map tiles**: When you view the map, map tile images are fetched from `tile.openstreetmap.org`.
- **Unsplash**: When you search for a background photo for a group, your search text is sent to `api.unsplash.com` to retrieve matching images. This feature is only available in builds configured with an Unsplash API key.
- **Google Play**: Builds installed from Google Play use Google Play services to offer in-app updates and rating prompts.

The OpenStreetMap and Unsplash requests are only made when you actively use the corresponding feature (location search/auto-location, map view, or background photo search) and only contain the search text or coordinates needed to fulfill that request — never your expense records or participant names.

**The exceptions are optional Google Drive sync and backup, and voice input.** When you explicitly enable Google Drive sync or backup and sign in, your expense/participant/category data *is* transmitted — to Google's Drive API, into a hidden folder inside your own Google account. Both are off by default, require an explicit sign-in step you can decline or revoke at any time, and — depending on how your copy of the app was built — may not be offered at all. Voice input is handled by your device's speech recognition service, as described under "Voice Input" above.

### User-Initiated Sharing
- **Export Feature**: You can voluntarily export your data to share with others
- **File Sharing**: When you use built-in sharing features, data is shared according to your choices

## Your Rights and Controls

### Data Control
- **Full Access**: You have complete access to all your data within the app
- **Export Capability**: You can export all your data at any time
- **Deletion**: You can delete individual records or all data through the app
- **Backup Control**: You control when and how to backup your data

### Permission Management
- **Location**: You can grant/revoke location permission in device settings
- **Camera**: You can grant/revoke camera permission in device settings
- **Microphone**: You can grant/revoke microphone permission in device settings
- **Notifications**: You can grant/revoke notification permission in device settings
- **Storage**: Required for basic app functionality (saving your expense data)

## Permissions Explained

### Required Permissions
- **Storage**: To save your expense groups, trips, and data locally

### Optional Permissions
- **Location (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION)**: Only when you choose to add location to expenses
- **Camera**: Only when you choose to take photos for backgrounds or attachments, or to scan a receipt
- **Microphone (RECORD_AUDIO)**: Only while you dictate an expense
- **Notifications (POST_NOTIFICATIONS)**: Only for the notifications you choose to turn on
- **Media Access (READ_MEDIA_IMAGES, READ_MEDIA_VIDEO)**: Only when you choose to select existing photos
- **Wi-Fi / Bluetooth (ACCESS_WIFI_STATE, CHANGE_WIFI_MULTICAST_STATE, BLUETOOTH_SCAN, BLUETOOTH_CONNECT, BLUETOOTH_ADVERTISE, NEARBY_WIFI_DEVICES)**: Only used by the optional device sync feature described above — to discover and exchange data with paired devices on the same Wi-Fi network or over Bluetooth

## Children's Privacy

Caravella does not specifically target children under 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.

## Changes to This Policy

We may update this privacy policy from time to time. We will notify users of any material changes by updating the "Last updated" date at the top of this policy and, where appropriate, by providing notice within the app.

## Contact Information

For questions about this privacy policy or our data practices, please contact us at:

**Email**: gianluigi.calcaterra@gmail.com  
**Project**: https://github.com/calca/caravella

---

## Technical Information for Developers

### Data Processing Basis
- **Legitimate Interest**: Core expense tracking functionality
- **Consent**: Optional features like location, camera and microphone access, device sync and Google Drive

### Data Retention
- **User Controlled**: Data is retained as long as the user keeps it in the app
- **No Server of Ours**: We operate no server, so we retain nothing; data you put in Google Drive stays in your Google account until you delete it

### Third-Party Services
- **Geocoding & Place Search**: OpenStreetMap's Nominatim service is used for address resolution and place search when location features are used
- **Map Tiles**: OpenStreetMap tile servers are used to render the in-app map
- **Background Photos (optional)**: Unsplash's API is used for the optional group background photo search feature
- **Google Drive Sync and Backup (optional, off by default)**: Google Sign-In and the Google Drive API are used only if you explicitly enable them; not every build of the app includes these features at all
- **Speech Recognition (optional)**: The device's speech recognition service is used for voice input
- **Google Play (Play Store builds)**: Google Play services are used for in-app updates and rating prompts
- **No Analytics**: No third-party analytics or tracking services are used

This policy complies with GDPR, CCPA, and Google Play Store requirements for apps that collect personal data.