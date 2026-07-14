# Package: `android_app_functions`

Exposes app capabilities to Android AI agents and shortcuts (e.g. Google Gemini/Assistant "App Functions") via a native Kotlin service plus a Dart `MethodChannel` bridge. Depends only on `flutter` + local `caravella_core`.

Barrel: `android_app_functions.dart` exports `src/app_functions_service.dart`, `src/platform_app_functions_manager.dart`, and model files.

## Exposed functions

| Function | Kind | Result model | Handled by |
|---|---|---|---|
| `onAddExpense` | write | — (navigates to group after creating) | Kotlin forwards to Dart via `MethodChannel('io.caravella.egm/app_functions')` |
| `getGroupBalance` | read | `ExpenseBalanceResult` (`groupId`, `groupTitle`, `totalBalance`, `currency`) | Kotlin directly |
| `getRecentExpenses` | read | `RecentExpensesResult` (list of `ExpenseSummary`, capped at `kRecentExpensesCount = 3`) | Kotlin directly |
| `getTodayTotal` | read | `TodayTotalResult` (`groupId`, `groupTitle`, `todayTotal`, `currency`) | Kotlin directly |

The three read-only functions are handled **entirely in native Kotlin** (`android/app/src/main/kotlin/io/caravella/egm/appfunctions/CaravellaAppFunctionService.kt` + `AppFunctionStorageReader.kt`) — they read the storage JSON directly without starting the Flutter engine, for fast/lightweight responses. Only `addExpense` round-trips through Dart, because it needs the running app (to let the user confirm/navigate into the UI).

## Registration flow

`PlatformAppFunctionsManager.initialize({required onAddExpense})` is a platform guard — no-ops unless `Platform.isAndroid`, otherwise delegates to `AppFunctionsService.initialize`.

Called from `lib/home/services/app_functions_initialization.dart` (`AppFunctionsInitialization.initialize()`), synchronously, during app startup (see [Architecture Overview § startup sequence](ARCHITECTURE.md#app-startup-sequence)). Its `_handleAddExpense` callback:

1. Checks the privacy toggle `PreferencesService.instance.appFunctions.isEnabled()` — if disabled, the request is silently ignored (logged only). This toggle is surfaced in Settings → Privacy (see [App: Settings](APP_SETTINGS.md)).
2. If `params.amount > 0`, resolves a category (case-insensitive match, falling back to first/"Other"), builds an `ExpenseDetails`, and calls `ExpenseGroupStorageV2.addExpenseToGroup`.
3. If amount is `0.0` (not provided by the agent), skips creating an expense and only navigates.
4. Always navigates to `ExpenseGroupDetailPage` via the global `navigatorKey`.

## Native dependency note

`android/app/build.gradle.kts` pins `androidx.appfunctions:appfunctions:1.0.0-alpha01` deliberately — `CaravellaAppFunctionService` uses a `Builder(qualifiedName, id)` constructor that was made internal starting in `alpha09`. Don't bump this dependency without re-verifying that API is still public in the target version.

## See also

- [App: Home](APP_HOME.md) — where `AppFunctionsInitialization` and `ShortcutsInitialization` are invoked
- [App: Settings](APP_SETTINGS.md) — the privacy toggle that gates App Functions
- [Architecture Overview](ARCHITECTURE.md)
