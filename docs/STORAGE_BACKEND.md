# Storage Backend Configuration

This document explains how to configure the storage backend for the Caravella app.

## Overview

Caravella supports two storage backends:
1. **File-based (JSON)** - Default, stores data in a JSON file
2. **Hive** - High-performance local database, better for larger datasets

The backend is selected at build time using the `STORAGE_BACKEND` dart-define parameter.

## Usage

### Using File-based Storage (Default)

No additional configuration needed. The app uses JSON file storage by default:

```bash
flutter run --flavor dev --dart-define=FLAVOR=dev
```

Or explicitly specify:

```bash
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=STORAGE_BACKEND=file
```

### Using Hive Storage

To use Hive for better performance:

```bash
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=STORAGE_BACKEND=hive
```

### Building APKs

#### Development APK with Hive:
```bash
flutter build apk --flavor dev --dart-define=FLAVOR=dev --dart-define=STORAGE_BACKEND=hive
```

#### Staging APK with Hive:
```bash
flutter build apk --flavor staging --release --dart-define=FLAVOR=staging --dart-define=STORAGE_BACKEND=hive
```

#### Production APK with Hive:
```bash
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod --dart-define=STORAGE_BACKEND=hive
```

## VS Code Configuration

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Dev (File Storage)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--flavor",
        "dev",
        "--dart-define=FLAVOR=dev",
        "--dart-define=STORAGE_BACKEND=file"
      ]
    },
    {
      "name": "Dev (Hive Storage)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--flavor",
        "dev",
        "--dart-define=FLAVOR=dev",
        "--dart-define=STORAGE_BACKEND=hive"
      ]
    },
    {
      "name": "Staging (Hive Storage)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--flavor",
        "staging",
        "--dart-define=FLAVOR=staging",
        "--dart-define=STORAGE_BACKEND=hive"
      ]
    }
  ]
}
```

## Performance Comparison

### File-based (JSON) Storage
- **Pros:**
  - Simple and proven
  - Human-readable data format
  - Easy to debug
  - No additional initialization required

- **Cons:**
  - Slower for large datasets
  - Entire file must be read/written for any operation
  - JSON parsing overhead

### Hive Storage
- **Pros:**
  - Much faster read/write operations
  - Binary format is more compact
  - Lazy loading of data
  - Better memory efficiency
  - Indexed lookups

- **Cons:**
  - Binary format is not human-readable
  - Requires initialization at app startup
  - Slightly more complex debugging

## Migration

~~Data is **not** automatically migrated between storage backends. If you switch backends:~~
**UPDATE**: As of the latest version, migration from JSON to Hive is automatic! See `docs/MIGRATION_JSON_TO_HIVE.md` for details.

## Backup and Import

The backup and import functionality in Settings → Data Backup works seamlessly with **both** storage backends:

### How Backup Works
- **Exports data from the active repository** (regardless of backend)
- Creates a JSON file containing all expense groups
- Packages it into a ZIP file
- Works identically whether using JSON or Hive backend

### How Import Works
- **Imports data into the active repository** (regardless of backend)
- Reads ZIP or JSON files
- Parses expense groups from the backup
- Adds them to the current storage backend
- Works identically whether using JSON or Hive backend

### Compatibility
✅ Backups created with **JSON backend** can be imported into **Hive backend**  
✅ Backups created with **Hive backend** can be imported into **JSON backend**  
✅ The backup format is **backend-agnostic** (always JSON in a ZIP)

This means you can:
1. Create a backup on JSON backend
2. Switch to Hive backend
3. Import the backup - all data restored!

## Technical Details

- File-based storage location: `${ApplicationDocumentsDirectory}/expense_group_storage.json`
- Hive storage location: `${HiveDefaultDirectory}/expense_groups.hive`
- Both backends implement the same `IExpenseGroupRepository` interface
- Selection happens in `ExpenseGroupStorageV2._createRepository()`
- Hive initialization occurs in `AppInitialization.initializeStorage()`

## Troubleshooting

### Hive initialization errors
If you see errors related to Hive adapters not being registered:
1. Ensure `STORAGE_BACKEND=hive` is passed as a dart-define
2. Check that `HiveInitializationService.initialize()` is called during app startup
3. Verify all type adapters are registered

### Data not appearing after switching backends
This is expected behavior. Each backend maintains separate storage. Export and re-import your data when switching.

## Testing

Both backends have comprehensive test coverage:
- File-based: `test/file_based_repository_test.dart`
- Hive: `test/hive_repository_test.dart`

Run tests with:
```bash
flutter test
```
