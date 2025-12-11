# Android Notification Icons

## Overview

This document describes the notification icon setup for the Caravella app on Android.

## Icon Resources

The app uses `ic_notification` as the small notification icon displayed in the Android status bar and notification drawer.

### PNG Icons (Primary)

PNG versions are provided in multiple densities for maximum compatibility:

- `drawable-mdpi/ic_notification.png` - 24x24 px (1x baseline)
- `drawable-hdpi/ic_notification.png` - 36x36 px (1.5x)
- `drawable-xhdpi/ic_notification.png` - 48x48 px (2x)
- `drawable-xxhdpi/ic_notification.png` - 72x72 px (3x)
- `drawable-xxxhdpi/ic_notification.png` - 96x96 px (4x)

These icons are:
- White silhouettes on transparent background
- Derived from the monochrome launcher icon
- Follow Android notification icon guidelines

### Vector Drawable (Fallback)

A vector drawable version exists at `drawable/ic_notification.xml` as a fallback for devices that support it.

## Android Requirements

According to Android design guidelines:
- Notification icons must be white on transparent background
- Icons should be simple, flat silhouettes
- PNG versions are recommended for maximum compatibility
- Vector drawables can work but may cause issues on some devices/versions

## Usage in Code

The notification icon is referenced in `lib/services/notification_service.dart`:

```dart
AndroidNotificationDetails(
  // ...
  icon: 'ic_notification',  // Uses PNG files from drawable-{density} folders
  // ...
)
```

Android automatically selects the appropriate density version based on the device's screen density.

## Regenerating Icons

If the icon needs to be updated:

1. Update the monochrome launcher icons first (`ic_launcher_monochrome.png` in each density folder)
2. Resize each monochrome icon to the notification icon size for that density:
   - mdpi: 24x24 px
   - hdpi: 36x36 px
   - xhdpi: 48x48 px
   - xxhdpi: 72x72 px
   - xxxhdpi: 96x96 px
3. Ensure all pixels are white (RGB 255,255,255) with transparency preserved
4. Save as `ic_notification.png` in the corresponding `drawable-{density}` folder
5. Verify all density versions are created correctly
6. Test on multiple Android devices/emulators

You can use image editing tools like GIMP, Photoshop, or command-line tools like ImageMagick to resize and process the icons.

## Related Issue

This setup was implemented to fix the "invalid icon" error that could occur on certain Android devices when notifications were enabled. The issue was resolved by providing PNG versions in all densities instead of relying solely on the vector drawable.
