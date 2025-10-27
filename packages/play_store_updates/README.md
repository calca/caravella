# Play Store Updates Package

This package provides Google Play Store in-app update functionality for the Caravella app.

## Purpose

This package is separated to allow building versions of the app without Google Play dependencies:
- **Play Store builds**: Include this package with `--dart-define=ENABLE_PLAY_UPDATES=true`
- **F-Droid builds**: Exclude this package (no flag or `ENABLE_PLAY_UPDATES=false`)

## Usage

When building for Play Store:
```bash
flutter build apk --dart-define=ENABLE_PLAY_UPDATES=true --dart-define=FLAVOR=prod
```

When building for F-Droid:
```bash
flutter build apk --dart-define=FLAVOR=prod
```

## Features

- Automatic weekly update checks
- Manual update checks from settings
- Flexible update flow (background download)
- Update notifications and prompts
- Graceful fallback when not available
