# Storage Backend

Caravella supports two interchangeable storage backends behind one interface. **SQLite is the default**; the legacy JSON file backend is kept for the `USE_JSON_BACKEND` escape hatch and as the migration source. This page replaces the old `SQLITE_BACKEND.md`.

For where this fits in the wider codebase, see [caravella_core reference § Storage architecture](PACKAGE_CARAVELLA_CORE.md#storage-architecture).

## The interface

`IExpenseGroupRepository` (`packages/caravella_core/lib/data/expense_group_repository.dart`) — 18 methods, all returning `StorageResult<T>` (`unwrap()`/`unwrapOr(fallback)`/`map()`). **Never depend on a concrete repository directly** — always go through `ExpenseGroupStorageV2` or this interface, so code works under both backends.

`ExpenseGroupValidator` (same file): `validate(group)` (empty title/currency, `startDate ≤ endDate`, duplicate participant/category IDs, non-positive expense amounts, dangling `paidBy`/category references) and `validateDataIntegrity(groups)` (duplicate group IDs, more than one pinned-and-non-archived group).

## Backend 1: SQLite (default) — `SqliteExpenseGroupRepository`

`packages/caravella_core/lib/data/sqlite_expense_group_repository.dart`. Uses `sqflite`, database file `expense_groups.db`, `_databaseVersion = 6`. Schema creation lives in `sqlite_schema.dart` (`createSqliteSchema`), table name constants in `sqlite_tables.dart`. No in-memory caching — every call reconstructs full `ExpenseGroup` objects via `_loadAllGroups`/`_loadGroupById`/`_mapToGroup`.

**Schema** (from `createSqliteSchema`):

```sql
groups(id TEXT PK, title, currency, start_date INTEGER, end_date INTEGER, timestamp INTEGER NOT NULL,
       pinned INTEGER DEFAULT 0, archived INTEGER DEFAULT 0, file TEXT, color INTEGER,
       notification_enabled INTEGER DEFAULT 0, group_type TEXT, auto_location_enabled INTEGER DEFAULT 0,
       device_id TEXT DEFAULT '', updated_at INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
       sync_version INTEGER DEFAULT 0, sync_enabled INTEGER DEFAULT 0)

participants(id TEXT PK, group_id TEXT NOT NULL, name TEXT NOT NULL,
             FK group_id -> groups ON DELETE CASCADE)

categories(id TEXT PK, group_id TEXT NOT NULL, name TEXT NOT NULL,
           FK group_id -> groups ON DELETE CASCADE)

expenses(id TEXT PK, group_id TEXT NOT NULL, name TEXT NOT NULL, amount REAL, date INTEGER NOT NULL,
         category_id TEXT NOT NULL, paid_by_id TEXT NOT NULL,
         location_latitude REAL, location_longitude REAL, location_name TEXT, note TEXT,
         created_by_device_id TEXT, created_by_device_name TEXT, created_by_user_name TEXT,
         updated_by_device_id TEXT, updated_by_device_name TEXT, updated_by_user_name TEXT,
         FK group_id -> groups CASCADE, FK category_id -> categories, FK paid_by_id -> participants)

attachments(id INTEGER PK AUTOINCREMENT, expense_id TEXT NOT NULL, file_path TEXT NOT NULL,
            FK expense_id -> expenses CASCADE)

-- Sync metadata (schema v3)
device_meta(device_id TEXT PK, device_name TEXT, last_seen INTEGER, vector_clock TEXT)
sync_log(id INTEGER PK AUTOINCREMENT, peer_id TEXT NOT NULL, channel TEXT NOT NULL,
         synced_at INTEGER NOT NULL, delta_sent INTEGER DEFAULT 0, delta_recv INTEGER DEFAULT 0)

-- Paired devices (schema v4) — QR-paired devices trusted for automatic LAN sync
paired_devices(device_id TEXT PK, device_name TEXT NOT NULL, platform TEXT, paired_at INTEGER NOT NULL,
               public_key TEXT)

-- Per-group pairing grants (schema v5) — which paired device may sync which group
paired_device_groups(device_id TEXT NOT NULL, group_id TEXT NOT NULL, granted_at INTEGER NOT NULL,
                      PRIMARY KEY (device_id, group_id))
```

**Schema v6** adds the six `created_by_*`/`updated_by_*` columns on `expenses` above — a snapshot (device id, device name, personal "name" setting) of who created the expense and who last modified it, taken at save time by `ExpenseGroupStorageV2.addExpenseToGroup`/`updateExpenseToGroup` (see `ExpenseAuthor`, `packages/caravella_core/lib/model/expense_author.dart`). Nullable and never backfilled — pre-v6 rows simply have no attribution history. `createdBy` is immutable once set (editing an expense preserves it and only re-stamps `updatedBy`).

Indexes: `idx_groups_timestamp(timestamp DESC)`, `idx_groups_pinned(pinned, archived)`, `idx_participants_group`, `idx_categories_group`, `idx_expenses_group`, `idx_expenses_date(date DESC)`, `idx_groups_updated_at`, `idx_groups_deleted`.

The v2 upgrade previously created three aggregation views (`v_group_totals`, `v_category_totals`, `v_participant_totals`), but no Dart code ever queried them — the stat methods (`getTotalExpenses`, `getTodaySpending`, `getTotalExpenseCount`, `getRecentExpenses`) use raw SQL directly instead. They were removed from `_createDatabase`/`_upgradeDatabase` as dead schema; installs that already ran the v2 migration keep the (harmless, unused) views until they reinstall — `_databaseVersion` was not bumped since removing an unused view isn't a schema change existing installs need to react to.

`SyncDao` (`packages/caravella_core/lib/sync/sync_dao.dart`) owns all reads/writes against the sync tables and columns above, including the `paired_devices` CRUD (`addPairedDevice`/`isPaired`/`getPairedDevices`/`removePairedDevice`) used to gate automatic LAN sync to devices that completed the QR pairing handshake (`LanSyncChannel`'s `isPeerAuthorized`/`onPairingRequest` callbacks, wired from `SyncOrchestrator`).

`saveGroup` runs inside a `db.transaction`: upserts the group row, then **deletes and re-inserts** all participants/categories/expenses/attachments for that group (no diffing). `updateGroupMetadata` instead diffs participant/category IDs (deletes only removed ones, `REPLACE`s the rest) while leaving expenses untouched — use `updateGroupMetadata` for metadata-only edits to avoid the expense-side churn of a full `saveGroup`.

## Backend 2: JSON file (legacy) — `FileBasedExpenseGroupRepository`

`packages/caravella_core/lib/data/file_based_expense_group_repository.dart`. Stores all groups as one JSON array in `${ApplicationDocumentsDirectory}/expense_group_storage.json`.

- In-memory cache (`_cachedGroups`, 5-minute validity), invalidated by comparing file mtime.
- `GroupIndex`/`ExpenseIndex` (`storage_index.dart`) for O(1) lookups, rebuilt on every load/save.
- Extra query methods not on the shared interface: `getGroupsByParticipant/Category/Currency`, `searchGroupsByTitle`, `getStorageStats`, `validateIndexConsistency`, `saveAllGroups`, `clearCache`, `forceReload`.
- `addExpenseGroup` force-reloads from disk first (bypassing cache) to avoid overwrite races between concurrent writers.
- `deleteGroup` also calls `AttachmentsStorageService.deleteGroupAttachments`.

## Selecting a backend: the factory

`ExpenseGroupRepositoryFactory` (`expense_group_repository_factory.dart`) is a **singleton** — `getRepository({useJsonBackend = false})` only honors the parameter on the *first* call; subsequent calls return the cached instance regardless of the argument. `reset()` clears it (test-only).

The app-level trigger is `lib/main/app_initialization.dart`'s `initStorage()`:

```dart
final shouldUseJson = String.fromEnvironment('USE_JSON_BACKEND', defaultValue: 'false')
    .toLowerCase() == 'true';
ExpenseGroupRepositoryFactory.getRepository(useJsonBackend: shouldUseJson);
```

```bash
# SQLite (default)
flutter run --flavor dev --dart-define=FLAVOR=dev

# JSON (legacy)
flutter run --flavor dev --dart-define=FLAVOR=dev --dart-define=USE_JSON_BACKEND=true
```

**Once migrated to SQLite, switching back to `USE_JSON_BACKEND=true` shows the pre-migration JSON snapshot — the two backends are independent after migration, not kept in sync.**

## `ExpenseGroupStorageV2` — the facade to actually use

`data/expense_group_storage_v2.dart` is a static-method facade over whatever repository the factory returns, unwrapping `StorageResult`s to plain values/nulls. Adds higher-level ops not on the raw interface:

- `addExpenseToGroup` / `updateExpenseToGroup` / `removeExpenseFromGroup`
- `isParticipantAssigned` / `isCategoryAssigned` — checks if an id is referenced by any expense
- `removeParticipantIfUnused` / `removeCategoryIfUnused`
- `updateParticipantReferencesFromDiff` / `updateCategoryReferencesFromDiff` — propagate a participant/category **rename** into the denormalized copies embedded in historical expenses (`ExpenseDetails.category`/`.paidBy` are full embedded objects, not IDs)

`clearCache()`/`forceReload()` only have an effect for the file-based backend (no-ops on SQLite) — safe to call unconditionally from shared code.

## Migration: JSON → SQLite

`StorageMigrationService` (`storage_migration_service.dart`), triggered from `initStorage()` only on the SQLite path:

1. Skip if `isMigrationCompleted()` (SharedPreferences key `storage_migration_completed`, version-gated by `storage_migration_version` against `_currentMigrationVersion = 1`).
2. `hasJsonData()` — checks the JSON file exists and isn't empty/`'[]'`.
3. Load all groups via `FileBasedExpenseGroupRepository().getAllGroups()`.
4. `sqliteRepository.saveGroup(group)` per group, tracking success/error counts.
5. If any failures occurred, return a `MigrationError` **without** marking complete.
6. `_validateMigration()` — reloads from SQLite, compares group counts and ID sets against the originals.
7. `_markMigrationCompleted()` — sets both SharedPreferences keys.
8. `_backupJsonFile()` — best-effort copy to `expense_group_storage.json.backup.<ISO8601-no-colons>`; failure here does not fail the migration.

`resetMigrationStatus()` exists for tests, to force re-migration.

## Supporting infrastructure

- **`storage_index.dart`** — `GroupIndex` (id map + pinned/archived/active sets, participant/category/currency/date-range lookups, title search, `validateConsistency()`) and `ExpenseIndex` (expenseId → `{groupId, expenseIndex}`); used only by the file-based repo.
- **`storage_transaction.dart`** — removed 2026-07-14. It provided a `StorageTransaction`/`TransactionExecutor`/`executeTransaction` extension for queued, in-memory-validated batch operations, committed via one `saveAllGroups` call for the file backend — but for any other repository (i.e. SQLite) it fell back to a non-atomic per-group `saveGroup` loop with no rollback on partial failure, and that path had zero test coverage and zero production callers. Removed rather than fixed since nothing in `lib/` used it. If batched atomic writes are needed again, implement them against `SqliteExpenseGroupRepository`'s own `db.transaction` (see `saveGroup`/`updateGroupMetadata`) instead of resurrecting the generic extension.
- **`storage_performance.dart`** — `StoragePerformanceMonitor` (opt-in via `.enable()`, 1000-entry ring buffer) and the `PerformanceMonitoring` mixin (`measureOperation`/`measureSyncOperation`) both repositories use.
- **`test/storage_benchmark.dart`** — `BenchmarkConfig`/`BenchmarkResult` (p50/p95/p99/stddev) for load-testing repositories; lives under `packages/caravella_core/test/` (not `lib/`) since it's dev/test-only tooling, not part of the package's public API or production build.
- **`storage_errors.dart`** — the `StorageError` hierarchy: `FileOperationError`, `SerializationError`, `ValidationError` (with a `fieldErrors` map), `EntityNotFoundError`, `DataIntegrityError`, `ConcurrentModificationError`, `MigrationError`, `NotFoundError`.

## Testing

```bash
flutter test test/sqlite_repository_test.dart
flutter test test/storage_migration_test.dart
```

## See also

- [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)
- [App: Settings § Backup & restore](APP_SETTINGS.md#backup--restore) — how the JSON export/import in Settings relates to (but is distinct from) this migration
- [Build Variants & Flavors](BUILD_VARIANTS.md) — the `USE_JSON_BACKEND` dart-define alongside the other flags
