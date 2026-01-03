# Dynamic Notification Icons by Group Type

## Overview

This document describes how notification icons change based on the expense group type. The notification's "tracker icon" (small icon shown in the Android status bar) varies depending on whether the group is categorized as travel, personal, family, or other.

## Icon Mapping

Each `ExpenseGroupType` has a corresponding notification icon:

| Group Type | Icon Name | Material Icon | Description |
|------------|-----------|---------------|-------------|
| `travel` | `ic_notification_travel` | `flight_takeoff` | Airplane taking off |
| `personal` | `ic_notification_personal` | `person` | Single person silhouette |
| `family` | `ic_notification_family` | `family_restroom` | Family group silhouette |
| `other` | `ic_notification_other` | `widgets_outlined` | Generic widgets icon |
| `null` (default) | `ic_notification` | (monochrome logo) | App's default icon |

## Implementation

The notification icon is selected dynamically in `NotificationService._getIconForGroupType()` based on the `ExpenseGroup.groupType` field.

```dart
// Get icon based on group type
final iconName = _getIconForGroupType(group.groupType);

// Use in notification
AndroidNotificationDetails(
  // ...
  icon: iconName,  // Dynamically selected
  // ...
)
```

## Creating the PNG Icons

### Requirements

According to `ANDROID_NOTIFICATION_ICONS.md`, notification icons **MUST be PNG files** (not vector drawables) to avoid "invalid_icon" errors with the `flutter_local_notifications` plugin.

Each icon must be created in the following densities:

| Density | Size | Folder |
|---------|------|--------|
| mdpi | 24×24 px | `drawable-mdpi/` |
| hdpi | 36×36 px | `drawable-hdpi/` |
| xhdpi | 48×48 px | `drawable-xhdpi/` |
| xxhdpi | 72×72 px | `drawable-xxhdpi/` |
| xxxhdpi | 96×96 px | `drawable-xxxhdpi/` |
| (fallback) | 24×24 px | `drawable/` |

### Icon Locations

Icons must be placed in these source sets:

- `android/app/src/main/res/drawable-{density}/`
- Optionally in flavor-specific folders for flavor-specific builds

### Icon Specifications

- **Format**: PNG
- **Color**: White (`#FFFFFF`) on transparent background
- **Style**: Simple, flat silhouettes
- **Contrast**: High contrast for visibility on any background

### Vector Source Data

For creating the PNG icons, use these Material Icon SVG paths (from Material Design Icons):

#### ic_notification_travel (flight_takeoff)
```xml
<path d="M2.5,19h19v2h-19zM22.07,9.64c-0.21,-0.8 -1.04,-1.28 -1.84,-1.06L14.92,10l-6.9,-6.43 -1.93,0.51 4.14,7.17 -4.97,1.33 -1.97,-1.54 -1.45,0.39 2.59,4.49c0,0 7.12,-1.9 16.57,-4.43 0.81,-0.23 1.28,-1.05 1.07,-1.85z"/>
```

#### ic_notification_personal (person)
```xml
<path d="M12,12c2.21,0 4,-1.79 4,-4s-1.79,-4 -4,-4 -4,1.79 -4,4 1.79,4 4,4zM12,14c-2.67,0 -8,1.34 -8,4v2h16v-2c0,-2.66 -5.33,-4 -8,-4z"/>
```

#### ic_notification_family (family_restroom)
```xml
<path d="M16,4c0,-1.11 0.89,-2 2,-2s2,0.89 2,2 -0.89,2 -2,2 -2,-0.89 -2,-2zM20,22v-6h2.5l-2.54,-7.63C19.68,7.55 18.92,7 18.06,7h-0.12c-0.86,0 -1.63,0.55 -1.9,1.37l-0.86,2.58C16.26,11.55 17,12.68 17,14v8h3zM12.5,11.5c0.83,0 1.5,-0.67 1.5,-1.5s-0.67,-1.5 -1.5,-1.5S11,9.17 11,10s0.67,1.5 1.5,1.5zM5.5,6c1.11,0 2,-0.89 2,-2s-0.89,-2 -2,-2 -2,0.89 -2,2 0.89,2 2,2zM7.5,22v-7H9V9c0,-1.1 -0.9,-2 -2,-2H4C2.9,7 2,7.9 2,9v6h1.5v7h4zM14,22v-4h1v-4c0,-0.82 -0.68,-1.5 -1.5,-1.5h-2c-0.82,0 -1.5,0.68 -1.5,1.5v4h1v4h3z"/>
```

#### ic_notification_other (widgets_outlined)
```xml
<path d="M16.66,4.52l2.83,2.83 -2.83,2.83 -2.83,-2.83 2.83,-2.83M9,5v4H5V5h4m10,10v4h-4v-4h4M9,15v4H5v-4h4m7.66,-13.31L11,7.34 16.66,13l5.66,-5.66 -5.66,-5.65zM11,3H3v8h8V3zm10,10h-8v8h8v-8zm-10,0H3v8h8v-8z"/>
```

### Generation Methods

#### Option 1: Using Android Studio

1. Right-click on `res` folder → New → Vector Asset
2. Choose "Clip Art" and search for the Material Icon name
3. Set color to white (#FFFFFF)
4. Set size to 24dp
5. Click "Next" and save as the appropriate icon name
6. Then use Android Studio's "Image Asset" tool to generate all density versions:
   - Right-click on `res` → New → Image Asset
   - Choose "Notification Icons"
   - Set source to the vector asset
   - Name appropriately and generate

#### Option 2: Using SVG Tools

1. Create an SVG file with 24×24 viewBox
2. Add the path data (white fill, transparent background)
3. Use tools like Inkscape or online converters to export as PNG
4. Scale to each density requirement
5. Ensure all pixels are pure white on transparent background

#### Option 3: Using Command Line (ImageMagick)

If you have ImageMagick installed:

```bash
# Example for creating one density from SVG
convert -density 300 -background transparent \
  -fill white input.svg \
  -resize 48x48 ic_notification_travel.png
```

### Validation

After creating the icons:

1. Verify each PNG has the correct dimensions for its density
2. Verify all pixels are white (#FFFFFF) with proper transparency
3. Test on multiple Android devices/emulators
4. Check that notifications display correctly for each group type
5. Verify no "invalid_icon" exceptions in logs

## Testing

To test the dynamic icons:

1. Create expense groups of different types (travel, personal, family, other)
2. Enable persistent notifications for each group
3. Open the Android notification drawer
4. Verify each notification shows a different icon in the status bar
5. Check that groups without a type show the default icon

## Fallback Behavior

If a type-specific icon is not found, Android will:
- Show no icon (blank space) in the status bar
- Log an error in the system logs
- Still display the notification with the large icon

Therefore, it's critical that all PNG files are properly created and placed in the correct locations.

## Related Files

- Implementation: `lib/services/notification_service.dart`
- Tests: `test/notification_icon_selection_test.dart`
- Requirements: `docs/ANDROID_NOTIFICATION_ICONS.md`
- Type definitions: `packages/caravella_core/lib/model/expense_group_type.dart`
