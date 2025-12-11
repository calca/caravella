# Android Launcher Icons

## Overview

This document describes the launcher icon setup for the Caravella app on Android, including the flavor-specific icon configuration.

## Icon Structure

The app uses a **flavor-based icon system** where each build flavor (dev, staging, prod) has its own complete set of launcher icons in separate source sets:

```
android/app/src/
├── dev/res/
│   ├── mipmap-anydpi-v26/ic_launcher_dev.xml
│   ├── mipmap-hdpi/ic_launcher_dev.png
│   ├── mipmap-mdpi/ic_launcher_dev.png
│   ├── mipmap-xhdpi/ic_launcher_dev.png
│   ├── mipmap-xxhdpi/ic_launcher_dev.png
│   ├── mipmap-xxxhdpi/ic_launcher_dev.png
│   ├── drawable-*/ic_launcher_foreground.png
│   ├── drawable-*/ic_launcher_monochrome.png
│   └── values/colors.xml (with ic_launcher_background color)
│
├── staging/res/
│   ├── mipmap-anydpi-v26/ic_launcher_staging.xml
│   ├── mipmap-*/ic_launcher_staging.png
│   ├── drawable-*/ic_launcher_foreground.png
│   ├── drawable-*/ic_launcher_monochrome.png
│   └── values/colors.xml (with ic_launcher_background color)
│
├── prod/res/
│   ├── mipmap-anydpi-v26/ic_launcher.xml
│   ├── mipmap-*/ic_launcher.png
│   ├── drawable-*/ic_launcher_foreground.png
│   ├── drawable-*/ic_launcher_monochrome.png
│   └── values/colors.xml (with ic_launcher_background color)
│
└── main/res/
    └── (NO launcher icons - only shared resources)
```

## Important: No Icons in Main Source Set

**Critical:** The `main` source set (`android/app/src/main/res`) must NOT contain any launcher icon resources (`ic_launcher*` files in mipmap directories or `ic_launcher_background` colors).

This is because:
- Android merges resources from all source sets during build
- Duplicate icon resources between `main` and flavor-specific source sets cause resource conflicts
- These conflicts result in "invalid icon" errors during APK installation or runtime

## Build Configuration

The `android/app/build.gradle.kts` file configures the icon for each flavor using manifest placeholders:

```kotlin
productFlavors {
    create("dev") {
        dimension = "environment"
        applicationIdSuffix = ".dev"
        manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_dev"
    }
    create("staging") {
        dimension = "environment"
        applicationIdSuffix = ".staging"
        manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_staging"
    }
    create("prod") {
        dimension = "environment"
        manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
    }
}
```

The `AndroidManifest.xml` uses the placeholder:
```xml
<application
    android:icon="${appIcon}"
    ...>
```

## Adaptive Icons

Each flavor uses adaptive icons (API 26+) with three components:

1. **Background**: Solid color defined in `values/colors.xml`
   - Dev: `#FFC107` (Amber)
   - Staging: `#FF9800` (Orange)
   - Prod: `#009688` (Teal)

2. **Foreground**: PNG image with transparency in `drawable-*` folders
   - Resized versions for each density (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
   - 16% inset applied in the adaptive icon XML

3. **Monochrome**: Single-color icon for themed icons (Android 13+)
   - Used for system theming and Material You integration

## Regenerating Icons

To update launcher icons for all flavors:

1. Update the source icon at `assets/icons/caravella-icon.png`

2. Update the icon configuration files:
   - `flutter_launcher_icons-dev.yaml`
   - `flutter_launcher_icons-staging.yaml`
   - `flutter_launcher_icons-prod.yaml`

3. Run the icon generator for each flavor:
   ```bash
   flutter pub run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
   flutter pub run flutter_launcher_icons -f flutter_launcher_icons-staging.yaml
   flutter pub run flutter_launcher_icons -f flutter_launcher_icons-prod.yaml
   ```

4. Verify the icons were generated in the correct flavor-specific directories

5. **Important:** Do NOT copy any `ic_launcher*` files to `android/app/src/main/res`

## Testing Icons

After generating icons, test each flavor:

```bash
# Dev flavor
flutter run --flavor dev --dart-define=FLAVOR=dev

# Staging flavor
flutter run --flavor staging --dart-define=FLAVOR=staging

# Prod flavor
flutter run --flavor prod --dart-define=FLAVOR=prod
```

Verify:
- App icon appears correctly in launcher
- Adaptive icon works on API 26+ devices
- Icon background color matches flavor configuration
- No "invalid icon" errors during installation

## Troubleshooting

### "Invalid icon" error during APK installation

**Cause:** Duplicate launcher icon resources in `main` source set conflicting with flavor-specific icons.

**Solution:** Remove all `ic_launcher*` files from `android/app/src/main/res/mipmap-*` directories and `ic_launcher_background` colors from `android/app/src/main/res/values/colors.xml`.

### Icons not updating after changes

1. Clean the build:
   ```bash
   flutter clean
   ```

2. Rebuild the app:
   ```bash
   flutter build apk --flavor <flavor> --dart-define=FLAVOR=<flavor>
   ```

3. Uninstall the old app from the device before installing the new APK

## Related Documentation

- [ANDROID_NOTIFICATION_ICONS.md](ANDROID_NOTIFICATION_ICONS.md) - Notification icon setup
- [BUILD_VARIANTS.md](BUILD_VARIANTS.md) - Build configuration and flavors
