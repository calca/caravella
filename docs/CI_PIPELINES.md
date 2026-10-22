# CI Pipelines

Four GitHub Actions workflows exist under `.github/workflows/`: CI on every push/PR, a manual **pre-release** (test APK on GitHub), and two manual **Store** workflows (upload to Play, then promote — which also publishes the GitHub release). They are **not identical** to each other and none is a single generic "lint → test → build" pipeline — read the actual YAML before assuming behavior, this page is a map, not a substitute.

## `Development - Android.yml` ("Android CI - Development")

Triggers: push/PR to `main`.

- **`build` job**: `flutter pub get` → `flutter analyze` → guard scripts (`validate_package_boundaries.sh`, `validate_accessibility.sh --skip-tests`, `validate_design_tokens.sh`) → `flutter test --coverage` (uploads `coverage/lcov.info` as the `coverage-report` artifact — visibility only, no minimum-coverage gate) → `flutter pub get && flutter test` in every `packages/*` → **F-Droid (FOSS) variant guard** (`./build_variant.sh foss`, `flutter analyze`, `./build_variant.sh check` — fails if a non-free Google artifact reaches the release classpath — then `./build_variant.sh gms`; see [caravella_gms](PACKAGE_CARAVELLA_GMS.md)) → build a **signed staging APK**:
  ```bash
  flutter build apk --flavor staging --release \
    --dart-define=FLAVOR=staging \
    --dart-define=ENABLE_TALKER_SCREEN=true \
    --dart-define=ENABLE_PLAY_UPDATES=true \
    --dart-define=ENABLE_BLUETOOTH_SYNC=true \
    --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true \
    --dart-define=ENABLE_ANDROID_WIDGET=true \
    --dart-define=UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY
  ```
  This is the sequence CLAUDE.md means by "match this locally before pushing" — reproduce it with `flutter pub get && flutter analyze && flutter test` before opening a PR.

Publishing a release on GitHub no longer builds anything or bumps `pubspec.yaml` (an older `release` job did both, which is where the bot-authored "Bump version" commits and the `v1.9.x-dev` pre-releases come from). The version is bumped by hand as part of preparing a release (`.claude/skills/plan-create-release`).

## `Pre-release - Android.yml` ("Android CI - Pre-release")

Manually triggered with input `target_branch`. A test build for sideloading; **nothing goes to Google Play** and `pubspec.yaml` isn't touched.

- Tag `v<version>-rc.<n>`: `<version>` from `pubspec.yaml`, `<n>` one past the highest existing `rc` tag of that version (`v2.0.2-rc.1`, `-rc.2`, …). Fails if the tag `v<version>` already exists (that version was released) — bump the version first.
- The APK is built with `--build-name=<version>-rc.<n>`, so the app shows which test build it is (Settings › Info and Android's app info read `2.0.3-rc.30-staging` — the flavor's `versionNameSuffix` is appended). The version code stays the one in `pubspec.yaml`.
- Runs `flutter analyze`, the package boundary guard, `flutter test` and every package's tests, then builds the **signed staging APK** with the same flags as the CI `build` job (Talker screen on, widget on). Staging installs next to the Play app (`io.caravella.egm.staging`, "Caravella - Staging", own data).
- Publishes a GitHub **pre-release** (never marked Latest) on the built commit with `io_caravella_egm-staging-<version>-rc.<n>.apk` + `.sha256`, and notes from `CHANGELOG.md` `[Unreleased]` (via [`.github/scripts/release_notes.py`](../.github/scripts/release_notes.py)) plus a compare link to the previous rc, or to the last store release for `rc.1`. It fails if `[Unreleased]` is empty.

## `Store - Android.yml` ("Android CI - Store")

Manually triggered (`workflow_dispatch`) with inputs `target_branch` and `track` (`internal`/`alpha`/`beta`/`production`).

