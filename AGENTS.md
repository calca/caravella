# AGENTS.md

Working instructions for AI coding agents (Claude Code, GitHub Copilot, Codex, Gemini…) on Caravella. `CLAUDE.md` only imports this file.

## Project

- Caravella: a group expense tracker in Flutter 3 stable + Material 3, Android first. Flavors via `--flavor dev|staging|prod` with the matching `--dart-define=FLAVOR=…`.
- CI uses Flutter **3.50.0** stable; use the same locally. Runs on macOS/zsh.
- Multi-package: core logic in `packages/caravella_core`, shared UI in `packages/caravella_core_ui`, the app in `lib/` (see Package boundaries).

## Commands

```bash
# Install deps (run in root AND in any package you touch)
flutter pub get

# Static analysis (CI-gating)
flutter analyze

# Full test suite (~2-3 min; do not abort mid-run)
flutter test

# Single test file / single test by name
flutter test test/expense_group_notifier_metadata_test.dart
flutter test test/expense_group_notifier_metadata_test.dart --plain-name "test description"

# Main flows on a running emulator (run for each rc by the pre-release workflow)
adb shell pm clear io.caravella.egm.dev && flutter test integration_test --flavor dev --dart-define=FLAVOR=dev

# Run app (flavor + FLAVOR define must match)
flutter run --flavor dev --dart-define=FLAVOR=dev
flutter run --flavor staging --dart-define=FLAVOR=staging

# Release APK (8-12 min; do not cancel)
flutter build apk --flavor staging --release --dart-define=FLAVOR=staging --dart-define=ENABLE_PLAY_UPDATES=true
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod --dart-define=ENABLE_PLAY_UPDATES=true

# Regenerate localizations after editing lib/l10n/*.arb
flutter gen-l10n
```

