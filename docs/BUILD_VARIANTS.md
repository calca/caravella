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

## All dart-define flags

This is the authoritative list — every `String.fromEnvironment`/`bool.fromEnvironment` call in the repo, found by grep, with its actual location:

| Flag | Type / default | Where read | Effect |
|---|---|---|---|
| `FLAVOR` | String, default `'prod'` | `lib/main/app_initialization.dart` | Sets `AppConfig.environment` |
| `USE_JSON_BACKEND` | String (`'true'`/`'false'`), default `'false'` | `lib/main/app_initialization.dart` | Selects the legacy JSON repository instead of SQLite — see [Storage Backend](STORAGE_BACKEND.md) |
| `ENABLE_PLAY_UPDATES` | bool, default `false` | `packages/play_store_updates/lib/src/update_service_factory.dart` | Enables real Google Play in-app-update checks (`PlayStoreUpdateService`) instead of the no-op stub — see [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md) |
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
- [F-Droid Submission](FDROID_SUBMISSION.md)
- [CI Pipelines](CI_PIPELINES.md)
