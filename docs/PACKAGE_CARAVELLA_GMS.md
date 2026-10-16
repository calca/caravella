# caravella_gms (Play vs. FOSS build)

Every feature that needs a **proprietary Google library** — Google Play Services, ML Kit, Play Core — sits behind one interface so the F-Droid build can leave those libraries out of the APK entirely, not just make them unreachable.

## The three pieces

| Piece | Where | What |
|---|---|---|
| Interface | `packages/caravella_core/lib/integrations/gms_integrations.dart` | `GmsIntegrations` (+ `ReceiptTextRecognizer`, `StoreReviewClient`, `CloudAccountChannel`, `AppUpdateIntegration`), `NoGmsIntegrations` (nothing available), and the static `GmsIntegrations.instance` the app reads. Also uses `PositionProvider` (`services/media/location_service_abstraction.dart`), `BluetoothSyncChannel` (`sync/channels/bluetooth_sync_channel.dart`) and `UpdateLocalizations` (`integrations/update_localizations.dart`), all in `caravella_core`. |
| Play implementation | `packages/caravella_gms/` (package `caravella_gms`) | `PlayGmsIntegrations`, exported as the top-level `gmsIntegrations` constant, wiring the real libraries — see the table below. Depends on `caravella_core`, `google_drive_sync`, `play_store_updates`. |
| FOSS stand-in | `packages/caravella_gms_foss/` (package **also** named `caravella_gms`) | Exports the same `gmsIntegrations` constant, set to `NoGmsIntegrations()`. Depends on `caravella_core` only. |

The root `pubspec.yaml` depends on `caravella_gms` (path `packages/caravella_gms`) and on none of the proprietary libraries directly. `AppInitialization.configureGmsIntegrations()` (`lib/main/app_initialization.dart`) installs `gmsIntegrations` into `GmsIntegrations.instance` as the first startup step; everything else in `lib/` and `caravella_core` only talks to `GmsIntegrations.instance`. Tests get `NoGmsIntegrations` unless they set `instance` themselves (see `test/sync/bluetooth_sync_factory_test.dart`).

## Feature by feature

| Feature | Play (`caravella_gms`) | FOSS build | App side |
|---|---|---|---|
| Current location | `GeolocatorPositionProvider` (`geolocator` → fused location provider) | Falls back to `LocationManagerPositionProvider` (`lib/manager/expense/services/location_manager_position_provider.dart`): the platform `LocationManager` through the `io.caravella.egm/location` channel (`android/.../LocationChannel.kt`), permissions via `permission_handler` | `LocationServiceImpl` composes the provider with `geocoding` reverse geocoding — see [Location & Maps](LOCATION_AND_MAPS.md) |
| Receipt OCR | `MlKitReceiptTextRecognizer` (`google_mlkit_text_recognition`) | Unavailable — scan buttons hidden | `ReceiptScannerService.isAvailable` — see [Receipt OCR](RECEIPT_OCR.md) |
| In-app review | `InAppReviewClient` (`in_app_review`) | Unavailable — never prompts | `RatingService` (`caravella_core`) |
| In-app updates | `PlayStoreAppUpdates` wrapping [play_store_updates](PACKAGE_PLAY_STORE_UPDATES.md) (still gated on `ENABLE_PLAY_UPDATES`) | Unavailable — no auto-check, no "Check for updates" card | `HomePage._performUpdateCheckIfNeeded`, `WhatsNewPage` |
| Google Drive cloud relay | `GoogleDriveSyncFactory.createCloudChannel()` from [google_drive_sync](PACKAGE_GOOGLE_DRIVE_SYNC.md) (still gated on `ENABLE_GOOGLE_DRIVE_SYNC`) | Unavailable — Cloud Sync hidden | `SyncBootstrap`; the Drive account UI uses `CloudAccountChannel` |
| Bluetooth sync | `NearbyBluetoothSyncChannel` (`nearby_connections`) | Unavailable — Bluetooth section hidden | `BluetoothSyncFactory.isEnabled` / `createChannel` (also honours `ENABLE_BLUETOOTH_SYNC`) — see [Sync Architecture](SYNC_ARCHITECTURE.md) |
| QR scanning (pairing) | `MobileScannerQrView` (`mobile_scanner` → ML Kit barcode) | Unavailable — "Scan a code" hidden; the device can still be paired by **showing** its own QR (`qr_flutter`, free) for a Play device to scan | `QrPairScanPage`, `MultiUserSyncPage` |

## Switching variant

The switch is `./build_variant.sh` at the repo root — see [Build Variants & Flavors](BUILD_VARIANTS.md#play-vs-foss-variant). In short: `./build_variant.sh foss` writes a git-ignored `pubspec_overrides.yaml` that points `caravella_gms` at `packages/caravella_gms_foss`, so pub resolves the stand-in and the proprietary plugins drop out of the dependency graph (and so out of Gradle and the APK). `./build_variant.sh gms` removes it. `./build_variant.sh check` fails if the Android release classpath still contains a non-free Google artifact.

A `--dart-define` can't do this: Dart defines only select code paths, while Flutter registers and Gradle compiles every plugin listed in the resolved dependency graph.

## Rules

- Never import a proprietary library (or `google_drive_sync` / `play_store_updates`) outside `packages/caravella_gms` — `validate_package_boundaries.sh` fails CI if you do, and lists the guarded package names.
- A new proprietary feature goes in `packages/caravella_gms`, gets a getter on `GmsIntegrations` returning `null`/`false` in `NoGmsIntegrations`, and the app hides (or replaces) the feature when it's missing.
- Keep the two `caravella_gms` packages' public API identical: both must export `gmsIntegrations` typed as `GmsIntegrations`. CI's "F-Droid (FOSS) variant guard" step analyzes the app against the stand-in and runs `./build_variant.sh check`.

## See also

- [Build Variants & Flavors](BUILD_VARIANTS.md)
- [F-Droid Submission](FDROID_SUBMISSION.md)
- [Architecture Overview](ARCHITECTURE.md#package-dependency-rules)
- [CI Pipelines](CI_PIPELINES.md)
