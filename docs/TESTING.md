# Testing Guide

## Overview

Caravella uses Flutter's built-in test framework. Tests are located in two directories:

- `test/` — App-level tests (widgets, integration, sync)
- `packages/caravella_core/test/` — Core package unit tests (services, repositories)

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
# Single file
flutter test test/sync/conflict_resolver_test.dart

# All tests in a directory
flutter test test/sync/
```

## Sync Subsystem Tests

The P2P sync tests are located in `test/sync/`:

| File | Description |
|------|-------------|
| `conflict_resolver_test.dart` | LWW conflict resolution — 8 cases: remote-newer wins, local-newer wins, tie-break, soft delete, non-existent delete, empty delta, mixed batch |
| `sync_integration_test.dart` | Bidirectional exchange between two in-memory repos; verifies convergence to correct LWW winner |
| `sync_clock_test.dart` | UTC timestamp source correctness |
| `sync_result_test.dart` | SyncResult / SyncStatus domain models |
| `group_serializer_test.dart` | JSON serialization with `_sync` metadata block |

### Run only sync tests

```bash
flutter test test/sync/
```

## Core Package Tests

Located in `packages/caravella_core/test/`:

```bash
cd packages/caravella_core
flutter test
```

These cover services like notifications, repositories, and widget helpers.

## Test Patterns

- **In-memory SQLite:** Tests use `sqflite_common_ffi` with `databaseFactoryFfi` and `inMemoryDatabasePath` for isolated, fast DB tests.
- **Mocks:** Mockito-based mocks for repositories and DAOs.
- **Golden tests:** Not currently used; widget tests use `pumpWidget` with `MaterialApp` wrappers.

## Continuous Integration

Tests run automatically on pull requests via GitHub Actions. The workflow:

1. Checks out the code
2. Sets up Flutter
3. Runs `flutter test` in root and core package
4. Reports failures as PR check annotations

## Tips

- Use `--name` to filter by test name:
  ```bash
  flutter test --name "remote-newer wins"
  ```
- Use `--reporter expanded` for verbose output:
  ```bash
  flutter test --reporter expanded test/sync/
  ```
- To update golden files (if added in future):
  ```bash
  flutter test --update-goldens
  ```
