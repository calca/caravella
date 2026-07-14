# Package: `play_store_updates`

Google Play in-app update integration, isolated into its own package so F-Droid/non-Play builds never pull in Play Services dependencies. Depends on `caravella_core` and `caravella_core_ui`. See [Build Variants & Flavors](BUILD_VARIANTS.md) for how this fits into the overall F-Droid-vs-Play story.

Barrels: `play_store_updates.dart` (full surface) and `updates.dart` (a smaller surface: just the interface, no-op impl, and factory).

## Factory pattern

`src/update_service_factory.dart` gates everything on:

```dart
const isPlayUpdatesEnabled = bool.fromEnvironment('ENABLE_PLAY_UPDATES', defaultValue: false);
```

- **`true`** → `UpdateServiceFactory.createUpdateService()`/`createUpdateNotifier()` return `PlayStoreUpdateService`/`PlayStoreUpdateNotifier` (`src/update_service_playstore.dart`), and `initializePlayStoreUpdatesLogger()` hooks a `LoggerAdapter` into `caravella_core`'s `LoggerService`.
- **`false`/unset** → returns `NoOpUpdateService`/`NoOpUpdateNotifier` (`src/update_service_noop.dart`) — every method is a stub, no Google Play code touched at all.
- On **web** builds specifically, a conditional import (`import 'update_service_playstore.dart' if (dart.library.html) 'update_service_noop.dart';`) substitutes the no-op implementation at compile time regardless of the flag, as an extra safety net.

## Update-check implementation

`src/app_update_service.dart` uses the `in_app_update` package (`InAppUpdate.checkForUpdate()/startFlexibleUpdate()/completeFlexibleUpdate()/performImmediateUpdate()`), guarded by `Platform.isAndroid`. It specifically catches `PlatformException` code `TASK_FAILURE`, which is expected when the app wasn't installed from Google Play (debug builds, sideloaded APKs, F-Droid builds). Persists the last-check timestamp in `shared_preferences` (`last_update_check_timestamp`) with a **7-day** check interval.

`src/app_update_notifier.dart` (`AppUpdateNotifier extends ChangeNotifier`) wraps state: `isChecking`, `updateAvailable`, `availableVersion`, `updatePriority`, `immediateAllowed`/`flexibleAllowed`, `isDownloading`, `isInstalling`, `error`.

`src/update_check_helper.dart`'s `checkAndShowUpdateIfNeeded()` is called once per session shortly after `HomePage` first renders: checks the interval, checks for an update, records the check, and shows a bottom sheet via a caller-supplied builder, using `AppToast` from `caravella_core_ui`.

`src/update_check_widget.dart` (`UpdateCheckWidget`) is the settings/what's-new screen UI — renders `SizedBox.shrink()` on non-Android platforms. Both entry points require the host app to implement `UpdateLocalizations` (`src/update_localizations.dart`, 11 getters); the app's adapter is `lib/settings/update/app_update_localizations.dart` (`AppUpdateLocalizations`), mapping the generated `gen.AppLocalizations` strings onto the interface.

## Where it's wired into the app

- `HomePage._performUpdateCheckIfNeeded()` (`lib/home/home_page.dart`) — automatic check, once per session.
- `WhatsNewPage` (`lib/settings/pages/whats_new_page.dart`) — embeds `UpdateCheckWidget` for a manual "check for updates" card, Android only.

## See also

- [Build Variants & Flavors](BUILD_VARIANTS.md) — the `ENABLE_PLAY_UPDATES` dart-define and how CI sets it
- [App: Home](APP_HOME.md)
- [App: Settings](APP_SETTINGS.md)
