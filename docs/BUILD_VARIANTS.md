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

**Toolchain**: Android Gradle Plugin, Gradle and Kotlin versions follow Flutter's own Android templates (`android/settings.gradle.kts`, `android/gradle/wrapper/gradle-wrapper.properties`); `android.builtInKotlin=false`/`android.newDsl=false` in `android/gradle.properties` keep plugins that haven't migrated to AGP 9's built-in Kotlin/new DSL working. `minSdk` is 29 (Android 10). Release builds ship the R8 mapping and native symbol tables inside the App Bundle (`ndk.debugSymbolLevel = "SYMBOL_TABLE"`) and use R8 optimized resource shrinking (`android.r8.optimizedResourceShrinking=true`).

**Release signing**: `release` builds are signed with the key from `android/key.properties` (not committed; CI writes it from secrets). Without that file — a local checkout, F-Droid — `build.gradle.kts` skips the signing config and the release APK comes out unsigned instead of failing; F-Droid signs it with its own key.

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
| `GOOGLE_DRIVE_SERVER_CLIENT_ID` | String, default: the `caravella-egm` Web client ID | `packages/google_drive_sync/lib/src/google_drive_sync_factory.dart` | Web OAuth client ID passed as `serverClientId`; required by Google sign-in on Android. Override only to use another Google Cloud project — see [setup guide § 4c](GOOGLE_DRIVE_SYNC_SETUP.md#4c-create-the-web-client-serverclientid) |
| `ENABLE_BLUETOOTH_SYNC` | bool, default **`true`** | `lib/sync/bluetooth_sync_factory.dart` | Hides the Bluetooth section of Settings → Sync when `false` — the only flag on this page that defaults *on*, since Bluetooth sync already ships. Irrelevant for the FOSS variant, which has no Bluetooth transport at all (see [Play vs. FOSS variant](#play-vs-foss-variant)) |
| `ENABLE_ANDROID_WIDGET` | bool, default per-flavor (`true` for dev/staging, `false` for prod), see below | `packages/caravella_core/lib/config/app_config.dart` (`AppConfig.enableAndroidWidget`), also read natively in `build.gradle.kts` | Enables/disables the Android home-screen widget, both on the Flutter side (`PlatformHomeWidgetManager`) and natively (disables the widget receiver/config activity in the manifest) |
| `ENABLE_TALKER_SCREEN` | bool, default `false` | `packages/caravella_core/lib/config/app_config.dart` (`AppConfig.enableTalkerScreen`) | Shows the in-app "Debug Logs" (Talker) screen in Settings even outside debug builds |
| `UNSPLASH_ACCESS_KEY` | String, default `''` | `lib/services/unsplash/unsplash_service.dart` | Enables the Unsplash background-photo search in group creation/editing (empty ⇒ feature silently disabled, returns no results) |

If you add a new `--dart-define`, add a row here — this table is meant to be the single source of truth (see [Keeping This Documentation Current](MAINTAINING_DOCS.md)).

## Play vs. FOSS variant

Separate from the flavors and dart-defines above, every build is one of two **variants**, chosen by `./build_variant.sh` before `flutter pub get`/`flutter build`:

| Variant | `caravella_gms` resolves to | Use |
|---|---|---|
| `gms` (default) | `packages/caravella_gms` — Play Services, ML Kit, Play Core | Play Store, GitHub releases, CI |
| `foss` | `packages/caravella_gms_foss` — no Google libraries | F-Droid |

```bash
./build_variant.sh foss    # writes pubspec_overrides.yaml (git-ignored) + flutter pub get
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod
./build_variant.sh check   # fails if a non-free Google artifact is on the release classpath
./build_variant.sh gms     # back to the Play build
./build_variant.sh         # prints the current variant
./build_variant.sh fdroid-lock      # regenerates pubspec.fdroid.lock (--check only verifies it)
./build_variant.sh fdroid-prepare   # F-Droid recipe: foss variant pinned to pubspec.fdroid.lock
```

`pubspec.fdroid.lock` is the lockfile of the F-Droid build: the committed `pubspec.lock` resolved for the foss variant without the test-only `sqflite_common_ffi`. It only drops packages, every other one keeps its locked version, and it lets the F-Droid recipe run `flutter pub get --enforce-lockfile`. Regenerate it whenever `pubspec.yaml` or `pubspec.lock` change; CI fails otherwise.

This has to be a dependency switch rather than another `--dart-define`: a define only picks code paths, while every plugin in the resolved dependency graph is still registered by Flutter and compiled by Gradle, which is what F-Droid's scanner rejects. In the FOSS variant receipt OCR, QR scanning, Bluetooth sync, Google Drive, in-app review and in-app updates are hidden, and the current location comes from the platform `LocationManager` instead of Google's fused provider — see [caravella_gms](PACKAGE_CARAVELLA_GMS.md) for the full feature table.

The flags below still apply inside the `gms` variant; in the `foss` variant the features they gate don't exist.

## Google Play updates vs. F-Droid

`ENABLE_PLAY_UPDATES` selects between `PlayStoreUpdateService` (real `in_app_update`-backed checks) and `NoOpUpdateService` (zero Google Play dependency) at the factory level in `play_store_updates` — see [package reference](PACKAGE_PLAY_STORE_UPDATES.md) for the mechanism. On web builds specifically, a conditional import forces the no-op implementation regardless of the flag.

```bash
# With Play Store update checks (staging/prod builds normally use this)
flutter build apk --dart-define=ENABLE_PLAY_UPDATES=true --dart-define=FLAVOR=prod --flavor prod --release

# Without (no update checks, but in_app_update is still compiled in)
flutter build apk --dart-define=FLAVOR=prod --flavor prod --release
```

Note: without the flag `in_app_update` is still in the APK — only the [FOSS variant](#play-vs-foss-variant) removes it. `play_store_updates` is reached only through `caravella_gms` (see [Architecture Overview](ARCHITECTURE.md#package-dependency-rules)).

## Google Drive sync (optional)

`ENABLE_GOOGLE_DRIVE_SYNC` selects between `GoogleDriveCloudChannel` (real Google Sign-In + Drive API) and `null` (Cloud Sync section hidden entirely) at the factory level in `google_drive_sync` — same pattern as `ENABLE_PLAY_UPDATES` above. See [package reference](PACKAGE_GOOGLE_DRIVE_SYNC.md) and the [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md) for the Google Cloud Console configuration this requires before the flag does anything useful.

```bash
# With Google Drive cloud sync
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true

# Without (default — no Google Sign-In/Drive code reachable at runtime)
flutter run --flavor dev --dart-define=FLAVOR=dev
```

## Bluetooth sync (on by default)

`ENABLE_BLUETOOTH_SYNC` works the other way round from the two flags above: it **defaults to `true`**, because Bluetooth sync already ships in normal builds — flipping the default would silently remove a working feature from any build that doesn't know to ask for it. Only pass `=false` when you specifically want it hidden from a Play build; the F-Droid build doesn't need it, since the [FOSS variant](#play-vs-foss-variant) has no Bluetooth transport.

```bash
# Default — Bluetooth sync reachable, same as today
flutter run --flavor dev --dart-define=FLAVOR=dev

# Explicitly hidden
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=ENABLE_BLUETOOTH_SYNC=false
```

The flag only gates whether `BluetoothSyncFactory.isEnabled` is true (and therefore whether the Bluetooth section shows and a channel is ever created through `GmsIntegrations.createBluetoothChannel`); `nearby_connections` stays compiled into every `gms`-variant build either way.

## Android home widget

`ENABLE_ANDROID_WIDGET` is read on both sides, with matching per-flavor defaults so a build without any explicit override behaves consistently:

1. **Flutter**: `AppConfig.enableAndroidWidget` gates `PlatformHomeWidgetManager` (no-ops when `false`). Its default isn't a flat `true`/`false` — it reads the `FLAVOR` dart-define itself (`defaultValue: _flavor != 'prod'`) so it lands on `true` for dev/staging and `false` for prod without needing `ENABLE_ANDROID_WIDGET` passed explicitly.
2. **Native**: `android/app/build.gradle.kts` resolves an *override* from (in order) the Gradle project property `enableAndroidWidget` → the `ENABLE_ANDROID_WIDGET` environment variable → no override. When an override is set, it forces the same value for every flavor. Without one, each product flavor's `resValue("bool", "enable_android_widget", ...)` falls back to its own default: **`true` for `dev` and `staging`, `false` for `prod`** — matching the Flutter side. `AndroidManifest.xml` uses `android:enabled="@bool/enable_android_widget"` on the widget's receiver and its configuration activity — when `false`, the widget doesn't even appear in Android's widget picker.

```bash
# dev/staging: widget enabled by default, no flag needed
flutter build apk --dart-define=FLAVOR=staging --flavor staging --release

# prod: widget disabled by default, no flag needed
flutter build apk --dart-define=FLAVOR=prod --flavor prod --release

# explicit override forces the same value on every flavor, both native and Flutter side
flutter build apk --dart-define=ENABLE_ANDROID_WIDGET=false --dart-define=FLAVOR=staging --flavor staging --release
```

**CI** (see [CI Pipelines](CI_PIPELINES.md)) builds `staging` with the widget explicitly enabled (`ENABLE_ANDROID_WIDGET=true`, matching the native default) and `prod` with it explicitly disabled (`ENABLE_ANDROID_WIDGET=false`, also matching the native default) — the dart-define is passed explicitly in both cases so the Flutter side stays in sync with the native per-flavor default rather than relying on its own separate `true` default.

## See also

- [Storage Backend § selecting a backend](STORAGE_BACKEND.md#selecting-a-backend-the-factory)
- [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md)
- [google_drive_sync package](PACKAGE_GOOGLE_DRIVE_SYNC.md) and its [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md)
- [F-Droid Submission](FDROID_SUBMISSION.md)
- [CI Pipelines](CI_PIPELINES.md)