CI (`.github/workflows/Development - Android.yml`) runs exactly: `flutter pub get` → `flutter analyze` → `flutter test` → **`flutter test` inside each `packages/*` (own `pub get` + `flutter test`, since they're separate Dart packages the root `flutter test` never reaches)** → F-Droid (FOSS) variant guard → signed staging APK build → native unit tests (`cd android && ./gradlew :app:testStagingDebugUnitTest`). Match this locally before pushing — when touching a package, also run `(cd packages/<name> && flutter pub get && flutter test)`.

- Play Store builds add `--dart-define=ENABLE_PLAY_UPDATES=true`; F-Droid builds omit it (and use `./build_variant.sh foss`).
- `validate_accessibility.sh`, `validate_design_tokens.sh` and tests like `test/accessibility_localization_test.dart` assume semantics labels and design tokens stay in sync.
- Screenshots or screen recordings from a device come out black while the app's secure screen (Settings, `FLAG_SECURE`) is on: turn it off first.

## Package boundaries

- `lib/` → all packages.
- `caravella_core_ui` → `caravella_core` only.
- `caravella_core` → independent (no dependency on other local packages).
- `android_app_functions` (exposes app capabilities to Android AI agents/shortcuts) and `play_store_updates` (conditional on `ENABLE_PLAY_UPDATES=true`) both depend on `caravella_core` (and `play_store_updates` also on `caravella_core_ui`).
- `caravella_gms` holds **everything that needs a proprietary Google library** (Play Services, ML Kit, Play Core: location provider, receipt OCR, QR scanning, Bluetooth/Nearby, in-app review/updates, and it depends on `google_drive_sync`/`play_store_updates`). The app depends on it alone and uses `GmsIntegrations.instance` (interface in `caravella_core`); never add those libraries to the root `pubspec.yaml` or import them in `lib/`. `packages/caravella_gms_foss` has the same package name with nothing in it — `./build_variant.sh foss` (F-Droid build) switches to it via `pubspec_overrides.yaml`. See [`docs/PACKAGE_CARAVELLA_GMS.md`](docs/PACKAGE_CARAVELLA_GMS.md).
- `google_drive_sync` (Google Drive cloud relay for the sync feature, conditional on `ENABLE_GOOGLE_DRIVE_SYNC=true` — see [`docs/GOOGLE_DRIVE_SYNC_SETUP.md`](docs/GOOGLE_DRIVE_SYNC_SETUP.md)) depends on `caravella_core` only.
- New features: business logic in `caravella_core`, reusable UI in `caravella_core_ui`, app-specific UI in `lib/`. Import packages whole: `package:caravella_core/caravella_core.dart`, `package:caravella_core_ui/caravella_core_ui.dart`.

## Architecture

- `lib/main.dart` is a thin entrypoint: startup sequencing (Talker logging init, `AppInitialization.initialize()`, shortcuts, Android App Functions, `runApp`) lives in `lib/main/app_initialization.dart` and `lib/main/caravella_app.dart`. `AppInitialization` wires `AppConfig` from the FLAVOR define, locks portrait and enables edge-to-edge; `lib/main/provider_setup.dart` (`ProviderSetup.createProviders` / `wrapWithNotifiers`) injects the providers (`ExpenseGroupNotifier`, `UserNameNotifier`, `LocaleNotifier`, `ThemeModeNotifier`).
- Routes observe navigation through `routeObserver` so pages like `HomePage` can refresh on `didPopNext`.
- Environment-aware app name/banner live in `packages/caravella_core/lib/config/app_config.dart`; don't hardcode labels elsewhere.
- SharedPreferences back locale/theme selection; mutations go through notifier callbacks, not direct prefs writes.
- Home (`lib/home/home_page.dart` + `home/cards`) listens to `ExpenseGroupNotifier.updatedGroupIds` and consumes `lastEvent`. Favor provider-driven state and notify through `ExpenseGroupNotifier` so `HomeCardsSection` refreshes without full reloads.
- Feature flows live under `lib/manager/**`; controllers (e.g. `group/group_form_controller.dart`) own form state, diff original models, and notify the global notifier after calling storage.

## Data & persistence

- Use `ExpenseGroupStorageV2` (from `caravella_core`) as the façade for all group/expense CRUD; it delegates to whichever `IExpenseGroupRepository` `ExpenseGroupRepositoryFactory` hands back, and adds caching, indexing and integrity checks.
- **SQLite (`SqliteExpenseGroupRepository`) is the only backend** — normalized tables (`groups`, `participants`, `categories`, `expenses`, …) with foreign keys on and indexes. The old JSON file (`${ApplicationDocumentsDirectory}/expense_group_storage.json`) is only read once, by `StorageMigrationService` via `LegacyJsonGroupReader`. See [`docs/STORAGE_BACKEND.md`](docs/STORAGE_BACKEND.md).
- Never depend on the concrete repository; go through `ExpenseGroupStorageV2` / `IExpenseGroupRepository`. It enforces a single pinned group. In tests, `useTestDatabase()` (`test/helpers/test_database.dart`) gives the app a fresh SQLite database in a temporary file.
- When editing groups, use `updateParticipantReferencesFromDiff`/`updateCategoryReferencesFromDiff` so embedded expense snapshots stay consistent. Preserve model IDs when cloning (`copyWith`).
- After touching persistence or i18n, run the targeted tests too (e.g. `flutter test test/background_removal_integration_test.dart`).

## UI

- **Before building any new screen, dialog, card or chart, check `packages/caravella_core_ui/` first.** It's the shared design system, meant to be reused, not reimplemented, from `lib/`.
  - Layout/containers: `BaseCard`, `CaravellaBottomSheetScaffold`, `SectionHeader`, `CaravellaAppBar`, `CaravellaTabBar`, `BottomActionBar`.
  - Feedback: `AppToast` (toasts/snackbars — never call `ScaffoldMessenger.of` directly), `Material3Dialog` (dialogs), `showSelectionBottomSheet<T>()` (picker sheet).
  - Data display: `CurrencyDisplay`, `NoExpense` (empty states), the `charts/` widgets (`SpendingBars`, `SpendingWave`, `MonthlyExpenseChart`, `WeeklyExpenseChart`, `Last15DaysBarChart`, `ChartBadge`) and `map/` widgets.
  - `AddFab`, `AppSystemUi`, `group_background_utils.dart`, `utils/debounce.dart` cover FAB, system UI styling, group background rendering and debouncing.
  - Build a bespoke widget in `lib/` only when nothing in `caravella_core_ui` fits; once a widget is useful in a second flow, promote it there instead of copy-pasting.
  - Use the tokens and text styles from `themes/caravella_themes.dart`, `themes/app_text_styles.dart` (incl. `AppTypography.fontFamily`), `themes/app_spacing.dart` (`AppSpacing`), `themes/app_radius.dart` (`AppRadius`) and `themes/form_theme.dart` instead of hardcoded values; `./validate_design_tokens.sh` guards known regressions in CI.
- Strings come from the generated `io_caravella_egm` package (`gen.AppLocalizations`); never hardcode literals. Locale via `LocaleNotifier`.
- Themes originate from `caravella_themes.dart` and respect Material 3 color roles; update light and dark together.
- The Android secure flag goes through `lib/settings/flag_secure_android.dart` and `PreferencesService`; reuse `AppInitialization.initFlagSecure` when adding secure surfaces.
- Android 15+: system bar colors are set from Flutter via `AppSystemUi` (`caravella_core_ui`, an `AnnotatedRegion<SystemUiOverlayStyle>`); don't set them in theme XML (see [`docs/ANDROID_15_FIX.md`](docs/ANDROID_15_FIX.md)).

## Logging

- **Always use `LoggerService`** (from `caravella_core`, Talker 5.x) — never `print()` or `debugPrint()`.
- Levels: `debug()` troubleshooting, `info()` operations/events, `warning()` recoverable issues and fallbacks, `error()` errors with optional `error` and `stackTrace`.
- Always pass a `name` category: `notification`, `manager.group`, `state.notifier`, `storage`, `ui.*` (e.g. `ui.sheet`), `api.*` (e.g. `api.nominatim`), `settings`, `sync.*`.

```dart
LoggerService.info('Restoring notification for group: ${group.title}', name: 'notification');
LoggerService.warning('Group not found: $groupId', name: 'notification');
LoggerService.error('Failed to save group', name: 'storage', error: e, stackTrace: st);
```

- The log screen (TalkerScreen) is in Settings → Debug Logs in debug builds or with `--dart-define=ENABLE_TALKER_SCREEN=true`.

## Documentation and changelog

`docs/` is a wiki, reverse-engineered from the current source — start at [`docs/README.md`](docs/README.md) (index) or [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) (system overview, package boundaries, startup sequence, feature map). Worth reading before touching specific areas:

- [`docs/STORAGE_BACKEND.md`](docs/STORAGE_BACKEND.md) — storage backend, schema versions and migrations.
- [`docs/BUILD_VARIANTS.md`](docs/BUILD_VARIANTS.md), [`docs/FDROID_SUBMISSION.md`](docs/FDROID_SUBMISSION.md), [`docs/CI_PIPELINES.md`](docs/CI_PIPELINES.md) — flavors, every dart-define flag, Play Store vs F-Droid, and what CI actually runs.
- [`docs/SYNC_ARCHITECTURE.md`](docs/SYNC_ARCHITECTURE.md) — device sync and conflict resolution.
- [`docs/RECEIPT_OCR.md`](docs/RECEIPT_OCR.md) — on-device receipt OCR flow.
- [`docs/ANDROID_15_FIX.md`](docs/ANDROID_15_FIX.md) — system bar color handling.
- [`docs/GOOGLE_DRIVE_SYNC_SETUP.md`](docs/GOOGLE_DRIVE_SYNC_SETUP.md) — Google Cloud Console setup for the optional Drive cloud relay; [`docs/PACKAGE_GOOGLE_DRIVE_SYNC.md`](docs/PACKAGE_GOOGLE_DRIVE_SYNC.md) for how the code fits together.

**When you change code that a doc page describes, update that page in the same change** — see [`docs/MAINTAINING_DOCS.md`](docs/MAINTAINING_DOCS.md) for the code-area → doc-page map and the writing conventions.

Update `CHANGELOG.md` `[Unreleased]` for every user-visible change, noting flavor-specific impacts when relevant.
