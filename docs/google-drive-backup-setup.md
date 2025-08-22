# Google Drive Backup Setup Guide

This document explains how to complete the Google Drive backup setup for Caravella.

## Overview

The Google Drive backup feature has been implemented and integrated into the app's Settings > Data management section. When running on Android, users will see additional options for Google Drive backup and restore.

## Implementation Details

### What's Included

1. **GoogleDriveBackupService** - Core service handling all Google Drive operations
2. **UI Integration** - Android-only UI in DataPage for backup/restore operations
3. **Authentication Flow** - Google Sign-In integration with proper scopes
4. **Error Handling** - Comprehensive error messages and user feedback
5. **Localization** - Support for Italian and English languages

### Features

- **Sign In/Out** - Authenticate with Google account
- **Backup to Drive** - Upload expense groups JSON file to Google Drive
- **Restore from Drive** - Download and restore data from Google Drive
- **Status Checking** - Check if backup exists on Drive
- **Progress Feedback** - Loading states and success/error messages

## Setup Requirements

To make Google Drive backup fully functional, you need to:

### 1. Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the Google Drive API
4. Configure OAuth 2.0 consent screen
5. Create OAuth 2.0 credentials for Android

### 2. Add Configuration File

Download the `google-services.json` file from Firebase/Google Cloud Console and place it in:
```
android/app/google-services.json
```

### 3. Update Package Name (if needed)

Ensure the package name in Google Cloud Console matches:
```
org.app.caravella
```

## Technical Architecture

### Service Layer
```dart
GoogleDriveBackupService
├── signIn() - Authenticate with Google
├── signOut() - Sign out from Google
├── uploadBackup() - Upload JSON to Drive
├── downloadBackup() - Download JSON from Drive
├── hasBackupOnDrive() - Check backup existence
└── getBackupInfo() - Get backup metadata
```

### UI Flow
1. **Settings** → **Data Management** → **DataPage**
2. **Android Only**: Google Drive section appears
3. **Authentication**: Sign in/out with Google account
4. **Backup**: Upload current expense groups to Drive
5. **Restore**: Download and replace local data with Drive backup

### File Management
- **Backup File**: `caravella_backup.json`
- **Location**: Google Drive root folder (app-scoped)
- **Format**: Same JSON format as local storage
- **Versioning**: Overwrites existing backup

## Error Handling

The implementation includes comprehensive error handling for:
- Authentication failures
- Network connectivity issues
- Google Drive API errors
- File operation errors
- Permission issues

## Security Considerations

- Uses minimal required scopes (Drive file access only)
- No sensitive data stored in plain text
- Authentication tokens managed by Google Sign-In SDK
- App-scoped storage (only Caravella can access its backup files)

## Testing

Unit tests are included for the `GoogleDriveBackupService` covering:
- Service initialization
- Authentication state management
- Error handling for unauthenticated operations
- Basic service contract validation

## Future Enhancements

Potential improvements could include:
- Multiple backup slots
- Automatic periodic backups
- Backup compression
- Backup encryption
- Cross-platform support (iOS)

## Troubleshooting

### Common Issues

1. **"Google sign in failed"**
   - Ensure `google-services.json` is properly configured
   - Verify package name matches Google Cloud Console
   - Check OAuth consent screen configuration

2. **"Not signed in to Google Drive"**
   - User needs to authenticate first
   - Check network connectivity

3. **"No backup found on Google Drive"**
   - No previous backup exists
   - User should create a backup first

### Debug Mode

For debugging, you can add additional logging to the `GoogleDriveBackupService` class to trace API calls and responses.