Steps: checkout → validate track → `flutter pub get` → `flutter analyze` → `flutter test` → build a **signed prod App Bundle**:
```bash
flutter build appbundle --flavor prod --release \
  --dart-define=FLAVOR=prod \
  --dart-define=ENABLE_PLAY_UPDATES=true \
  --dart-define=ENABLE_BLUETOOTH_SYNC=true \
  --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true \
  --dart-define=ENABLE_ANDROID_WIDGET=false \
  --dart-define=UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY
```
→ generates a SHA256 checksum → uploads the artifact → **uploads directly to Google Play** via `r0adkll/upload-google-play@v1` → prepares a **draft GitHub release** `v<version>` on the built commit, with a **prod APK** built from the same commit and flags (`io_caravella_egm-<version>.apk` + `.sha256`) and notes from the `CHANGELOG.md` section `[<version>]` (falling back to `[Unreleased]`, with a warning, if the changelog isn't finalized yet). A draft is not public and creates no tag until it's published; re-running the workflow for the same version replaces it, and it leaves an already published release alone.

The APK is signed with the upload key, while Play delivers the app re-signed with the Play App Signing key, so it can't update an install that came from Play — the release notes say so.

The upload authenticates as the service account in the `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret (`play-deploy@elegant-obelisk-472510-g8.iam.gserviceaccount.com`, Google Play Android Developer API enabled in its Cloud project). That account must be a Play Console user (**Users and permissions**) with app permissions on *Caravella* to release to testing tracks and production; without them the step fails with `The caller does not have permission`, which is why every run before 2.0.0 stopped at the upload.

Besides the AAB, the Store workflow uploads an `io_caravella_egm-<version>-mapping` artifact (R8 `mapping.txt` + `native-debug-symbols.zip`, kept 90 days). Play already gets both from inside the AAB but never lets you download them again, so this copy is what you use to retrace obfuscated class names that Play Console shows in recommendations or crash reports.

## `Store - Promote.yml` ("Android CI - Store Promote")

Manually triggered with inputs `target_branch`, `track` (default `production`), `rollout` (user fraction, `1` = full), `promote_release` (off = listing-only update, track untouched), `update_listing` and `dry_run`. It builds nothing: it promotes the version code already uploaded by `Store - Android.yml` (read from `pubspec.yaml` on `target_branch`), in one Play edit via [`.github/scripts/play_publish.py`](../.github/scripts/play_publish.py):
- sets the track's release to that version code, with release notes from `store/changelog/release-notes-<version>.xml` (one `<locale>` block per language, ≤500 chars each);
- replaces each existing store listing's **short and full description** with the "Short Description" (≤80 chars) and "Full Description" (≤4000) sections of `store/metadata/listing_<lang>.md`, and its **feature graphic** with `store/assets/feature-graphic/<lang>.png` (1024×500) when that file exists. The title stays as it is on Play, because the repo titles exceed Play's 30-char limit in some languages. Regional variants share one file (`es-ES`/`es-419`/`es-US` → `listing_es.md`, `pt-BR`/`pt-PT` → `listing_pt.md`).

Phone screenshots are replaced the same way from `store/screenshots/<lang>/*.jpg` (sorted by file name, max 8; `es-*`/`pt-*` variants share a folder). They are framed marketing shots (1080×1920, localized caption on brand teal, phone frame) rendered from `store/screenshots/frame.html?lang=<lang>&i=<0-7>` around the raw captures in `store/screenshots/raw/`. To refresh them: install the prod build on an emulator (AAB from the Store run artifact → `bundletool build-apks --connected-device`), restore the demo backup produced by `store/screenshots/demo/make_demo.py` (Settings → Data management → Restore), turn off *Protect screen*, enable status-bar demo mode, capture each screen with `adb exec-out screencap -p` (`demo/adb_ui.py` taps UI nodes by label), then re-render `frame.html` for every language at a 1080×1920 viewport and export as JPEG. `frame.html` draws the raw captures on a 1280×2856 canvas: on a 1080×2400 emulator use `adb shell wm size 1280x2856` + `wm density 500` and gesture navigation (`cmd overlay enable-exclusive --category com.android.internal.systemui.navbar.gestural`). Its `fixQr` step paints over the emulator-only device name and warning at fixed rows measured on `raw/04-qr.png` — re-measure them whenever that capture changes. `make_demo.py` dates everything relative to its `NOW`; when the demo data is older than today, shifting the dates in the app's SQLite database (`run-as` copy of `databases/expense_groups.db`, millisecond columns `groups.start_date/end_date/timestamp`, `expenses.date`) keeps "today" populated. Copy the `en`/`it` sets to `fastlane/metadata/android/{en-US,it-IT}/images/phoneScreenshots/` for F-Droid.

The feature graphics are rendered from `store/assets/feature-graphic/feature-graphic.html` (brand teal, Montserrat, logo and two app screenshots; `?lang=en|it|es|pt|zh` picks the copy): open it in a 1024×500 viewport and screenshot it, e.g. `agent-browser set viewport 1024 500 && agent-browser open "file://$PWD/store/assets/feature-graphic/feature-graphic.html?lang=it" && agent-browser screenshot store/assets/feature-graphic/it.png`.

Only languages that already have a Play store listing are touched. `dry_run` validates the edit and discards it. Updating the listing additionally needs the service account's **Manage store presence** app permission in Play Console; with release permissions only, `validate`/`commit` fail with `The caller does not have permission`.

When `track=production`, `promote_release` is on and it isn't a `dry_run`, it then **publishes the draft GitHub release** `v<version>` (creating the tag on the commit the Store run built) and marks it Latest, after refreshing its notes from `CHANGELOG.md` `[<version>]`. If there's no draft, the step fails after Play has already been promoted — run `Store - Android.yml` for that version, then promote again (Play accepts re-promoting the same version code). So GitHub's releases list mirrors what is in production on Play, plus `-rc` pre-releases for testing.

Typical release: optionally `Pre-release - Android.yml` for testers → prepare the release (version bump, changelogs, store notes) → `Store - Android.yml` with `track=internal`, test → this workflow with `track=production`.

## Things the workflows have in common

- Flutter is pinned to a specific stable version (check the `flutter-version:` key in each workflow file for the current pin — it's bumped periodically and this page won't track it).
- **`ENABLE_ANDROID_WIDGET` follows the flavor in CI**: `true` for every `staging` build (`Development - Android.yml`'s `build` job and `Pre-release - Android.yml`), `false` for every `prod` build (`Store - Android.yml`'s App Bundle and GitHub-release APK). This matches `android/app/build.gradle.kts`'s native per-flavor default (on for `dev`/`staging`, off for `prod`) — see [Build Variants § Android home widget](BUILD_VARIANTS.md#android-home-widget).
- No workflow ever builds an F-Droid APK; the FOSS variant is only analyzed and dependency-checked (see the `build` job above). The APK itself is only built by F-Droid's own build server — see [F-Droid Submission](FDROID_SUBMISSION.md).
- The build workflows all pass `ENABLE_BLUETOOTH_SYNC=true` (redundant with its default, kept explicit for parity with `ENABLE_PLAY_UPDATES`) and `ENABLE_GOOGLE_DRIVE_SYNC=true` — the staging APK and prod App Bundle CI produces both ship with the real Google Drive cloud channel reachable. This requires OAuth clients registered in Google Cloud Console for `io.caravella.egm.staging` and `io.caravella.egm` against the matching signing certificate's SHA-1 — the release (upload) keystore for the staging APK and the GitHub Release prod APK, and additionally the **Play App Signing** key for `io.caravella.egm`, since Google Play re-signs the App Bundle with its own key before delivering it — or Google Sign-In will fail with `DEVELOPER_ERROR` in these builds — see the [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md).

## See also

- [Build Variants & Flavors](BUILD_VARIANTS.md) — what each dart-define flag actually does
- [F-Droid Submission](FDROID_SUBMISSION.md)
- [Google Drive Sync Setup Guide](GOOGLE_DRIVE_SYNC_SETUP.md) — required before `ENABLE_GOOGLE_DRIVE_SYNC=true` builds can actually sign in
- Root `CLAUDE.md` — local command reference
