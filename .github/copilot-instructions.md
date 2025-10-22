# Caravella Flutter App
- Multi-platform group expense tracker built with Flutter 3 stable + Material 3; flavors selected via `--dart-define=FLAVOR=dev|staging|prod`.
- Run inside macOS/zsh; prefer flutter stable (CI uses 3.35.x) and consult these notes before ad-hoc scripts.

## Core Architecture
- Entry point `lib/main.dart` wires `AppConfig` from the FLAVOR define, locks portrait, enables Android edge-to-edge, and injects providers (`ExpenseGroupNotifier`, `UserNameNotifier`, `LocaleNotifier`, `ThemeModeNotifier`).
- Routes observe navigation through `routeObserver` so pages like `HomePage` can refresh on `didPopNext`.
- Environment-aware app name/banner live in `lib/config/app_config.dart`; avoid hardcoding labels elsewhere.
- SharedPreferences back locale/theme selection; mutations update via notifier callbacks not direct prefs writes.

## Data & Persistence
- Use `ExpenseGroupStorageV2` as the façade for all trip/expense CRUD; it wraps `FileBasedExpenseGroupRepository` which performs caching, indexing, and integrity checks.
- `FileBasedExpenseGroupRepository` saves to `${ApplicationDocumentsDirectory}/expense_group_storage.json`; it automatically enforces a single pinned group and prunes stale cache with `forceReload`.
- When editing groups, rely on helper APIs like `updateParticipantReferencesFromDiff`/`updateCategoryReferencesFromDiff` so embedded expense snapshots stay consistent.
- Logger output flows through `lib/data/services/logger_service.dart`; prefer `LoggerService.warning` instead of `print`.

## UI & Interaction Patterns
- Home experience (`lib/home/home_page.dart` + `home/cards`) listens to `ExpenseGroupNotifier.updatedGroupIds` and consumes `lastEvent` to show `AppToast` messages via the global `rootScaffoldMessenger`.
- Feature flows live under `lib/manager/**`; controllers (e.g., `group/group_form_controller.dart`) own form state, diff original models, and notify the global notifier after calling storage.
- Reusable surfaces live in `lib/widgets/` (`base_card.dart`, `bottom_sheet_scaffold.dart`, `material3_dialog.dart`); match spacing/shape tokens instead of bespoke layouts.
- For toasts or snackbars, always use `AppToast.show` or the shared `ScaffoldMessenger` key—direct `ScaffoldMessenger.of` calls break when contexts unmount after async work.

## Localization, Theming, Platform
- Strings come from the generated `io_caravella_egm` package (`gen.AppLocalizations`); never hardcode literals—inject locale via `LocaleNotifier`.
- Themes originate from `lib/themes/caravella_themes.dart` and respect Material 3 color roles; update both light/dark variants together.
- Android-only secure flag toggles through `settings/flag_secure_android.dart` and SharedPreferences (`flag_secure_enabled`); reuse `_initFlagSecure` logic when adding new secure surfaces.
- Android 15+ compatibility: system bar colors managed via `SystemChrome.setSystemUIOverlayStyle` in `main.dart`; avoid setting colors in theme XML to prevent deprecated API warnings (see `docs/ANDROID_15_FIX.md`).

## Workflows & Quality Gates
- Standard loop: `flutter pub get`, `flutter analyze`, `flutter test` (2–3 min; do not abort). CI will fail without all three.
- Launch flavors with `flutter run --flavor dev|staging --dart-define=FLAVOR=...` or VS Code configs in `.vscode/launch.json`.
- Release APK builds use `flutter build apk --flavor {staging|prod} --release --dart-define=FLAVOR=...`; expect 8–12 minutes and avoid cancelling.
- Accessibility regression scripts (`validate_accessibility.sh`) and tests like `test/accessibility_localization_test.dart` assume semantics labels stay in sync.

## Contribution Checklist
- Favor provider-driven state and notify through `ExpenseGroupNotifier` so `HomeCardsSection` refreshes without full reloads.
- Preserve model IDs when cloning (`copyWith`) to keep repository indexes valid.
- Update `CHANGELOG.md` `[Unreleased]` for every user-visible change and note flavor-specific impacts when relevant.
- After touching persistence or i18n, run targeted tests (`flutter test test/background_removal_integration_test.dart`, etc.) to ensure storage and localization helpers still pass.