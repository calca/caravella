# CI Pipelines

Two GitHub Actions workflows exist under `.github/workflows/`. They are **not identical** to each other and neither is a single generic "lint → test → build" pipeline — read the actual YAML before assuming behavior, this page is a map, not a substitute.

## `Development - Android.yml` ("Android CI - Development")

Triggers: push/PR to `main`, and `release: published`.

- **`build` job** (runs unless the triggering event is a release): `flutter pub get` → `flutter analyze` → `flutter test --coverage` (uploads `coverage/lcov.info` as the `coverage-report` artifact — visibility only, no minimum-coverage gate) → build a **signed staging APK**:
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
- **`release` job** (runs only on `release: published`): skips `analyze`/`test` entirely, builds `staging` (if prerelease) or `prod` (otherwise), uploads the APK, then **auto-bumps the patch version and versionCode in `pubspec.yaml` and pushes the bump to `main`**. Be aware of this when reasoning about `pubspec.yaml`'s version history — some bumps are bot-authored, not manual. It passes `ENABLE_ANDROID_WIDGET=true` for the `staging` path and `=false` for the `prod` path (see `WIDGET_FLAG` in the "Determine build flavor" step), matching each flavor's native Gradle default.

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
→ generates a SHA256 checksum → uploads the artifact → **uploads directly to Google Play** via `r0adkll/upload-google-play@v1`.

The upload authenticates as the service account in the `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret (`play-deploy@elegant-obelisk-472510-g8.iam.gserviceaccount.com`, Google Play Android Developer API enabled in its Cloud project). That account must be a Play Console user (**Users and permissions**) with app permissions on *Caravella* to release to testing tracks and production; without them the step fails with `The caller does not have permission`, which is why every run before 2.0.0 stopped at the upload.

## `Store - Promote.yml` ("Android CI - Store Promote")

Manually triggered with inputs `target_branch`, `track` (default `production`), `rollout` (user fraction, `1` = full), `promote_release` (off = listing-only update, track untouched), `update_listing` and `dry_run`. It builds nothing: it promotes the version code already uploaded by `Store - Android.yml` (read from `pubspec.yaml` on `target_branch`), in one Play edit via [`.github/scripts/play_publish.py`](../.github/scripts/play_publish.py):
- sets the track's release to that version code, with release notes from `store/changelog/release-notes-<version>.xml` (one `<locale>` block per language, ≤500 chars each);
- replaces each existing store listing's **short and full description** with the "Short Description" (≤80 chars) and "Full Description" (≤4000) sections of `store/metadata/listing_<lang>.md`, and its **feature graphic** with `store/assets/feature-graphic/<lang>.png` (1024×500) when that file exists. The title stays as it is on Play, because the repo titles exceed Play's 30-char limit in some languages. Regional variants share one file (`es-ES`/`es-419`/`es-US` → `listing_es.md`, `pt-BR`/`pt-PT` → `listing_pt.md`).

The feature graphics are rendered from `store/assets/feature-graphic/feature-graphic.html` (brand teal, Montserrat, logo and two app screenshots; `?lang=en|it|es|pt|zh` picks the copy): open it in a 1024×500 viewport and screenshot it, e.g. `agent-browser set viewport 1024 500 && agent-browser open "file://$PWD/store/assets/feature-graphic/feature-graphic.html?lang=it" && agent-browser screenshot store/assets/feature-graphic/it.png`.

Only languages that already have a Play store listing are touched. `dry_run` validates the edit and discards it. Updating the listing additionally needs the service account's **Manage store presence** app permission in Play Console; with release permissions only, `validate`/`commit` fail with `The caller does not have permission`.

Typical release: run `Store - Android.yml` with `track=internal`, test, then run this workflow with `track=production`.

## Things both workflows have in common

- Flutter is pinned to a specific stable version (check the `flutter-version:` key in each workflow file for the current pin — it's bumped periodically and this page won't track it).
- **`ENABLE_ANDROID_WIDGET` follows the flavor in CI**: `true` for every `staging` build (`Development - Android.yml`'s `build` job, and its `release` job when the release is a prerelease), `false` for every `prod` build (`Development - Android.yml`'s `release` job for a non-prerelease, and `Store - Android.yml`'s prod App Bundle). This matches `android/app/build.gradle.kts`'s native per-flavor default (on for `dev`/`staging`, off for `prod`) — see [Build Variants § Android home widget](BUILD_VARIANTS.md#android-home-widget).
- Neither workflow ever builds an F-Droid-style artifact (`ENABLE_PLAY_UPDATES` omitted). That build variant is only ever exercised by F-Droid's own build server — see [F-Droid Submission](FDROID_SUBMISSION.md).
- Both workflows now also pass `ENABLE_BLUETOOTH_SYNC=true` (redundant with its default, kept explicit for parity with `ENABLE_PLAY_UPDATES`) and `ENABLE_GOOGLE_DRIVE_SYNC=true` — the staging APK and prod App Bundle CI produces both ship with the real Google Drive cloud channel reachable. This requires OAuth clients registered in Google Cloud Console for `io.caravella.egm.staging` and `io.caravella.egm` against the matching signing certificate's SHA-1 — the release (upload) keystore for the staging APK and the GitHub Release prod APK, and additionally the **Play App Signing** key for `io.caravella.egm`, since Google Play re-signs the App Bundle with its own key before delivering it — or Google Sign-In will fail with `DEVELOPER_ERROR` in these builds — see the [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md).

## See also

- [Build Variants & Flavors](BUILD_VARIANTS.md) — what each dart-define flag actually does
- [F-Droid Submission](FDROID_SUBMISSION.md)
- [Google Drive Sync Setup Guide](GOOGLE_DRIVE_SYNC_SETUP.md) — required before `ENABLE_GOOGLE_DRIVE_SYNC=true` builds can actually sign in
- Root `CLAUDE.md` — local command reference
