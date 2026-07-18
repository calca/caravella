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

## Sync Subsystem Tests

The P2P sync tests live in `packages/caravella_core/test/sync/` — they test classes under `packages/caravella_core/lib/sync/` and only depend on `caravella_core` itself, so they were moved out of the root `test/` in the technical-debt pass that added the CI step above (see `plan.todo.md`), to actually run as part of that package's own `flutter test`:

| File | Description |
|------|-------------|
| `conflict_resolver_test.dart` | LWW conflict resolution — 8 cases: remote-newer wins, local-newer wins, tie-break, soft delete, non-existent delete, empty delta, mixed batch |
| `conflict_resolver_authorship_test.dart` | `createdBy`/`updatedBy` authorship metadata survives `applyDelta` |
| `sync_integration_test.dart` | Bidirectional exchange between two in-memory repos; verifies convergence to correct LWW winner |
| `sync_clock_test.dart` | UTC timestamp source correctness |
| `sync_crypto_test.dart` | `SyncEnvelope` encrypt/decrypt round-trip and X25519 ECDH + HKDF key agreement |
| `sync_dao_test.dart` | Per-group pairing grants (paired devices, `isPaired`, revocation) |
| `sync_result_test.dart` | SyncResult / SyncStatus domain models |
| `group_serializer_test.dart` | JSON serialization with `_sync` metadata block |

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
- **Mocks:** Mockito-based mocks for repositories and DAOs.
- **Golden tests:** Not currently used; widget tests use `pumpWidget` with `MaterialApp` wrappers.

## Continuous Integration

Tests run automatically on pull requests via GitHub Actions. The workflow:

1. Checks out the code
2. Sets up Flutter
3. Runs `flutter test` in the root app
4. Runs `flutter pub get` + `flutter test` inside each of the 5 `packages/*` (own step, since the root `flutter test` never reaches them — see "Overview" above)
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
