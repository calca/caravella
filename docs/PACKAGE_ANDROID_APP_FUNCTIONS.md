# Package: `android_app_functions`

Exposes app capabilities to Android AI agents (e.g. Gemini) as [App Functions](https://developer.android.com/reference/androidx/appfunctions), on Android 16 (API 36) and later. The functions themselves are native Kotlin in `android/app`; this Dart package is only the bridge that opens the group when an agent's link is opened. Depends only on `flutter` + local `caravella_core`.

Barrel: `android_app_functions.dart` exports `src/app_functions_service.dart`, `src/platform_app_functions_manager.dart`, and model files.

## Exposed functions

Declared in `android/app/src/main/kotlin/io/caravella/egm/appfunctions/CaravellaAppFunctionService.kt`, on `BaseCaravellaAppFunctionService` (an `androidx.appfunctions.AppFunctionService`), each with `@AppFunctionDeclaration(isDescribedByKDoc = true)`: the KDoc is what the agent reads, so keep it accurate. Results are `@AppFunctionSerializable` classes in the same file.

| Function | Kind | Returns |
|---|---|---|
| `listGroups()` | read | `List<ExpenseGroupInfo>` (`groupId`, `title`, `currency`) — the active groups, so the agent has the ids the others need |
| `addExpense(groupId, amount?, categoryName?, note?)` | write | `AddedExpense` (`expenseId`, `groupId`, `amount`, `intentToOpen`). With an amount (> 0) the expense is saved at once (category matched by name, else the first; paid by the first participant). Without one nothing is saved and `intentToOpen` is a `PendingIntent` that opens the group in Caravella, where the user adds it, for the agent to open (a service can't start an activity from the background) |
| `getGroupBalance(groupId)` | read | `GroupBalance` (`totalBalance`, the group's total spending) |
| `getRecentExpenses(groupId)` | read | `RecentExpenses` (the last 3 `ExpenseInfo`, newest first) |
| `getTodayTotal(groupId)` | read | `TodayTotal` |

Errors are `AppFunctionException`s: `AppFunctionInvalidArgumentException` (amount ≤ 0), `AppFunctionElementNotFoundException` (unknown group), `AppFunctionDisabledException` (see below). They are returned from the I/O dispatcher as a value and thrown on the service's coroutine (`io { }`), because an `AppFunctionException` thrown across `withContext` is copied by kotlinx.coroutines through reflection, which fails fatally where the system's App Functions extension classes are missing.

All data access is native, without starting Flutter: `AppFunctionStorageReader.kt` reads (and, for `addExpense`, writes) the app's SQLite database (`expense_groups.db`) through two views it creates on demand (`group_summary_view`, `expense_details_view`; re-created whenever missing, since the database file can be replaced while the process lives, e.g. by a backup restore). The same reader serves the home widget.

## Privacy toggle

Settings › Privacy has the App Functions toggle (`PreferencesService.instance.appFunctions`, off by default). It works at two levels:

- **In the system.** The functions are declared disabled (`@AppFunctionDeclaration(isEnabled = false)`, `enabledByDefault` false in the generated XML), so after an install agents don't offer them. `AppFunctionsState` (`appfunctions/AppFunctionsState.kt`) sets each one to `APP_FUNCTION_STATE_ENABLED` or `APP_FUNCTION_STATE_DISABLED` with `AppFunctionManager.setAppFunctionEnabled`, following the toggle. `MainActivity.onCreate` calls `AppFunctionsState.watch`: it syncs once (the preference can change without the app running, e.g. a backup restore) and then listens to the preference, which Flutter writes when the user flips the toggle. No Dart code is involved. Android 16+ only.
- **On every call.** The Kotlin side reads the toggle from Flutter's `SharedPreferences` (`flutter.app_functions_enabled`); when off, every function returns `AppFunctionDisabledException` and touches no data, in case the system state ever drifts.

Check the system state on a device with `adb shell dumpsys app_function` (`"enabled": [1]` enabled, `[2]` disabled).

## How it is wired

- `androidx.appfunctions:appfunctions` and its KSP compiler `appfunctions-compiler` (same version, `android/app/build.gradle.kts`; KSP plugin in `android/settings.gradle.kts`). From `@AppFunctionServiceEntryPoint(serviceName = "CaravellaAppFunctionService", appFunctionXmlFileName = "caravella_app_functions")` the compiler generates the concrete `CaravellaAppFunctionService` and `assets/caravella_app_functions.xml` (ids `io.caravella.egm.appfunctions.BaseCaravellaAppFunctionService#<name>`).
- The compiler also writes `assets/caravella_app_functions-v1.xml` (KSP arg `appfunctions:generateV1Xml`, in `android/app/build.gradle.kts`): the older index format, which is the only one the system indexer on Android 16 reads (AppSearch module 36). Without it the system has no record of the functions: they can't be found, called or enabled (`dumpsys app_function` lists nothing for Caravella, and `setAppFunctionEnabled` fails with "Function … does not exist").
- `AndroidManifest.xml` declares the generated service: exported, `android:permission="android.permission.BIND_APP_FUNCTION_SERVICE"` (only the system binds it), action `android.app.appfunctions.AppFunctionService`, properties `android.app.appfunctions.schema` → `app_functions_schema.xsd`, `android.app.appfunctions.v2` → `caravella_app_functions.xml` and `android.app.appfunctions` → `caravella_app_functions-v1.xml`.
- The link: the `PendingIntent` targets `MainActivity` with action `io.caravella.egm.ADD_EXPENSE` and the group (plus category and note when given). `MainActivity` forwards it on `MethodChannel('io.caravella.egm/app_functions')` as `onAddExpense` (with a category or note; with neither, it takes the shortcuts' `onShortcutTapped` path, which also opens the group), which `PlatformAppFunctionsManager.initialize({required onAddExpense})` (a no-op off Android) hands to `AppFunctionsInitialization._handleAddExpense` (`lib/home/services/app_functions_initialization.dart`, called at startup): it checks the privacy toggle, saves the expense if an amount came with it (`AppFunctionsInitialization.expenseFor`; the link carries none), and opens `ExpenseGroupDetailPage` via the global `navigatorKey`.
- Release builds keep what the library loads by name (the `@AppFunctionSerializable` classes and their generated `$…Factory`) through the library's own R8 rules; the inventory is created directly by the generated service.

## Tests

`android/app/src/test/kotlin/io/caravella/egm/appfunctions/CaravellaAppFunctionsTest.kt` runs on Robolectric (SDK 36) with `appfunctions-testing`'s `AppFunctionTestRule`: functions are found by search and executed through the generated service as declared in the manifest, over a small SQLite database shaped like the app's (search, each function, the invalid amount, the unknown group, the toggle off, the functions declared disabled and enabled in the system only with the toggle on). Run with `cd android && ./gradlew :app:testDevDebugUnitTest`. A real call from an agent needs an Android 16 device with one; the emulator images have no `cmd app_function`.

## See also

- [App: Home](APP_HOME.md) — where `AppFunctionsInitialization` and `ShortcutsInitialization` are invoked
- [App: Settings](APP_SETTINGS.md) — the privacy toggle that gates App Functions
- [Architecture Overview](ARCHITECTURE.md)
