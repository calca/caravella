# F-Droid Submission Guide

F-Droid is a community-maintained FOSS Android app catalog. This page covers what's specific to Caravella's F-Droid packaging; for the general submission process see F-Droid's own docs (linked at the bottom).

**Note on version numbers**: this page intentionally avoids hardcoding the current app version or F-Droid version code — those live in `pubspec.yaml` (`version:`) and `metadata.yml` (`CurrentVersion`/`CurrentVersionCode`, `Builds:`) respectively, and go stale immediately if duplicated here. Before an F-Droid submission or update, always diff those two files against each other rather than trusting a number written in this doc.

## Build configuration

F-Droid builds the **`prod`** flavor in the **FOSS variant**: before building, the recipe runs `./build_variant.sh foss`, which points the app's `caravella_gms` dependency at `packages/caravella_gms_foss` — a package with the same name and API but no proprietary Google library. The Play Services, ML Kit and Play Core plugins then aren't in the dependency graph at all, so they aren't compiled into the APK (earlier builds only made them unreachable with dart-defines, which F-Droid's scanner still rejects). See [caravella_gms](PACKAGE_CARAVELLA_GMS.md) and [Build Variants § Play vs. FOSS variant](BUILD_VARIANTS.md#play-vs-foss-variant):

```bash
./build_variant.sh foss
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod
./build_variant.sh check   # no non-free Google artifact on the release classpath
```

The recipe in `metadata.yml` also deletes (`rm:`) the packages only the Play build uses — `packages/caravella_gms`, `packages/google_drive_sync`, `packages/play_store_updates` — so the source scan doesn't see them; pub never needs them once the override is in place. `ENABLE_PLAY_UPDATES`, `ENABLE_GOOGLE_DRIVE_SYNC` and `ENABLE_BLUETOOTH_SYNC` don't need to be passed: the features they gate don't exist in the FOSS variant.

Cross-check the exact build stanza (including any `--dart-define=ENABLE_ANDROID_WIDGET=...`) against `metadata.yml`'s `Builds:` section directly — do not rely on the command shown above being current if `metadata.yml` has since changed. Only tags that contain `build_variant.sh` can be built this way; older tags can't be built without non-free dependencies.

Package name: `io.caravella.egm`. F-Droid signs the APK with its own key — the repo's release keystore is not used for F-Droid builds.

## Metadata locations

- `metadata.yml` (repo root) — F-Droid app metadata: categories, license, links, anti-features, `AutoUpdateMode: Version` / `UpdateCheckMode: Tags` (F-Droid picks up new versions from GitHub release tags in `vX.Y.Z` format).
- `fastlane/metadata/android/<locale>/` — per-locale store listing (`title.txt`, `short_description.txt`, `full_description.txt`, `changelogs/<versionCode>.txt`, `images/`). Every locale (en-US, it-IT, es-ES, pt-BR, zh-CN) has a full listing: title, short and full description (the Play listing minus what the FOSS build lacks — Google Drive, Bluetooth, receipt reading, Unsplash) and the 8 framed screenshots from `store/screenshots/<lang>/`. Refresh them together with the Play listing.

## Keeping `metadata.yml` in sync

`metadata.yml`'s version fields drift independently from `pubspec.yaml` and from the actual release process (`pubspec.yaml` is bumped by hand when preparing a release; no workflow touches `metadata.yml` — see [CI Pipelines](CI_PIPELINES.md)). Whenever you cut a release intended for F-Droid:

1. Confirm `pubspec.yaml`'s `version:` matches the GitHub release tag.
2. Update `metadata.yml`'s `CurrentVersion`/`CurrentVersionCode` and add a new `Builds:` entry if the build recipe changed.
3. Add the matching `fastlane/metadata/android/<locale>/changelogs/<versionCode>.txt` file(s).

## Dependency / anti-feature review points

F-Droid requires no non-free dependencies and no non-free network services.

- **Non-free libraries** are all confined to `packages/caravella_gms` and absent from the FOSS variant: `geolocator` (fused location), `google_mlkit_text_recognition` (receipt OCR), `mobile_scanner` (ML Kit barcode, QR pairing), `nearby_connections` (Bluetooth sync), `in_app_review` and `in_app_update` (Play Core, via `play_store_updates`), `google_sign_in`/`googleapis` (Drive, via `google_drive_sync`). CI enforces both halves: `validate_package_boundaries.sh` fails if any of them is imported or depended on outside `caravella_gms`, and the "F-Droid (FOSS) variant guard" step runs `./build_variant.sh check` on the release classpath. When a new plugin is added anywhere, re-run `./build_variant.sh foss && ./build_variant.sh check` — a free-looking plugin can still pull in `com.google.android.gms`.
- **What the F-Droid build loses**: receipt scanning, QR *scanning* (it can still be paired by showing its own QR), Bluetooth sync, Google Drive sync, in-app review and in-app updates. Current location still works, through the platform `LocationManager` (`LocationChannel.kt`).
- **`UNSPLASH_ACCESS_KEY`** (background photo search — see [Group Management § photo/background flow](APP_GROUP_MANAGEMENT.md#photobackground-flow)) is a keyed third-party network service. The F-Droid recipe doesn't pass it, so the feature is simply absent there (it degrades to "feature unavailable" with no key). Keep it that way: a baked-in key would make it a non-free network dependency.
- **Prebuilt native libraries**: the test-only dev dependency `sqflite_common_ffi` pulls in `sqlite3`, whose build hook bundles a downloaded `libsqlite3.so` into every APK (it isn't used at runtime — the app uses `sqflite`). The recipe deletes that dev dependency from `pubspec.yaml` before `pub get`. If another package with a native-assets build hook is added, check the APK's `lib/` for prebuilt `.so` files the same way.
- **OpenStreetMap** tiles and Nominatim place search are free network services and stay enabled.
- **`bonsoir`** (LAN/mDNS peer-to-peer sync, `packages/caravella_core/lib/sync/channels/lan_sync_channel.dart`) has no Google Play Services dependency and isn't gated by any flag — it runs whenever a group has sync enabled, on every build including F-Droid's.
- **Builds per ABI**: following fdroiddata's [Flutter template](https://gitlab.com/fdroid/fdroiddata/-/blob/master/templates/build-flutter.yml), each release has three `Builds:` entries built with `--split-per-abi` (`android-arm`, `android-arm64`, `android-x64`). Flutter sets each split APK's versionCode to 1000/2000/4000 + the pubspec build number (2.2.1+127 → 1127, 2127, 4127), which is what `VercodeOperation` and `CurrentVersionCode` (the x86_64 code) encode. Only the latest release is listed.
- **No `--enforce-lockfile`**: the committed `pubspec.lock` describes the Play build. The FOSS variant removes the Play-only packages and `sqflite_common_ffi`, so pub rewrites the lockfile; the changes are removals plus the `caravella_gms` override, and every remaining package keeps its locked version. Committing a FOSS lockfile upstream would allow `--enforce-lockfile` if a reviewer asks for it.
- **Recipe workarounds**: the recipe installs `platforms;android-37.0` and the build-tools the tag's Android Gradle Plugin defaults to up front — `build-tools;36.0.0` for AGP 9.1 (v2.2.1). If AGP downloads build-tools itself mid-build, it reloads the SDK and fails with "Failed to find target with hash string 'android-37'"; when AGP is bumped, check which build-tools it pulls (the fdroiddata build log shows it) and update this line. The lint and signing `sed` lines were needed for v2.0.1 (AGP 8.11: false "must extend Activity" under JDK 21, unconditional release signing); from v2.2.1 they are no-ops and can be dropped from the fdroiddata recipe.
- The Flutter embedding itself references (but doesn't bundle) Play Core split-install classes for deferred components; F-Droid builds Flutter apps with that as a known case.

For everything else, verify licenses against `pubspec.yaml`/`pubspec.lock` directly (pub.dev shows each package's license) rather than trusting a hardcoded table — the dependency set changes often enough that a static table here would go stale within a few releases.

## Permissions

Camera and location are declared `android:required="false"` in `AndroidManifest.xml` — the app is fully usable with both denied. Storage permission is only needed pre-Android-13 (modern versions use the system Photo Picker, no permission required).

## Reproducible builds

F-Droid signs the APK with its own key; reproducible builds (F-Droid shipping an APK signed by us) are not enabled, and can't be switched on later without breaking updates for existing installs. They couldn't match anyway: the F-Droid APK is the FOSS variant, the Play/GitHub one isn't.

- `pubspec.lock` is committed — dependency versions are pinned.
- No build timestamps are embedded; version comes from `pubspec.yaml` only.
- Confirm the Flutter version F-Droid's build server uses matches (or is compatible with) the version pinned in CI — see [CI Pipelines](CI_PIPELINES.md) for CI's current pin, and re-check this at submission time since both drift independently.

## External resources

- F-Droid docs: https://f-droid.org/docs/
- Metadata reference: https://f-droid.org/docs/Build_Metadata_Reference/
- Inclusion policy: https://f-droid.org/docs/Inclusion_Policy/
- Request for Packaging (first submission): https://gitlab.com/fdroid/rfp/-/issues — Caravella's is [rfp#3406](https://gitlab.com/fdroid/rfp/-/work_items/3406). RFPs are picked up rarely; the faster route is opening a merge request on [fdroiddata](https://gitlab.com/fdroid/fdroiddata) with `metadata/io.caravella.egm.yml` (based on this repo's `metadata.yml`), whose CI builds the app and gets a reviewer. Caravella's is [fdroiddata!52814](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/52814); while it carries the `waiting-on-response` label the reviewer is waiting on us, so answer there promptly.

## See also

- [Build Variants & Flavors](BUILD_VARIANTS.md)
- [CI Pipelines](CI_PIPELINES.md)
- [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md)
- [google_drive_sync package](PACKAGE_GOOGLE_DRIVE_SYNC.md)
- [caravella_gms](PACKAGE_CARAVELLA_GMS.md)
