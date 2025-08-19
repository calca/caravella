# Manual Testing Guide for Geolocation Feature

## Overview
This document describes how to manually test the new geolocation feature for expense records.

## What Was Added

### 1. Data Model Changes
- **ExpenseLocation**: New class in `lib/data/expense_location.dart`
  - Fields: latitude, longitude, address, name
  - JSON serialization/deserialization
  - Display text formatting

- **ExpenseDetails**: Updated to include optional location field
  - JSON serialization includes location
  - copyWith method supports location

### 2. UI Components
- **LocationInputWidget**: New widget in `lib/manager/expense/expense_form/location_input_widget.dart`
  - Manual text input for location names
  - GPS location detection button
  - Clear location button
  - Loading indicator during GPS acquisition

### 3. Form Integration
- Location widget added to expense forms when date/note fields are visible
- Appears after the note field
- Saves location data with expense records

### 4. Permissions
- Added location permissions to Android manifest:
  - ACCESS_FINE_LOCATION
  - ACCESS_COARSE_LOCATION

### 5. CSV Export
- Location column added to CSV exports
- Uses displayText from ExpenseLocation

### 6. Localization
- Added location-related strings in both English and Italian
- Includes error messages for permission/service issues

## Manual Testing Steps

### Test 1: Basic Form Display
1. Run the app: `flutter run --flavor dev`
2. Create a new expense group
3. Add a new expense
4. Verify the location field appears after the note field
5. Check that all UI elements render correctly

### Test 2: Manual Location Entry
1. In the expense form, type a location name in the location field
2. Save the expense
3. Edit the expense and verify the location is preserved
4. Export CSV and verify location appears in the export

### Test 3: GPS Location Detection
1. In the expense form, tap the GPS location button
2. Grant location permissions when prompted
3. Verify loading indicator appears
4. Check that coordinates are populated when GPS succeeds
5. Verify error messages appear for permission/service issues

### Test 4: Location Persistence
1. Create an expense with a location
2. Close and reopen the app
3. Edit the expense and verify location is preserved
4. Test with both manual and GPS-detected locations

### Test 5: CSV Export with Location
1. Create multiple expenses with different location types:
   - No location
   - Manual location name
   - GPS coordinates
2. Export group to CSV
3. Verify location column contains appropriate data

### Test 6: Cross-Platform Testing
1. Test on Android (location permissions)
2. Test on web (GPS may not work, manual entry should work)
3. Verify form behavior is consistent

## Expected Behavior

### Location Field Visibility
- Shows when creating/editing expenses in detailed mode
- Hidden in quick-add mode (matches note field behavior)

### GPS Button
- Shows location icon normally
- Shows loading spinner when detecting location
- Handles permission requests gracefully
- Shows error messages for failures

### Location Display
- Manual entries show as entered
- GPS locations show coordinates if no address available
- Empty when no location is set

### Data Persistence
- Location data saves with expense records
- Survives app restarts
- Included in CSV exports

## Known Limitations

1. **GPS Accuracy**: Depends on device capabilities and settings
2. **Web Support**: GPS detection may not work in all browsers
3. **Reverse Geocoding**: Not implemented (coordinates shown as-is)
4. **Offline Support**: GPS detection requires location services

## Troubleshooting

### Location Permission Issues
- Check device location settings
- Ensure app has location permissions
- Try manual location entry if GPS fails

### UI Layout Issues
- Verify all form fields are properly spaced
- Check that location field appears in correct position
- Test on different screen sizes

### Data Issues
- Verify location data appears in expense details
- Check CSV export includes location column
- Test editing existing expenses