# SQLite Backend Implementation

## Overview

Caravella now supports two storage backends:
1. **SQLite Database** (default) - Improved performance and scalability
2. **JSON File Storage** (legacy) - Original file-based storage

The SQLite backend provides better performance, especially with larger datasets, and more efficient querying capabilities.

## Architecture

### Components

#### 1. SqliteExpenseGroupRepository
Located at: `packages/caravella_core/lib/data/sqlite_expense_group_repository.dart`

Implements the `IExpenseGroupRepository` interface using SQLite as the storage backend.

**Features:**
- Normalized database schema with separate tables for groups, participants, categories, and expenses
- Foreign key constraints for data integrity
- Indexed columns for faster queries
- Transaction support for atomic operations
- Automatic database versioning and migration support

**Database Schema:**
- `groups` - Main expense group data
- `participants` - Participants in groups
- `categories` - Expense categories
- `expenses` - Individual expense records

#### 2. StorageMigrationService
Located at: `packages/caravella_core/lib/data/storage_migration_service.dart`

Handles automatic migration from JSON file storage to SQLite database.

**Features:**
- Detects if migration is needed
- Reads all data from JSON backend
- Writes data to SQLite backend
- Validates migration success
- Backs up original JSON file
- Tracks migration completion using SharedPreferences

#### 3. ExpenseGroupRepositoryFactory
Located at: `packages/caravella_core/lib/data/expense_group_repository_factory.dart`

Factory class that creates the appropriate repository instance based on configuration.

**Features:**
- Singleton pattern for repository instances
- Backend selection via configuration
- Support for switching between JSON and SQLite backends

## Usage

### Default Behavior (SQLite)

By default, the app uses the SQLite backend. On first launch after update:
1. App checks if migration is needed
2. If JSON data exists, it's automatically migrated to SQLite
3. Original JSON file is backed up
4. Future operations use SQLite

### Using JSON Backend (Legacy Mode)

To use the legacy JSON backend, pass the `USE_JSON_BACKEND` flag:

```bash
# Development
flutter run --dart-define=USE_JSON_BACKEND=true

# Release build
flutter build apk --dart-define=USE_JSON_BACKEND=true --dart-define=FLAVOR=prod
```

### Build Examples

#### SQLite Backend (Default)
```bash
# Dev flavor
flutter run --flavor dev --dart-define=FLAVOR=dev

# Staging flavor
flutter build apk --flavor staging --release --dart-define=FLAVOR=staging

# Production flavor
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod
```

#### JSON Backend (Legacy)
```bash
# Dev flavor with JSON
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=USE_JSON_BACKEND=true

# Production with JSON
flutter build apk --flavor prod --release --dart-define=FLAVOR=prod --dart-define=USE_JSON_BACKEND=true
```

## Migration Process

### Automatic Migration

The migration happens automatically during app initialization:

1. **Check Migration Status**: Uses SharedPreferences to check if migration was already completed
2. **Detect JSON Data**: Checks if `expense_group_storage.json` exists and has data
3. **Load from JSON**: Reads all groups from JSON backend
4. **Save to SQLite**: Writes all groups to SQLite database
5. **Validate**: Ensures all groups were migrated correctly
6. **Backup**: Creates a timestamped backup of the JSON file
7. **Mark Complete**: Stores migration completion flag in SharedPreferences

### Migration Validation

The service performs several validation checks:
- Count validation: Ensures the same number of groups exist in both backends
- ID validation: Verifies all group IDs are present in the migrated data
- Structure validation: Checks that groups, participants, categories, and expenses are preserved

### Backup Files

After successful migration, the original JSON file is backed up to:
```
expense_group_storage.json.backup.<timestamp>
```

Example: `expense_group_storage.json.backup.1701234567890`

## Testing

### Running Tests

The implementation includes comprehensive test suites:

```bash
# Run all tests
flutter test

# Run SQLite repository tests
flutter test test/sqlite_repository_test.dart

# Run migration tests
flutter test test/storage_migration_test.dart
```

### Test Coverage

**SqliteExpenseGroupRepository Tests:**
- Basic CRUD operations (create, read, update, delete)
- Filtering operations (active, archived, pinned groups)
- Pin and archive operations
- Expense operations
- Validation
- Metadata updates
- Complex data (locations, attachments)

**StorageMigrationService Tests:**
- Migration detection
- JSON data detection
- Complete migration flow
- Migration validation
- Empty data handling
- Property preservation
- Backup creation

## Performance Considerations

### SQLite Advantages
- **Faster queries**: Indexed columns enable efficient lookups
- **Better scalability**: Handles larger datasets more efficiently
- **Transactions**: Atomic operations ensure data consistency
- **Normalized data**: Reduces redundancy and improves query performance

### Migration Performance
- Migration is performed only once
- Progress is logged for debugging
- Failures are logged but don't prevent app startup
- Original data is preserved in backup file

## Troubleshooting

### Migration Issues

If migration fails:
1. Check logs for error messages (search for "migration" tag)
2. Original JSON data remains intact
3. App starts with empty SQLite database
4. Manual recovery possible from JSON backup

### Force Re-migration

To force a re-migration (useful for testing):

```dart
// Reset migration status
await StorageMigrationService.resetMigrationStatus();

// Trigger migration
await StorageMigrationService.migrateToSqlite();
```

### Switching Between Backends

**Important**: Once migrated to SQLite, switching back to JSON backend will show the old data (pre-migration). The backends are independent.

To safely switch:
1. Export your data before switching
2. Use the desired backend flag
3. Import data if needed

## Code Examples

### Using the Repository Directly

```dart
// Get repository instance (uses factory)
final repository = ExpenseGroupRepositoryFactory.getRepository();

// Save a group
final result = await repository.saveGroup(myGroup);
if (result.isSuccess) {
  print('Group saved successfully');
}

// Get all active groups
final activeGroups = await repository.getActiveGroups();
if (activeGroups.isSuccess) {
  for (final group in activeGroups.data!) {
    print('Group: ${group.title}');
  }
}
```

### Using ExpenseGroupStorageV2 (Recommended)

```dart
// The wrapper automatically uses the configured backend
final group = await ExpenseGroupStorageV2.getTripById(groupId);

// Add an expense
await ExpenseGroupStorageV2.addExpenseToGroup(groupId, expense);

// Get all groups
final groups = await ExpenseGroupStorageV2.getAllGroups();
```

## Future Enhancements

Potential improvements for future versions:
- Database optimization and vacuuming
- Incremental backups
- Data export to SQLite file
- Migration progress UI
- Offline sync support
- Performance monitoring and analytics

## References

- **SQLite Package**: [sqflite](https://pub.dev/packages/sqflite)
- **Repository Pattern**: `packages/caravella_core/lib/data/expense_group_repository.dart`
- **Migration Service**: `packages/caravella_core/lib/data/storage_migration_service.dart`
- **Factory Pattern**: `packages/caravella_core/lib/data/expense_group_repository_factory.dart`
