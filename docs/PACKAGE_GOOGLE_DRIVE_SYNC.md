# Package: `google_drive_sync`

Google Drive cloud relay for the sync feature, isolated into its own package so builds without `ENABLE_GOOGLE_DRIVE_SYNC=true` (the default, including F-Droid) never exercise Google Sign-In or Drive API code at runtime. Depends on `caravella_core`. See [Google Drive Sync Setup Guide](GOOGLE_DRIVE_SYNC_SETUP.md) for the Google Cloud Console configuration this needs, and [Build Variants & Flavors](BUILD_VARIANTS.md) for the flag.

Barrel: `google_drive_sync.dart`.

## Factory pattern

`src/google_drive_sync_factory.dart` gates everything on:

```dart
const isEnabled = bool.fromEnvironment('ENABLE_GOOGLE_DRIVE_SYNC', defaultValue: false);
```

- **`true`** → `GoogleDriveSyncFactory.createCloudChannel()` returns a `GoogleDriveCloudChannel`.
- **`false`/unset** → returns `null`.

This mirrors `play_store_updates`'s `UpdateServiceFactory` (see [its package reference](PACKAGE_PLAY_STORE_UPDATES.md#factory-pattern)) with one difference: instead of a no-op fallback object, disabled builds get `null`. `SyncOrchestrator`'s `cloudChannel` constructor parameter and `isCloudEnabled` getter were already nullable/boolean before this package existed (`packages/caravella_core/lib/sync/sync_orchestrator.dart`), so `null` was the natural fit — and it lets `SyncSettingsScreen` hide the whole Cloud Sync section with a single `if (orchestrator.isCloudEnabled)` check rather than rendering a card full of disabled controls.

