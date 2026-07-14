# Privacy Policy for Caravella

**Last updated: July 2026**

## Overview

Caravella is a group expense management application that helps you track shared expenses, trips, and participants. We are committed to protecting your privacy and being transparent about our data practices.

## Information We Collect

### Data You Provide
- **Group and Trip Information**: Names, descriptions, and details of expense groups or trips you create
- **Expense Records**: Details of expenses including amounts, categories, descriptions, and participant assignments
- **Participant Information**: Names and details of people you add to your groups
- **Location Data**: When you choose to add location information to expenses (optional)
- **Photos**: When you choose to add background images to groups or attach images to expenses (optional)

### Data Collected Automatically
- **App Usage Data**: Basic app functionality and performance metrics
- **Device Information**: Basic device identifiers for app functionality

## How We Use Your Information

### Primary Uses
- **Core Functionality**: To provide expense tracking, group management, and calculation features
- **Data Synchronization**: To maintain your data across app sessions
- **Backup and Export**: To enable data backup and export features

### Location Information
- **Optional Feature**: Location data is only collected when you explicitly choose to add location information to an expense
- **User Control**: You can use the app without ever providing location access
- **Purpose**: To help you remember where expenses occurred for better record-keeping

### Camera and Photos
- **Optional Feature**: Camera access is only used when you choose to take photos for group backgrounds or expense attachments
- **User Control**: You can use the app without ever providing camera access
- **Local Storage**: Photos are stored locally on your device

## Data Storage and Security

### Local Storage
- **Primary Storage**: All your data is stored locally on your device
- **No Cloud Sync**: We do not automatically sync your data to cloud servers
- **User Control**: You control all data backups and exports

### Security Measures
- **Device Security**: Data security relies on your device's built-in security features
- **Encrypted Backups**: Backup files can be encrypted when exported
- **No Online Accounts**: No user accounts or online services required

## Data Sharing

### No Third-Party Sharing of Your Personal Data
- We do not share, sell, or transfer your expense, participant, or group data to third parties
- We do not use advertising networks or analytics/tracking services
- We do not have access to your data as it remains on your device

### Third-Party Services Used by Optional Features
While your expense data itself is never transmitted anywhere, a small number of optional features make direct network requests from your device to third-party services. No account, expense, or participant data is included in these requests:
- **OpenStreetMap (Nominatim)**: When you search for a location or use auto-location for an expense, the search text or GPS coordinates are sent to `nominatim.openstreetmap.org` to resolve place names/addresses. See the [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/).
- **OpenStreetMap map tiles**: When you view the map, map tile images are fetched from `tile.openstreetmap.org`.
- **Unsplash**: When you search for a background photo for a group, your search text is sent to `api.unsplash.com` to retrieve matching images. This feature is only available in builds configured with an Unsplash API key.

These requests are only made when you actively use the corresponding feature (location search/auto-location, map view, or background photo search) and only contain the search text or coordinates needed to fulfill that request — never your expense records or participant names.

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
- **Storage**: Required for basic app functionality (saving your expense data)

## Permissions Explained

### Required Permissions
- **Storage**: To save your expense groups, trips, and data locally

### Optional Permissions
- **Location (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION)**: Only when you choose to add location to expenses
- **Camera**: Only when you choose to take photos for backgrounds or attachments
- **Media Access (READ_MEDIA_IMAGES, READ_MEDIA_VIDEO)**: Only when you choose to select existing photos

## Children's Privacy

Caravella does not specifically target children under 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.

## Changes to This Policy

We may update this privacy policy from time to time. We will notify users of any material changes by updating the "Last updated" date at the top of this policy and, where appropriate, by providing notice within the app.

## Contact Information

For questions about this privacy policy or our data practices, please contact us at:

**Email**: privacy@caravella.app  
**Project**: https://github.com/calca/caravella

---

## Technical Information for Developers

### Data Processing Basis
- **Legitimate Interest**: Core expense tracking functionality
- **Consent**: Optional features like location and camera access

### Data Retention
- **User Controlled**: Data is retained as long as the user keeps it in the app
- **Local Only**: No server-side data retention

### Third-Party Services
- **Geocoding & Place Search**: OpenStreetMap's Nominatim service is used for address resolution and place search when location features are used
- **Map Tiles**: OpenStreetMap tile servers are used to render the in-app map
- **Background Photos (optional)**: Unsplash's API is used for the optional group background photo search feature
- **No Analytics**: No third-party analytics or tracking services are used

This policy complies with GDPR, CCPA, and Google Play Store requirements for apps that collect personal data.