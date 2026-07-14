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
    --dart-define=ENABLE_ANDROID_WIDGET=false \
    --dart-define=UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY
  ```
  This is the sequence CLAUDE.md means by "match this locally before pushing" — reproduce it with `flutter pub get && flutter analyze && flutter test` before opening a PR.
- **`release` job** (runs only on `release: published`): skips `analyze`/`test` entirely, builds `staging` (if prerelease) or `prod` (otherwise), uploads the APK, then **auto-bumps the patch version and versionCode in `pubspec.yaml` and pushes the bump to `main`**. Be aware of this when reasoning about `pubspec.yaml`'s version history — some bumps are bot-authored, not manual.

## `Store - Android.yml` ("Android CI - Store")

Manually triggered (`workflow_dispatch`) with inputs `target_branch` and `track` (`internal`/`alpha`/`beta`/`production`).

Steps: checkout → validate track → `flutter pub get` → `flutter analyze` → `flutter test` → build a **signed prod App Bundle**:
```bash
flutter build appbundle --flavor prod --release \
  --dart-define=FLAVOR=prod \
  --dart-define=ENABLE_PLAY_UPDATES=true \
  --dart-define=ENABLE_ANDROID_WIDGET=false \
  --dart-define=UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY
```
→ generates a SHA256 checksum → uploads the artifact → **uploads directly to Google Play** via `r0adkll/upload-google-play@v1`.

## Things both workflows have in common

- Flutter is pinned to a specific stable version (check the `flutter-version:` key in each workflow file for the current pin — it's bumped periodically and this page won't track it).
- **`ENABLE_ANDROID_WIDGET` is always `"false"`** in CI (job-level env var), for every flavor and every build type. If you need to verify the Android home-screen widget still works, you must build locally without that flag — CI will never catch a widget regression.
- Neither workflow ever builds an F-Droid-style artifact (`ENABLE_PLAY_UPDATES` omitted). That build variant is only ever exercised by F-Droid's own build server — see [F-Droid Submission](FDROID_SUBMISSION.md).

## See also

- [Build Variants & Flavors](BUILD_VARIANTS.md) — what each dart-define flag actually does
- [F-Droid Submission](FDROID_SUBMISSION.md)
- Root `CLAUDE.md` — local command reference
