# Build Variants & Flavors

Caravella ships from one codebase as three **flavors** (dev/staging/prod) and, orthogonally, with or without Google Play–specific functionality (for F-Droid compatibility). Both axes are controlled by `--dart-define` flags plus a matching Android Gradle flavor. This page replaces the previous version, which described a `lib/updates/` folder that no longer exists — that logic now lives entirely in the `play_store_updates` package (see [package reference](PACKAGE_PLAY_STORE_UPDATES.md)).

## Flavors (`android/app/build.gradle.kts`)

Gradle flavor dimension `"environment"`, three flavors:

| Flavor | `applicationId` suffix | App name | Icon |
|---|---|---|---|
| `dev` | `.dev` | "Caravella - Dev" | `@mipmap/ic_launcher_dev` |
| `staging` | `.staging` | "Caravella - Staging" | `@mipmap/ic_launcher_staging` |
| `prod` | (none) | "Caravella" | `@mipmap/ic_launcher` |

Always pass a matching pair: `--flavor <x> --dart-define=FLAVOR=<x>`. `FLAVOR` is read in `lib/main/app_initialization.dart`'s `configureEnvironment()` and sets `AppConfig.environment` (which drives log verbosity, app name/banner, `showDebugBanner`, etc. — see [caravella_core reference § AppConfig](PACKAGE_CARAVELLA_CORE.md#appconfig)).

```bash
flutter run --flavor dev --dart-define=FLAVOR=dev
flutter build apk --flavor staging --release --dart-define=FLAVOR=staging
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod
```

## iOS flavors (`ios/Runner.xcodeproj`)

Mirrors the Android setup: three Xcode schemes (`dev`/`staging`/`prod`), each with its own `Debug-<flavor>`/`Release-<flavor>`/`Profile-<flavor>` build configuration and `ios/Flutter/<flavor><Config>.xcconfig` (e.g. `devDebug.xcconfig`), setting `PRODUCT_BUNDLE_IDENTIFIER` and the `BUNDLE_NAME`/`BUNDLE_DISPLAY_NAME` consumed by `Info.plist`.

| Flavor | Bundle ID | App name |
|---|---|---|
| `dev` | `io.caravella.egm.dev` | "Caravella - Dev" |
| `staging` | `io.caravella.egm.staging` | "Caravella - Staging" |
| `prod` | `io.caravella.egm` | "Caravella" |

```bash
flutter run --flavor dev --dart-define=FLAVOR=dev -d <ios-simulator-id>
flutter build ios --flavor staging --dart-define=FLAVOR=staging
```

