# Caravella Flutter App
- Multi-platform group expense tracker built with Flutter 3 stable + Material 3; flavors selected via `--dart-define=FLAVOR=dev|staging|prod`.
- Run inside macOS/zsh; prefer flutter stable (CI uses 3.38.x) and consult these notes before ad-hoc scripts.
- **Multi-package architecture**: Core logic in `packages/caravella_core`, UI components in `packages/caravella_core_ui`, updates in `packages/play_store_updates`, main app in `lib/`.

## Core Architecture
- Entry point `lib/main.dart` wires `AppConfig` from the FLAVOR define, locks portrait, enables Android edge-to-edge, and injects providers (`ExpenseGroupNotifier`, `UserNameNotifier`, `LocaleNotifier`, `ThemeModeNotifier`).
- Routes observe navigation through `routeObserver` so pages like `HomePage` can refresh on `didPopNext`.
- Environment-aware app name/banner live in `packages/caravella_core/lib/config/app_config.dart`; avoid hardcoding labels elsewhere.
- SharedPreferences back locale/theme selection; mutations update via notifier callbacks not direct prefs writes.

## Package Structure
- **`packages/caravella_core/`**: Business logic, data models, storage, services (logging, shortcuts, preferences, rating), state management
  - Services organized by category: `logging/`, `shortcuts/`, `storage/`, `user/`
  - Export: `import 'package:caravella_core/caravella_core.dart';`
- **`packages/caravella_core_ui/`**: Reusable UI components, widgets, themes-independent components
  - Export: `import 'package:caravella_core_ui/caravella_core_ui.dart';`
- **`packages/play_store_updates/`**: Google Play Store update functionality (conditional with `ENABLE_PLAY_UPDATES=true`)
  - Export: `import 'package:play_store_updates/play_store_updates.dart';`
- **`lib/`**: App-specific UI, pages, managers, main app logic

## Data & Persistence
- Use `ExpenseGroupStorageV2` (from `caravella_core`) as the façade for all trip/expense CRUD; it wraps `FileBasedExpenseGroupRepository` which performs caching, indexing, and integrity checks.
- `FileBasedExpenseGroupRepository` saves to `${ApplicationDocumentsDirectory}/expense_group_storage.json`; it automatically enforces a single pinned group and prunes stale cache with `forceReload`.
- When editing groups, rely on helper APIs like `updateParticipantReferencesFromDiff`/`updateCategoryReferencesFromDiff` so embedded expense snapshots stay consistent.
- Logger output flows through `packages/caravella_core/lib/services/logging/logger_service.dart`; prefer `LoggerService.warning` instead of `print`.

## UI & Interaction Patterns
- Home experience (`lib/home/home_page.dart` + `home/cards`) listens to `ExpenseGroupNotifier.updatedGroupIds` (from `caravella_core`) and consumes `lastEvent` to show `AppToast` messages (from `caravella_core_ui`) via the global `rootScaffoldMessenger`.
- Feature flows live under `lib/manager/**`; controllers (e.g., `group/group_form_controller.dart`) own form state, diff original models, and notify the global notifier after calling storage.
- Reusable UI components live in `packages/caravella_core_ui/` (`base_card.dart`, `bottom_sheet_scaffold.dart`, `material3_dialog.dart`, `app_toast.dart`); match spacing/shape tokens instead of bespoke layouts.
- For toasts or snackbars, always use `AppToast.show` (from `caravella_core_ui`) or the shared `ScaffoldMessenger` key—direct `ScaffoldMessenger.of` calls break when contexts unmount after async work.

## Localization, Theming, Platform
- Strings come from the generated `io_caravella_egm` package (`gen.AppLocalizations`); never hardcode literals—inject locale via `LocaleNotifier` (from `caravella_core`).
- Themes originate from `packages/caravella_core_ui/lib/themes/caravella_themes.dart` and respect Material 3 color roles; update both light/dark variants together.
- Android-only secure flag toggles through `settings/flag_secure_android.dart` and `PreferencesService` (from `caravella_core/services/storage/`); reuse `_initFlagSecure` logic when adding new secure surfaces.
- Android 15+ compatibility: system bar colors managed via `SystemChrome.setSystemUIOverlayStyle` in `main.dart`; avoid setting colors in theme XML to prevent deprecated API warnings (see `docs/ANDROID_15_FIX.md`).

## Services Organization
- Services in `packages/caravella_core/lib/services/` are organized by category:
  - **`logging/`**: `LoggerService` for structured logging
  - **`shortcuts/`**: Android app shortcuts (`AppShortcutsService`, `PlatformShortcutsManager`, `ShortcutsNavigationService`)
  - **`storage/`**: `PreferencesService` for SharedPreferences access
  - **`user/`**: `RatingService` for in-app reviews
- Use `import 'package:caravella_core/caravella_core.dart';` to access all services.

## Workflows & Quality Gates
- Standard loop: `flutter pub get` (run in root and packages), `flutter analyze`, `flutter test` (2–3 min; do not abort). CI will fail without all three.
- Launch flavors with `flutter run --flavor dev|staging --dart-define=FLAVOR=...` or VS Code configs in `.vscode/launch.json`.
- **Play Store builds**: Add `--dart-define=ENABLE_PLAY_UPDATES=true` to enable Google Play updates (from `play_store_updates` package)
- **F-Droid builds**: Omit `ENABLE_PLAY_UPDATES` flag to exclude Play Store dependencies entirely
- Release APK builds use `flutter build apk --flavor {staging|prod} --release --dart-define=FLAVOR=...`; expect 8–12 minutes and avoid cancelling.
- Accessibility regression scripts (`validate_accessibility.sh`) and tests like `test/accessibility_localization_test.dart` assume semantics labels stay in sync.

## Contribution Checklist
- Favor provider-driven state and notify through `ExpenseGroupNotifier` (from `caravella_core`) so `HomeCardsSection` refreshes without full reloads.
- Preserve model IDs when cloning (`copyWith`) to keep repository indexes valid.
- **When adding new features**: Place business logic in `caravella_core`, reusable UI in `caravella_core_ui`, app-specific UI in `lib/`
- **Package dependencies**: `lib/` can depend on all packages; `caravella_core_ui` can depend on `caravella_core`; `caravella_core` should remain independent
- Update `CHANGELOG.md` `[Unreleased]` for every user-visible change and note flavor-specific impacts when relevant.
- After touching persistence or i18n, run targeted tests (`flutter test test/background_removal_integration_test.dart`, etc.) to ensure storage and localization helpers still pass.
- When modifying packages, run `flutter pub get` in both the package directory and root to update dependencies.