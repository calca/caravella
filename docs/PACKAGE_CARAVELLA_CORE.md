# Package: `caravella_core`

Business logic, data models, storage, and cross-cutting services. Independent of every other local package — see [Architecture Overview § package dependency rules](ARCHITECTURE.md#package-dependency-rules). Import as a whole: `import 'package:caravella_core/caravella_core.dart';`.

The barrel `caravella_core.dart` exports everything under `data/`, `model/`, and `state/` wholesale, plus selected files under `services/`. **`services/backup_service.dart` is deliberately not in the barrel** — import it directly (`package:caravella_core/services/backup_service.dart`) as `AutoBackupNotifier` does.

## Storage architecture

`IExpenseGroupRepository` (`data/expense_group_repository.dart`) is the abstract contract every backend implements: `getAllGroups/getActiveGroups/getArchivedGroups/getGroupById/getExpenseById/getPinnedGroup/saveGroup/addExpenseGroup/updateGroupMetadata/deleteGroup/setPinnedGroup/removePinnedGroup/archiveGroup/unarchiveGroup/validateGroup/checkDataIntegrity/getTotalExpenses/getTodaySpending/getRecentExpenses/getTotalExpenseCount`, all returning `StorageResult<T>` (success/failure wrapper with `unwrap()`/`unwrapOr()`/`map()`). The same file defines `ExpenseGroupValidator.validate(group)` (empty title/currency, date ordering, duplicate participant/category IDs, non-positive expense amounts, dangling references) and `validateDataIntegrity(groups)` (duplicate group IDs, more than one pinned-and-non-archived group).

Full details on both backends, the SQLite schema, the factory, `ExpenseGroupStorageV2`, and the migration flow live in **[Storage Backend](STORAGE_BACKEND.md)** — this page only summarizes the pieces that matter for day-to-day feature work:

- Never depend on `SqliteExpenseGroupRepository`/`FileBasedExpenseGroupRepository` directly — always go through `ExpenseGroupStorageV2` (a static facade) or `IExpenseGroupRepository`, so code works under both backends.
- `ExpenseGroupStorageV2.updateParticipantReferencesFromDiff` / `updateCategoryReferencesFromDiff` propagate a participant/category rename into the denormalized copies embedded in historical expenses — use these instead of hand-rolling the update whenever a group's participants/categories are edited.
- `forceReload()`/`clearCache()` only matter for the file-based backend (no-ops on SQLite) but are safe to call unconditionally.

## Domain models (`model/`)

- **`ExpenseGroup`** — `id` (uuid v4), `title`, `expenses`, `participants`, `categories`, `startDate`/`endDate` (nullable), `currency`, `timestamp`, `pinned`/`archived`, `file` (background image path), `color` (legacy ARGB int or palette index), `notificationEnabled`, `groupType`, `autoLocationEnabled`. `copyWith` uses a sentinel to distinguish "not passed" from "explicit null" for `file`/`color`/`groupType`. Carries derived-stat methods used throughout the stats UI: `getTotalExpenses`, `getDailyAverage`, `getMonthlyAverage`, `getCategoryTotals`, `getParticipantTotals`, `getParticipantActivityCounts`, `getUncategorizedTotal`, `getTodaySpendingSync`, `getAveragePerParticipant`, `getEffectiveDateRange`, `getParticipantsByActivity`. `ExpenseGroup.empty()` seeds new-group flows.
- **`ExpenseDetails`** — `id`, `category`/`paidBy` (full embedded objects, not just IDs — this is why rename-propagation exists), `amount`, `date`, `note`, `name`, `location`, `attachments` (file paths).
- **`ExpenseParticipant`** / **`ExpenseCategory`** — `id`, `name`, `createdAt`; equality by `id` only.
- **`ExpenseLocation`** — lat/lng plus full geocoding detail (`street`, `locality`, `administrativeArea`, `postalCode`, `country`, ...); `hasLocation`/`displayText` (name → address → coordinates fallback).
- **`ExpenseGroupType`** (enum `personal, family, travel, other`) — carries an icon and `defaultCategoryKeys` (i18n keys) used to seed categories for new groups.
- **`GroupTypeTemplate`** — user-defined custom group type (`iconCodePoint`, `defaultCategories`), persisted separately via `GroupTypeTemplateService`/`PreferencesService`, not in group storage.
- **`group_settlements.dart`** — `computeSettlements(ExpenseGroup) → List<Settlement>`: the "who owes whom" algorithm. See [App: Group Details & Stats § Settlements algorithm](APP_GROUP_DETAILS_STATS.md#settlements-algorithm) for the full write-up.
- **`ExpenseGroupColorPalette`** — theme-aware color resolution (`resolveGroupColor(group, colorScheme)`), 12-color palette mapped onto `ColorScheme` roles so group colors adapt to light/dark mode; also handles legacy ARGB migration and text-contrast helpers.

## State notifiers (`state/`)

- **`ExpenseGroupNotifier`** (`ChangeNotifier`) — the central state hub. Holds `_currentGroup`; exposes `updatedGroupIds`/`deletedGroupIds` (unmodifiable lists UI listens to for incremental refresh) and `lastEvent`/`consumeLastEvent()` (values seen: `category_added`, `participant_added`). Mutators: `setCurrentGroup`, `updateGroupMetadata` (persists + preserves in-memory expenses), `addCategory`/`addParticipant` (dedupe by name), `refreshGroup`, `updateGroupPin`/`updateGroupArchive` (persist, refresh current group if it matches, then trigger shortcuts update). Two injectable platform hooks: `setShortcutsUpdateCallback` and `setNotificationCancelCallback` (both wired in `lib/main/provider_setup.dart`).
- **`LocaleNotifier`**, **`ThemeModeNotifier`**, **`DynamicColorNotifier`** — all `InheritedWidget`s (not `ChangeNotifier`) carrying a value + change callback, with a static `.of(context)` accessor.
- **`UserNameNotifier`**, **`FlagSecureNotifier`**, **`AppFunctionsEnabledNotifier`**, **`AutoBackupNotifier`** — thin `ChangeNotifier`s over single `SharedPreferences` keys. `AutoBackupNotifier` additionally reconciles its pref against the platform's real backup state via `BackupService` on load, and calls `BackupService.setBackupEnabled`/`requestBackup` when toggled.

## Services (`services/`)

- **`LoggerService`** (`logging/logger_service.dart`) — Talker-backed. `initialize({useHistory, maxHistoryItems, minLevel})`; `LoggerService.instance` self-initializes lazily. `debug/info/warning/error(message, {name, error, stackTrace})`. Always use this instead of `print`/`debugPrint` — see the logging conventions in the root `CLAUDE.md`.
- **`PreferencesService`** (`storage/preferences_service.dart`) — singleton over `SharedPreferences`, initialized via `PreferencesService.initialize()` (throws `StateError` if `.instance` is read first). Organized into typed sub-namespaces: `.locale`, `.theme`, `.security`, `.user`, `.backup`, `.storeRating`, `.appState`, `.appFunctions`, `.groupTypeTemplates`.
- **Media service abstractions** (`media/`) — `FilePickerService`, `ImageCompressionService`, `LocationServiceAbstraction` are pure interfaces with no implementation in this package; concrete implementations live in `lib/manager/expense/services/*_impl.dart` (dependency-inversion boundary around `image_picker`/`file_picker`/`geolocator`).
- **Shortcuts** (`shortcuts/`) — `AppShortcutsService` (Android `MethodChannel('io.caravella.egm/shortcuts')`, picks up to 4 groups: pinned first, then 3 most-recently-updated), `PlatformShortcutsManager` (gates everything behind `Platform.isAndroid`), `ShortcutsNavigationService` (holds the global `navigatorKey`, dispatches shortcut taps to a group's detail page).
- **`BackupService`** (`services/backup_service.dart`, not in the barrel) — Android backup toggle via `MethodChannel('io.caravella.egm/backup')` (enabling can be triggered, disabling cannot be forced — a platform limitation); iOS uses inverted "exclude from backup" semantics.
- **`AttachmentsStorageService`** — stores expense attachment files under `Documents/Caravella/<sanitized-group-name>[_<8-char-id>]/`, deliberately hidden from OS gallery/Files apps by design; disambiguates same-named groups via a hidden `.group_metadata` marker file.
- **`GroupTypeTemplateService`** — CRUD over `GroupTypeTemplate` list, persisted as one JSON blob via `PreferencesService.groupTypeTemplates`.
- **`RatingService`** — wraps `in_app_review`; prompts once the user reaches 10 total expenses, then re-prompts at most every 30 days.
- **`AppHomeWidgetService`** / **`PlatformHomeWidgetManager`** (`widgets/`) — Android home-screen widget via `home_widget`; parses `caravella://home_widget/add_expense` and `/open_group` deep links from widget taps. Gated behind `Platform.isAndroid && AppConfig.enableAndroidWidget`.

## `AppConfig` (`config/app_config.dart`)

```dart
enum Environment { dev, staging, prod }   // set via AppConfig.setEnvironment(...)

static const bool enableTalkerScreen  = bool.fromEnvironment('ENABLE_TALKER_SCREEN', defaultValue: false);
static const bool enableAndroidWidget = bool.fromEnvironment('ENABLE_ANDROID_WIDGET', defaultValue: true);
```

`AppConfig` does **not** define `FLAVOR` or `USE_JSON_BACKEND` — those dart-defines are read directly in the app's `lib/main/app_initialization.dart`. `ENABLE_PLAY_UPDATES` lives entirely in the sibling package `play_store_updates`. See [Build Variants & Flavors](BUILD_VARIANTS.md) for the full flag list.

## See also

- [Storage Backend](STORAGE_BACKEND.md) — full schema, migration, factory details
- [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md)
- [Architecture Overview](ARCHITECTURE.md)
