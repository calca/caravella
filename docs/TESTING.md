# Testing Guide

## Overview

Caravella uses Flutter's built-in test framework. Tests are located in two directories:

- `test/` — App-level tests (widgets, integration, plus the one sync test that exercises app-level code: `test/sync/bluetooth_sync_factory_test.dart`)
- `packages/caravella_core/test/` — Core package unit tests (services, repositories, and the P2P sync subsystem — see below)

`test/` and `packages/caravella_core/test/` are two separate Dart packages' test suites — running `flutter test` from the root only picks up `test/`, never `packages/*/test/**`. Both `flutter test` (root) and `flutter test` inside each `packages/*` directory must pass; CI runs both (see "Continuous Integration" below).

## Prerequisites

- Flutter SDK (see `.fvmrc` for the pinned version)
- For SQLite-based tests on desktop: `sqflite_common_ffi` (already in dev dependencies)

## Running All Tests

```bash
# Run all tests in the main app
flutter test

# Run all tests in the core package
cd packages/caravella_core
flutter test
```

## Running Specific Test Files

```bash
# Single file (note the package-relative path)
cd packages/caravella_core && flutter test test/sync/conflict_resolver_test.dart

# All tests in a directory
cd packages/caravella_core && flutter test test/sync/
```

## Accessibility Guideline Tests

`test/a11y/accessibility_guidelines_test.dart` pumps the main screens (group page and its three sections, Home, Groups, group search, new and edit expense, group creation, settings, appearance, group settings and its editors) with a seeded group, in the light theme, the dark theme and at 200% text, and runs Flutter's guidelines on each: `androidTapTargetGuideline` (48×48 dp), `labeledTapTargetGuideline` (every tappable node has a label) and `textContrastGuideline` (text contrast as drawn). When adding a screen, add it to `_screens`; a failure there is a real accessibility regression, not a flaky test. Theme-level contrast is pinned separately by `packages/caravella_core_ui/test/themes/contrast_test.dart`.

## Sync Subsystem Tests

The P2P sync tests live in `packages/caravella_core/test/sync/` — they test classes under `packages/caravella_core/lib/sync/` and only depend on `caravella_core` itself, so they were moved out of the root `test/` in the technical-debt pass that added the CI step above (see `plan.todo.md`), to actually run as part of that package's own `flutter test`:

| File | Description |
|------|-------------|
| `conflict_resolver_test.dart` | LWW conflict resolution — 8 cases: remote-newer wins, local-newer wins, tie-break, soft delete, non-existent delete, empty delta, mixed batch |
| `conflict_resolver_authorship_test.dart` | `createdBy`/`updatedBy` authorship metadata survives `applyDelta` |
| `sync_integration_test.dart` | Bidirectional exchange between two in-memory repos; verifies convergence to correct LWW winner |
| `group_deletion_sync_test.dart` | Two phones exchanging through `SyncOrchestrator.handleIncomingDelta`, started from either side: a deleted group stays deleted on both, a change reaches the other phone |
| `sync_clock_test.dart` | UTC timestamp source correctness |
| `sync_crypto_test.dart` | `SyncEnvelope` encrypt/decrypt round-trip and X25519 ECDH + HKDF key agreement |
| `sync_dao_test.dart` | Per-group pairing grants (paired devices, `isPaired`, revocation) |
| `sync_result_test.dart` | SyncResult / SyncStatus domain models |
| `lan_two_peer_test.dart` | Wi-Fi end to end: phone A is the real `LanSyncChannel` (`mdns: false`, port 0) behind `SyncOrchestrator` and SQLite, phone B speaks the HTTP protocol from the test with its own X25519 keys and database. Pairing grants and brings the group, changes go both ways in one exchange, newer change wins on both, unpaired phone and wrong key refused (403), revoked grant blocks both ways, deletion reaches B, and A pairing/syncing with B's code (`pairWithHost`) |
| `cloud_sync_test.dart` | Google Drive cycle with a fake `appDataFolder` and two phones: every group taken without a grant, own snapshot uploaded with what was merged, own shard ignored, deletion propagated and not undone by a stale shard, newer-schema shard skipped, signed out → `cloudUnreachable`, on/off, and `deleteGroup`'s tombstone |

`packages/caravella_gms/test/nearby_bluetooth_sync_channel_test.dart` runs the real `NearbyBluetoothSyncChannel` over a fake `Nearby` (constructor `nearby:`/`requestPermissions:`) against a scripted phone: handshake and encrypted exchange from either side, deltas over 32 KB chunked with every payload within Nearby's limit, chunked hello reassembly, incomplete chunks dropped after 30 s, implausible chunk totals ignored, handshake and response timeouts reported as failures, a sync without a hello ignored, and `startUpdate` answering only the paired device with its stored key.

The one sync test that stays in the root `test/sync/` is `bluetooth_sync_factory_test.dart` — it tests `lib/sync/bluetooth_sync_factory.dart`, an app-level class, not `caravella_core`.

### Run only sync tests

```bash
cd packages/caravella_core && flutter test test/sync/
```

## Core Package Tests

Located in `packages/caravella_core/test/` (includes `sync/`, see above):

```bash
cd packages/caravella_core
flutter test
```

These cover services like notifications, repositories, widget helpers, and the sync subsystem.

## Test Patterns

- **In-memory SQLite:** Tests use `sqflite_common_ffi` with `databaseFactoryFfi` and `inMemoryDatabasePath` for isolated, fast DB tests.
- **App storage in tests:** anything going through `ExpenseGroupStorageV2` calls `useTestDatabase()` (`test/helpers/test_database.dart`), which points `ExpenseGroupRepositoryFactory` at a new SQLite database in a temporary file. Call it in `setUp` for a clean database per test, and give each group its own participant/category/expense ids (they are primary keys across the database).
- **Mocks:** Mockito-based mocks for repositories and DAOs.
- **Golden tests:** Not currently used; widget tests use `pumpWidget` with `MaterialApp` wrappers.

## Continuous Integration

Tests run automatically on pull requests via GitHub Actions. The workflow:

1. Checks out the code
2. Sets up Flutter
3. Runs `flutter test` in the root app
4. Runs `flutter pub get` + `flutter test` inside each of the `packages/*` (own step, since the root `flutter test` never reaches them — see "Overview" above)
5. Reports failures as PR check annotations

## Tips

- Use `--name` to filter by test name:
  ```bash
  flutter test --name "remote-newer wins"
  ```
- Use `--reporter expanded` for verbose output:
  ```bash
  cd packages/caravella_core && flutter test --reporter expanded test/sync/
  ```
- To update golden files (if added in future):
  ```bash
  flutter test --update-goldens
  ```
