# Architecture Overview

Caravella is a multi-platform Flutter app (Material 3) for group expense tracking, split into five local packages plus the main app. There is no backend server or company-run account system, and all data is stored **locally on-device by default** — the optional sync feature lets a user exchange data directly between *their own* devices over LAN/Bluetooth, or (opt-in, separately gated) relay it through *their own* Google Drive; see [Storage Backend](STORAGE_BACKEND.md) and the [google_drive_sync package](PACKAGE_GOOGLE_DRIVE_SYNC.md).

```
lib/                        → app-specific UI, pages, controllers ("the app")
packages/caravella_core/    → business logic, data models, storage, cross-cutting services
packages/caravella_core_ui/ → shared design-system widgets and themes
packages/android_app_functions/ → exposes app capabilities to Android AI agents/shortcuts
packages/play_store_updates/    → Google Play in-app update integration (conditional)
packages/google_drive_sync/     → Google Drive cloud relay for sync (conditional)
```

## Package dependency rules

These are enforced by convention, not by tooling — respect them when adding code:

- `lib/` may depend on all packages.
- `caravella_core_ui` depends on `caravella_core` only.
- `caravella_core` is independent — it must not depend on any other local package.
- `android_app_functions` depends on `caravella_core` only.
- `play_store_updates` depends on `caravella_core` and `caravella_core_ui`.
- `google_drive_sync` depends on `caravella_core` only.
- `play_store_updates` and `google_drive_sync` are normal pubspec dependencies of the root app at all times; the "conditional" part is purely a runtime/compile-time switch (see [Build Variants & Flavors](BUILD_VARIANTS.md)), not conditional dependency resolution.

See [caravella_core reference](PACKAGE_CARAVELLA_CORE.md), [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md), [android_app_functions](PACKAGE_ANDROID_APP_FUNCTIONS.md), [play_store_updates](PACKAGE_PLAY_STORE_UPDATES.md), [google_drive_sync](PACKAGE_GOOGLE_DRIVE_SYNC.md) for what's inside each.

## App startup sequence

Entry point `lib/main.dart`:

1. `LoggerService.initialize(...)` (Talker-backed logger; verbosity tuned per `AppConfig.environment` — prod is quieter than dev).
2. Everything runs inside `runZonedGuarded` — the error handler explicitly swallows known-noisy network/map-tile errors and logs the rest via `LoggerService.warning`.
3. `AppInitialization.initialize()` (`lib/main/app_initialization.dart`), in order:
   - `WidgetsFlutterBinding.ensureInitialized()`
   - `configureErrorHandling()` — `FlutterError.onError` / `PlatformDispatcher.instance.onError`
   - `configureImagePicker()` — forces the Android photo picker
   - `configureEnvironment()` — reads `--dart-define=FLAVOR` and sets `AppConfig.environment`
   - `lockOrientation()` — portrait only
   - `configureSystemUI()` / `configureImageCache()`
   - `initFlagSecure()` — applies the FLAG_SECURE preference via `flag_secure`
   - `initStorage()` — picks the JSON or SQLite repository backend and runs the one-time migration if needed (see [Storage Backend](STORAGE_BACKEND.md))
4. `ShortcutsInitialization.initialize()` (`lib/home/services/shortcuts_initialization.dart`) — wires Android App Shortcuts and home-screen-widget tap handling.
5. `AppFunctionsInitialization.initialize()` (`lib/home/services/app_functions_initialization.dart`) — registers the Android App Functions "add expense" callback (see [android_app_functions](PACKAGE_ANDROID_APP_FUNCTIONS.md)).
6. `runApp(const CaravellaApp())`.

`CaravellaApp` (`lib/main/caravella_app.dart`) loads locale/theme/dynamic-color prefs, then nests:
`ProviderSetup.createProviders` → `DynamicColorBuilder` → `ProviderSetup.wrapWithNotifiers` → `ToastProvider.create` → `MaterialApp`.

`ProviderSetup` (`lib/main/provider_setup.dart`) wires the app-wide providers:
- `createProviders`: `ExpenseGroupNotifier`, `UserNameNotifier`, `GroupTypeTemplatesNotifier` — all `ChangeNotifierProvider`s. `ExpenseGroupNotifier` gets two injected platform callbacks here: a shortcuts-update callback (→ `PlatformShortcutsManager.updateShortcuts()` + `PlatformHomeWidgetManager.updateHomeWidgets()`) and a notification-cancel callback (→ `NotificationManager().cancelNotificationForGroup`).
- `wrapWithNotifiers`: nests `LocaleNotifier` → `ThemeModeNotifier` → `DynamicColorNotifier` (all `InheritedWidget`s from `caravella_core`/`caravella_core_ui`).

`lib/main/route_observer.dart` exports a single global `routeObserver`, subscribed to by `CaravellaHomePage`/`HomePage` so returning from a pushed page (e.g. group detail) triggers a lightweight refresh instead of a full reload.

## State management

The app uses `provider` for reactive state. The central piece is `ExpenseGroupNotifier` (`caravella_core`, `ChangeNotifier`): it holds the current group and exposes change-tracking fields (`updatedGroupIds`, `deletedGroupIds`, `lastEvent`/`consumeLastEvent()`) that home/history screens listen to for incremental UI updates instead of full reloads. See [caravella_core reference § State notifiers](PACKAGE_CARAVELLA_CORE.md#state-notifiers).

## Feature map (where to look)

| Area | Entry point | Doc |
|---|---|---|
| Home screen, cards, search | `lib/home/**` | [App: Home](APP_HOME.md) |
| Group creation wizard & editing | `lib/manager/group/**` | [App: Group Management](APP_GROUP_MANAGEMENT.md) |
| Expense form, attachments, voice, receipt scan | `lib/manager/expense/**` | [App: Expense Entry](APP_EXPENSE_ENTRY.md) |
| Group detail, stats tabs, settlements, export | `lib/manager/details/**` | [App: Group Details & Stats](APP_GROUP_DETAILS_STATS.md) |
| Active/archived group list | `lib/manager/history/**` | [App: History & Search](APP_HISTORY_SEARCH.md) |
| Settings, backup/restore, templates | `lib/settings/**` | [App: Settings](APP_SETTINGS.md) |
| Storage backend & migration | `packages/caravella_core/lib/data/**` | [Storage Backend](STORAGE_BACKEND.md) |
| Receipt OCR | `lib/data/services/receipt_scanner_service.dart` | [Receipt OCR](RECEIPT_OCR.md) |
| Persistent notifications | `lib/services/notification_*.dart` | [Notifications](NOTIFICATIONS.md) |
| Maps & location search | `lib/manager/expense/location/**`, `caravella_core_ui/lib/map/**` | [Location & Maps](LOCATION_AND_MAPS.md) |
| Flavors, dart-defines, F-Droid vs Play Store | `android/app/build.gradle.kts`, `packages/play_store_updates` | [Build Variants](BUILD_VARIANTS.md), [F-Droid Submission](FDROID_SUBMISSION.md) |
| Peer-to-peer + Google Drive sync | `packages/caravella_core/lib/sync/**`, `lib/sync/**`, `packages/google_drive_sync` | [google_drive_sync package](PACKAGE_GOOGLE_DRIVE_SYNC.md), [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md) |
| CI pipelines | `.github/workflows/*.yml` | [CI Pipelines](CI_PIPELINES.md) |

## See also

- [Documentation Home](README.md)
- [Keeping This Documentation Current](MAINTAINING_DOCS.md)
