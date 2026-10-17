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

### Completing a flexible update

Play Core needs a separate `completeFlexibleUpdate()` call once a flexible download finishes, to actually install and restart the app. Note that `in_app_update`'s `startFlexibleUpdate()` future completes **when the download has finished** (or with an error if the user declines it / it fails), not when it starts — so `AppUpdateService.startFlexibleUpdate()` returns `true` = downloaded and ready to install, and takes an `onDownloadStarted` callback (fired on the first `downloading` status) for "downloading in background" feedback. Three mechanisms track completion:

- The `startFlexibleUpdate()` result itself: the home auto-check awaits it and, on `true`, immediately shows the ready-to-install sheet; `AppUpdateNotifier` sets `updateDownloaded`. (Until 2.0.1 the home flow showed its "downloading" toast at that point and never offered to install — the prompt only appeared after restarting the app.)
- `AppUpdateService.installUpdateStream` wraps `InAppUpdate.installUpdateListener` (a `Stream<InstallStatus>`, empty on non-Android) as **one shared broadcast stream**: every `installUpdateListener` call reopens the same native event channel, and cancelling one subscription would stop events for all. `AppUpdateNotifier` subscribes to it in its constructor and flips `updateDownloaded` to `true` on `InstallStatus.downloaded`, back to `false` on `installed` — this is what drives the live UI while the app is in the foreground.
- `AppUpdateService.isUpdateReadyToInstall()` calls `InAppUpdate.checkForUpdate()` and checks `installStatus == InstallStatus.downloaded` — for a download that finished while the app was closed, since the stream only reports transitions that happen while something is listening. `AppUpdateNotifier` runs this once on construction; `checkAndShowUpdateIfNeeded()` (see below) runs it before its normal interval-gated check, on every call.

Both `UpdateCheckWidget` and the home-page auto-check surface `updateDownloaded` with an "Install" action wired to `completeFlexibleUpdate()` — see below.

`src/app_update_notifier.dart` (`AppUpdateNotifier extends ChangeNotifier`) wraps state: `isChecking`, `updateAvailable`, `availableVersion`, `updatePriority`, `immediateAllowed`/`flexibleAllowed`, `isDownloading`, `isInstalling`, `updateDownloaded`, `error`.

`src/update_check_helper.dart`'s `checkAndShowUpdateIfNeeded()` is called once per session shortly after `HomePage` first renders. It first checks `isUpdateReadyToInstall()` (regardless of the 7-day interval) and, if true, shows a bottom sheet offering to call `completeFlexibleUpdate()` — this is the path that catches a flexible download that finished in the background. Otherwise it checks the interval, checks for a *new* update, records the check, and shows a bottom sheet via a caller-supplied builder. If the user accepts, it starts the flexible update, shows an `AppToast` (from `caravella_core_ui`) when the download starts, and when it finishes shows the same ready-to-install sheet.

`src/update_check_widget.dart` (`UpdateCheckWidget`) is the settings/what's-new screen UI — renders `SizedBox.shrink()` on non-Android platforms. When its notifier's `updateDownloaded` is `true`, the "update available" card switches its title/description/button to the ready-to-install variant (`Icons.restart_alt`, calls `completeFlexibleUpdate()`) instead of starting a new download. Both entry points require the host app to implement `UpdateLocalizations` (`src/update_localizations.dart`, 14 getters); the app's adapter is `lib/settings/update/app_update_localizations.dart` (`AppUpdateLocalizations`), mapping the generated `gen.AppLocalizations` strings onto the interface.

## Where it's wired into the app

The app never imports this package: `caravella_gms`'s `PlayStoreAppUpdates` (`packages/caravella_gms/lib/src/play_store_app_updates.dart`) wraps it as `GmsIntegrations.appUpdates`, and the F-Droid build doesn't contain it at all — see [caravella_gms](PACKAGE_CARAVELLA_GMS.md). The `UpdateLocalizations` interface lives in `caravella_core` (`integrations/update_localizations.dart`); `src/update_localizations.dart` here only re-exports it.

- `HomePage._performUpdateCheckIfNeeded()` (`lib/home/home_page.dart`) — automatic check, once per session, via `appUpdates.checkAndShowUpdateIfNeeded`.
- `WhatsNewPage` (`lib/settings/pages/whats_new_page.dart`) — `appUpdates.buildUpdateCheckWidget` (an `UpdateCheckWidget`) for a manual "check for updates" card, Android only.

## See also

- [Build Variants & Flavors](BUILD_VARIANTS.md) — the `ENABLE_PLAY_UPDATES` dart-define and how CI sets it
- [App: Home](APP_HOME.md)
- [App: Settings](APP_SETTINGS.md)
