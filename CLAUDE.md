# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

@.github/copilot-instructions.md

## Commands

```bash
# Install deps (run in root AND in any package you touch)
flutter pub get

# Static analysis (CI-gating)
flutter analyze

# Full test suite (~2-3 min; do not abort mid-run)
flutter test

# Single test file
flutter test test/expense_group_notifier_metadata_test.dart

# Single test by name
flutter test test/expense_group_notifier_metadata_test.dart --plain-name "test description"

# Run app (flavor + FLAVOR define must match)
flutter run --flavor dev --dart-define=FLAVOR=dev
flutter run --flavor staging --dart-define=FLAVOR=staging

# Release APK (8-12 min; do not cancel)
flutter build apk --flavor staging --release --dart-define=FLAVOR=staging --dart-define=ENABLE_PLAY_UPDATES=true
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod --dart-define=ENABLE_PLAY_UPDATES=true

# Regenerate localizations after editing lib/l10n/*.arb
flutter gen-l10n
```

CI (`.github/workflows/Development - Android.yml`) runs exactly: `flutter pub get` → `flutter analyze` → `flutter test` → **`flutter test` inside each of the 5 `packages/*` (own `pub get` + `flutter test`, since they're separate Dart packages the root `flutter test` never reaches)** → signed staging APK build. Match this locally before pushing — when touching a package, also run `(cd packages/<name> && flutter pub get && flutter test)`.

## Package boundaries

- `lib/` → all packages.
- `caravella_core_ui` → `caravella_core` only.
- `caravella_core` → independent (no dependency on other local packages).
- `android_app_functions` (exposes app capabilities to Android AI agents/shortcuts) and `play_store_updates` (conditional on `ENABLE_PLAY_UPDATES=true`) both depend on `caravella_core` (and `play_store_updates` also on `caravella_core_ui`).
- `google_drive_sync` (Google Drive cloud relay for the sync feature, conditional on `ENABLE_GOOGLE_DRIVE_SYNC=true` — see [`docs/GOOGLE_DRIVE_SYNC_SETUP.md`](docs/GOOGLE_DRIVE_SYNC_SETUP.md)) depends on `caravella_core` only.
- `lib/main.dart` is a thin entrypoint; actual startup sequencing (Talker logging init, `AppInitialization.initialize()`, shortcuts, Android App Functions, `runApp`) lives in `lib/main/app_initialization.dart` and `lib/main/caravella_app.dart`. Provider wiring is factored out into `lib/main/provider_setup.dart` (`ProviderSetup.createProviders` / `wrapWithNotifiers`) rather than inline in `main.dart`.

## Documentation

`docs/` is a wiki, reverse-engineered from the current source — start at [`docs/README.md`](docs/README.md) (index) or [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) (system overview, package boundaries, startup sequence, feature map). Docs worth reading before touching specific areas:

- [`docs/STORAGE_BACKEND.md`](docs/STORAGE_BACKEND.md) — storage backend/migration details (see "Data & Persistence" in copilot-instructions.md for the summary).
- [`docs/BUILD_VARIANTS.md`](docs/BUILD_VARIANTS.md), [`docs/FDROID_SUBMISSION.md`](docs/FDROID_SUBMISSION.md), [`docs/CI_PIPELINES.md`](docs/CI_PIPELINES.md) — flavors, every dart-define flag, Play Store vs F-Droid, and what CI actually runs.
- [`docs/RECEIPT_OCR.md`](docs/RECEIPT_OCR.md) — on-device receipt OCR flow.
- [`docs/ANDROID_15_FIX.md`](docs/ANDROID_15_FIX.md) — system bar color handling, referenced from copilot-instructions.
- [`docs/GOOGLE_DRIVE_SYNC_SETUP.md`](docs/GOOGLE_DRIVE_SYNC_SETUP.md) — Google Cloud Console setup for the optional Drive cloud relay (`ENABLE_GOOGLE_DRIVE_SYNC`); [`docs/PACKAGE_GOOGLE_DRIVE_SYNC.md`](docs/PACKAGE_GOOGLE_DRIVE_SYNC.md) for how the code fits together.

**When you change code that a doc page describes, update that page in the same change** — see [`docs/MAINTAINING_DOCS.md`](docs/MAINTAINING_DOCS.md) for the code-area → doc-page map and the writing conventions that keep these pages from going stale.