`google_drive_sync` is always a normal pubspec dependency of the root app (same non-conditional-dependency-resolution caveat as `play_store_updates` — see [Architecture Overview § package dependency rules](ARCHITECTURE.md#package-dependency-rules)).

## The `CloudRelayChannel` interface

Defined in `caravella_core` (`packages/caravella_core/lib/sync/channels/cloud_relay_channel.dart`), not here — `caravella_core` stays independent of any concrete cloud provider SDK per the package boundary rules. It's an abstract class with two concrete, shared members (`isEnabled()`/`setEnabled()`, backed by a `shared_preferences` flag `sync_cloud_enabled` common to every implementation) and five abstract ones (`uploadShard`, `downloadAllShards`, `start`, `stop`, `syncNow`, plus a `channelName` getter) that `GoogleDriveCloudChannel` implements. `GoogleDriveCloudChannel` uses `extends`, not `implements`, specifically to inherit those two concrete members instead of reimplementing them.

## Auth: `GoogleDriveAuthService` (`src/google_drive_auth_service.dart`)

Wraps `google_sign_in`'s `GoogleSignIn`, scoped to `drive.DriveApi.driveAppdataScope` only (see the setup guide's "which scope" note for why). `authenticatedClient()` bridges a signed-in `GoogleSignInAccount` into a plain `http.Client` by injecting `account.authHeaders` into every request via a small `http.BaseClient` subclass (`_GoogleAuthClient`) — the standard pattern for using `google_sign_in` with `googleapis`'s generated clients, since this package deliberately avoids an extra auth-bridging dependency (`extension_google_sign_in_as_googleapis_auth` or similar) in favor of one file of plain code.

`signInSilently()` failures are swallowed (logged, return `null`) — a expired/revoked session on app start shouldn't surface as an error, just fall back to "not signed in."

## Drive API: `GoogleDriveApiClient` (`src/google_drive_api_client.dart`)

Thin wrapper around `googleapis`'s `drive.DriveApi`, scoped to `spaces: 'appDataFolder'` throughout — a hidden per-app folder invisible in the user's normal Drive UI. Each device gets one file, `caravella_shard_<deviceId>.json`, holding that device's latest delta payload (`uploadShard` finds-or-creates it via `files.list` + `files.update`/`files.create`); `downloadAllShards` lists every `caravella_shard_*` file and downloads each with `files.get(..., downloadOptions: DownloadOptions.fullMedia)`. This mirrors the shard-per-device model the `CloudRelayChannel` interface's method names imply — peers converge by downloading every device's shard and merging through the same `SyncManager`/`ConflictResolver` pipeline LAN/Bluetooth deltas already go through (see [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)).

## `GoogleDriveCloudChannel` (`src/google_drive_cloud_channel.dart`)

Ties auth + API client together and implements the periodic-polling half of `CloudRelayChannel` (`start`/`stop`, manual rescheduling via `Timer` rather than `Timer.periodic` so overlapping sync cycles can't stack — same pattern the LAN channel's own polling would use). Adds Drive-specific surface beyond the base interface that the UI downcasts to when present:

- `signedInAccountEmail` — shown in `SyncSettingsScreen`'s Cloud Sync card as "Signed in as `<email>`".
- `signIn()` / `signOut()` / `restoreSession()` (silent sign-in on screen load, so a prior session survives app restarts without prompting again).

`uploadShard`/`downloadAllShards` no-op with a warning log (not an exception) when there's no authenticated session — callers (`SyncOrchestrator`) don't need Drive-specific error handling.

## Where it's wired into the app

- `lib/sync/sync_bootstrap.dart` — `SyncBootstrap.initialize()` passes `GoogleDriveSyncFactory.createCloudChannel()` as `SyncOrchestrator`'s `cloudChannel`.
- `lib/sync/sync_settings_screen.dart` — the whole Cloud Sync section (`_buildCloudSection`) is conditionally built on `orchestrator.isCloudEnabled`; `_CloudSyncCard` reads `widget.orchestrator.cloudChannel` (the same instance the orchestrator uses, not a throwaway one — important, since a fresh `GoogleDriveCloudChannel` would have no sign-in session) and downcasts to `GoogleDriveCloudChannel` for the sign-in flow.

## Known gaps

- **`uploadShard` has no runtime call site.** It's implemented here and exercised in isolation by `test/google_drive_api_client_test.dart`, but nothing in `SyncOrchestrator`, this package's own `start()`/`syncNow()`, or any UI page ever calls `GoogleDriveCloudChannel.uploadShard` — this device's own changes are never pushed to Drive today. Downloaded shards aren't merged into the local DB either (`SyncOrchestrator`'s `onShards` callback only logs a count). See [Sync Architecture § Known gaps](SYNC_ARCHITECTURE.md#known-gaps--todos) for the full picture across all three channels.
- Beyond the `google_drive_api_client_test.dart` coverage added for `downloadAllShards`'s error handling, there's no test coverage for `GoogleDriveAuthService`/sign-in — it wraps platform channels and live HTTP calls with no mocking infrastructure in this codebase yet. Verify auth changes via the manual smoke test in the [setup guide](GOOGLE_DRIVE_SYNC_SETUP.md#verifying-it-works).
- iOS is supported in code (the `GOOGLE_DRIVE_IOS_CLIENT_ID` define, `GoogleDriveAuthService`'s `iosClientId` parameter) but untested — this repo's CI only builds Android (see [CI Pipelines](CI_PIPELINES.md)).

## See also

- [Google Drive Sync Setup Guide](GOOGLE_DRIVE_SYNC_SETUP.md) — Google Cloud Console configuration
- [Build Variants & Flavors](BUILD_VARIANTS.md) — the `ENABLE_GOOGLE_DRIVE_SYNC`/`GOOGLE_DRIVE_IOS_CLIENT_ID` dart-defines
- [play_store_updates package](PACKAGE_PLAY_STORE_UPDATES.md) — the sibling package this one's factory pattern is modeled on
- [caravella_core reference](PACKAGE_CARAVELLA_CORE.md) — `CloudRelayChannel`, `SyncOrchestrator`, and the rest of the sync pipeline