These were generated with `flutter_flavorizr` (dev dependency; config lives under the `flavorizr:` key in `pubspec.yaml`), scoped to the `ios:xcconfig,ios:buildTargets,ios:schema,ios:podfile,ios:plist` processors only — the `android:*`/`flutter:*` processors are never run against this config, since Android flavors are already hand-maintained in `build.gradle.kts` and the app has its own `FLAVOR` dart-define mechanism (not flavorizr's generated one). The original `Runner` scheme/configs (`Debug`/`Release`/`Profile`, no suffix) are left in place and still work for `RunnerTests` and any tooling that doesn't pass `--flavor`. Re-run `dart run flutter_flavorizr -p ios:xcconfig,ios:buildTargets,ios:schema,ios:podfile,ios:plist -f` followed by `pod install` (from `ios/`) after editing the `flavorizr:` block in `pubspec.yaml` — then re-check `ios/Runner/Info.plist`'s `CFBundleIdentifier` is still `$(PRODUCT_BUNDLE_IDENTIFIER)` and that the generated `.xcscheme` files still have `BuildActionEntries` under `BuildAction` (the generator omits both; hand-fix them, using the `Runner` scheme as the reference, before relying on the flavor schemes).

## All dart-define flags

This is the authoritative list — every `String.fromEnvironment`/`bool.fromEnvironment` call in the repo, found by grep, with its actual location:

| Flag | Type / default | Where read | Effect |
|---|---|---|---|
| `FLAVOR` | String, default `'prod'` | `lib/main/app_initialization.dart` | Sets `AppConfig.environment` |
| `USE_JSON_BACKEND` | String (`'true'`/`'false'`), default `'false'` | `lib/main/app_initialization.dart` | Selects the legacy JSON repository instead of SQLite — see [Storage Backend](STORAGE_BACKEND.md) |
| `ENABLE_PLAY_UPDATES` | bool, default `false` | `packages/play_store_updates/lib/src/update_service_factory.dart` | Enables real Google Play in-app-update checks (`PlayStoreUpdateService`) instead of the no-op stub — see [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md) |
| `ENABLE_GOOGLE_DRIVE_SYNC` | bool, default `false` | `packages/google_drive_sync/lib/src/google_drive_sync_factory.dart` | Builds a real `GoogleDriveCloudChannel` (Google Sign-In + Drive API) for the sync feature's Cloud Sync option instead of leaving it `null`/hidden — see [google_drive_sync package](PACKAGE_GOOGLE_DRIVE_SYNC.md) and its [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md) |
| `GOOGLE_DRIVE_IOS_CLIENT_ID` | String, default `''` | `packages/google_drive_sync/lib/src/google_drive_sync_factory.dart` | iOS-only OAuth client ID for Google Drive sync; unused/unnecessary on Android — see [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md#step-5--optional-ios-oauth-client) |
| `ENABLE_BLUETOOTH_SYNC` | bool, default **`true`** | `lib/sync/bluetooth_sync_factory.dart` | Hides the Bluetooth section of Settings → Sync when `false` — the only flag on this page that defaults *on*, since Bluetooth sync already ships; F-Droid-style builds pass `=false` explicitly to avoid the Google Play Services dependency `nearby_connections` pulls in — see [F-Droid Submission](FDROID_SUBMISSION.md) |
| `ENABLE_ANDROID_WIDGET` | bool, default `true` | `packages/caravella_core/lib/config/app_config.dart` (`AppConfig.enableAndroidWidget`), also read natively in `build.gradle.kts` | Enables/disables the Android home-screen widget, both on the Flutter side (`PlatformHomeWidgetManager`) and natively (disables the widget receiver/config activity in the manifest) |
| `ENABLE_TALKER_SCREEN` | bool, default `false` | `packages/caravella_core/lib/config/app_config.dart` (`AppConfig.enableTalkerScreen`) | Shows the in-app "Debug Logs" (Talker) screen in Settings even outside debug builds |
| `UNSPLASH_ACCESS_KEY` | String, default `''` | `lib/services/unsplash/unsplash_service.dart` | Enables the Unsplash background-photo search in group creation/editing (empty ⇒ feature silently disabled, returns no results) |

If you add a new `--dart-define`, add a row here — this table is meant to be the single source of truth (see [Keeping This Documentation Current](MAINTAINING_DOCS.md)).

## Google Play updates vs. F-Droid

`ENABLE_PLAY_UPDATES` selects between `PlayStoreUpdateService` (real `in_app_update`-backed checks) and `NoOpUpdateService` (zero Google Play dependency) at the factory level in `play_store_updates` — see [package reference](PACKAGE_PLAY_STORE_UPDATES.md) for the mechanism. On web builds specifically, a conditional import forces the no-op implementation regardless of the flag.

```bash
# With Play Store update checks (staging/prod builds normally use this)
flutter build apk --dart-define=ENABLE_PLAY_UPDATES=true --dart-define=FLAVOR=prod --flavor prod --release

# Without (F-Droid-style build — no Google dependency reachable at runtime)
flutter build apk --dart-define=FLAVOR=prod --flavor prod --release
```

Note: `play_store_updates` is always a normal pubspec dependency of the root app — the "conditional" part is a runtime/compile-time code path, not conditional dependency resolution (see [Architecture Overview](ARCHITECTURE.md)).

## Google Drive sync (optional)

`ENABLE_GOOGLE_DRIVE_SYNC` selects between `GoogleDriveCloudChannel` (real Google Sign-In + Drive API) and `null` (Cloud Sync section hidden entirely) at the factory level in `google_drive_sync` — same pattern as `ENABLE_PLAY_UPDATES` above. See [package reference](PACKAGE_GOOGLE_DRIVE_SYNC.md) and the [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md) for the Google Cloud Console configuration this requires before the flag does anything useful.

```bash
# With Google Drive cloud sync
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true

# Without (default — no Google Sign-In/Drive code reachable at runtime)
flutter run --flavor dev --dart-define=FLAVOR=dev
```

## Bluetooth sync (on by default)

`ENABLE_BLUETOOTH_SYNC` works the other way round from the two flags above: it **defaults to `true`**, because Bluetooth sync already ships in normal builds — flipping the default would silently remove a working feature from any build that doesn't know to ask for it. Only pass `=false` when you specifically want it gone, e.g. for an F-Droid build avoiding the Google Play Services dependency `nearby_connections` pulls in (Nearby Connections API) — see [F-Droid Submission](FDROID_SUBMISSION.md).

```bash
# Default — Bluetooth sync reachable, same as today
flutter run --flavor dev --dart-define=FLAVOR=dev

# Explicitly excluded (F-Droid-style)
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=ENABLE_BLUETOOTH_SYNC=false
```

As with every flag on this page, `nearby_connections` stays a normal, always-present pubspec dependency either way — the flag only gates whether `lib/sync/sync_settings_screen.dart` ever shows the Bluetooth section (and therefore whether `BluetoothSyncChannel` is ever constructed), not whether the dependency is compiled into the binary.

## Android home widget

`ENABLE_ANDROID_WIDGET` is read on both sides:

1. **Flutter**: `AppConfig.enableAndroidWidget` gates `PlatformHomeWidgetManager` (no-ops when `false`).
2. **Native**: `android/app/build.gradle.kts` resolves the flag from (in order) the Gradle project property `enableAndroidWidget` → the `ENABLE_ANDROID_WIDGET` environment variable → default `true`, and emits it as `resValue("bool", "enable_android_widget", ...)`. `AndroidManifest.xml` uses `android:enabled="@bool/enable_android_widget"` on the widget's receiver and its configuration activity — when `false`, the widget doesn't even appear in Android's widget picker.

```bash
flutter build apk --dart-define=ENABLE_ANDROID_WIDGET=false --dart-define=FLAVOR=prod --flavor prod --release
```

**Current CI always builds with `ENABLE_ANDROID_WIDGET=false`** (see [CI Pipelines](CI_PIPELINES.md)) — if you need to test the widget locally, build without that flag or explicitly pass `=true`.

## See also

- [Storage Backend § selecting a backend](STORAGE_BACKEND.md#selecting-a-backend-the-factory)
- [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md)
- [google_drive_sync package](PACKAGE_GOOGLE_DRIVE_SYNC.md) and its [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md)
- [F-Droid Submission](FDROID_SUBMISSION.md)
- [CI Pipelines](CI_PIPELINES.md)
