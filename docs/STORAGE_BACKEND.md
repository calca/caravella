# Storage Backend

Caravella stores its data in a SQLite database behind one interface. Until 2.4 a JSON file backend (`FileBasedExpenseGroupRepository`, the `USE_JSON_BACKEND` define) was kept as an escape hatch; 2.5 removed it (#678). What remains of it is `LegacyJsonGroupReader`, which reads the old file once for the migration. This page replaces the old `SQLITE_BACKEND.md`.

For where this fits in the wider codebase, see [caravella_core reference § Storage architecture](PACKAGE_CARAVELLA_CORE.md#storage-architecture).

## The interface

`IExpenseGroupRepository` (`packages/caravella_core/lib/data/expense_group_repository.dart`) — 18 methods, all returning `StorageResult<T>` (`unwrap()`/`unwrapOr(fallback)`/`map()`). **Never depend on a concrete repository directly** — always go through `ExpenseGroupStorageV2` or this interface, so tests can hand the app a database of their own.

`ExpenseGroupValidator` (same file): `validate(group)` (empty title/currency, `startDate ≤ endDate`, duplicate participant/category IDs, non-positive expense amounts, dangling `paidBy`/category references) and `validateDataIntegrity(groups)` (duplicate group IDs, more than one pinned-and-non-archived group).

## Backend 1: SQLite (default) — `SqliteExpenseGroupRepository`

`packages/caravella_core/lib/data/sqlite_expense_group_repository.dart`. Uses `sqflite`, database file `expense_groups.db`, `_databaseVersion = 8`. Schema creation lives in `sqlite_schema.dart` (`createSqliteSchema`), table name constants in `sqlite_tables.dart`. No in-memory caching — every call reconstructs full `ExpenseGroup` objects via `_loadAllGroups`/`_loadGroupById`/`_mapToGroup`.

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
         location_latitude REAL, location_longitude REAL, location_name TEXT, location_details TEXT, note TEXT,
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

**Schema v7** adds `expenses.location_details`: the whole `ExpenseLocation` as JSON (`toJson`: address, street, locality, postal code, country, …). The three `location_*` columns held only coordinates and name, so a place from the automatic location — a locality but no name — read back as bare coordinates. `SqliteGroupMapper` reads the JSON when present and falls back to the three columns (still written, for older readers and for rows saved before v7, which keep what they had). Those older rows get their place named when the expense is opened (see [Location & Maps](LOCATION_AND_MAPS.md)): `fillExpenseLocation` (`IExpenseGroupRepository`) rewrites that expense's `location_*` columns only — no `updatedBy`, and `groups.updated_at` stays, so last-writer-wins sync doesn't take the fix for a newer version of the group.

**Schema v8** adds `groups.payments`: the payments ticked as paid in Settle up (`ExpenseGroup.payments`) as a JSON list of `SettlePayment.toJson`, null when there are none (`SqliteGroupMapper.paymentsToColumn`/`paymentsFromColumn`; an unreadable value reads as none). A group has a handful at most and always loads and saves them with itself, so they don't get a table. `ConflictResolver._saveGroupInTransaction` writes the column too.

**Schema v9** adds `groups.budget_amount` (REAL) and `groups.budget_period` (TEXT: `total`, `monthly`, `weekly`, `daily`), the group budget (`ExpenseGroup.budget`, `GroupBudget`); both null for no budget (`SqliteGroupMapper.budgetToColumns`/`budgetFromColumns`; an unknown period or an amount that isn't positive reads as none). `ConflictResolver._saveGroupInTransaction` writes them too.

Indexes: `idx_groups_timestamp(timestamp DESC)`, `idx_groups_pinned(pinned, archived)`, `idx_participants_group`, `idx_categories_group`, `idx_expenses_group`, `idx_expenses_date(date DESC)`, `idx_groups_updated_at`, `idx_groups_deleted`.

The v2 upgrade previously created three aggregation views (`v_group_totals`, `v_category_totals`, `v_participant_totals`), but no Dart code ever queried them — the stat methods (`getTotalExpenses`, `getTodaySpending`, `getTotalExpenseCount`, `getRecentExpenses`) use raw SQL directly instead. They were removed from `_createDatabase`/`_upgradeDatabase` as dead schema; installs that already ran the v2 migration keep the (harmless, unused) views until they reinstall — `_databaseVersion` was not bumped since removing an unused view isn't a schema change existing installs need to react to.

`SyncDao` (`packages/caravella_core/lib/sync/sync_dao.dart`) owns all reads/writes against the sync tables and columns above, including the `paired_devices` CRUD (`addPairedDevice`/`isPaired`/`getPairedDevices`/`removePairedDevice`) used to gate automatic LAN sync to devices that completed the QR pairing handshake (`LanSyncChannel`'s `isPeerAuthorized`/`onPairingRequest` callbacks, wired from `SyncOrchestrator`).

`saveGroup` runs inside a `db.transaction`: upserts the group row, then **deletes and re-inserts** all participants/categories/expenses/attachments for that group (no diffing). `updateGroupMetadata` instead diffs participant/category IDs (deletes only removed ones, `REPLACE`s the rest) while leaving expenses untouched — use `updateGroupMetadata` for metadata-only edits to avoid the expense-side churn of a full `saveGroup`.

`deleteGroup` leaves a **tombstone** instead of removing the row: `deleted = 1`, a new `updated_at` (`SyncClock`), `pinned = 0`, and the group's expenses (with their attachment rows), participants and categories deleted, in one transaction. Every read skips deleted groups (`SqliteGroupMapper`, `WHERE deleted = 0`). The tombstone is what tells the other devices the group is gone: it goes out in `deleted_groups` (Wi-Fi/Bluetooth deltas, Google Drive snapshots) and beats their older copy by Last Writer Wins, which is what stops the group coming back from them. Before 2.4.2 the row was removed, so a deletion never reached the other devices.

## The factory

`ExpenseGroupRepositoryFactory` (`expense_group_repository_factory.dart`) is a **singleton**: `getRepository()` creates the `SqliteExpenseGroupRepository` on first use and returns it from then on. `lib/main/app_initialization.dart`'s `initStorage()` calls it first, then runs the migration below. Tests point it at a database in a temporary file with `useForTesting(repository)` (`test/helpers/test_database.dart`'s `useTestDatabase()` does this), and `reset()` clears it.

## `ExpenseGroupStorageV2` — the facade to actually use

`data/expense_group_storage_v2.dart` is a static-method facade over whatever repository the factory returns, unwrapping `StorageResult`s to plain values/nulls. Adds higher-level ops not on the raw interface:

- `addExpenseToGroup` / `updateExpenseToGroup` / `removeExpenseFromGroup`
- `isParticipantAssigned` / `isCategoryAssigned` — checks if an id is referenced by any expense
- `removeParticipantIfUnused` / `removeCategoryIfUnused`
- `updateParticipantReferencesFromDiff` / `updateCategoryReferencesFromDiff` — rewrite the participant/category copies inside the group's expenses after a **rename**. In SQLite an expense row keeps only `paid_by_id`/`category_id` and is read back with the group's current participant/category, so the rename itself (`updateGroupMetadata`) is what the reader sees; these still keep the in-memory `ExpenseDetails` copies consistent

## Migration: JSON → SQLite

`StorageMigrationService` (`storage_migration_service.dart`), triggered from `initStorage()` at every launch until it has run once:

1. Skip if `isMigrationCompleted()` (SharedPreferences key `storage_migration_completed`, version-gated by `storage_migration_version` against `_currentMigrationVersion = 1`).
2. Read the old file with `LegacyJsonGroupReader.readGroups()` (`legacy_json_group_reader.dart`: `${ApplicationDocumentsDirectory}/expense_group_storage.json`, a JSON list of `ExpenseGroup.toJson`, checked with `validateDataIntegrity`). No file or no groups: mark the migration complete and stop. `hasJsonData()` still answers whether the file has data.
3. A read failure returns a `MigrationError` without marking complete, so the next launch tries again.
4. `sqliteRepository.saveGroup(group)` per group, tracking success/error counts.
5. If any failures occurred, return a `MigrationError` **without** marking complete.
6. `_validateMigration()` — reloads from SQLite, compares group counts and ID sets against the originals.
7. `_markMigrationCompleted()` — sets both SharedPreferences keys.
8. `_backupJsonFile()` — best-effort copy to `expense_group_storage.json.backup.<ISO8601-no-colons>`; failure here does not fail the migration.

`resetMigrationStatus()` exists for tests, to force re-migration.

## Supporting infrastructure

- **`storage_transaction.dart`** — removed 2026-07-14. It provided a `StorageTransaction`/`TransactionExecutor`/`executeTransaction` extension for queued, in-memory-validated batch operations, committed via one `saveAllGroups` call for the file backend — but for any other repository (i.e. SQLite) it fell back to a non-atomic per-group `saveGroup` loop with no rollback on partial failure, and that path had zero test coverage and zero production callers. Removed rather than fixed since nothing in `lib/` used it. If batched atomic writes are needed again, implement them against `SqliteExpenseGroupRepository`'s own `db.transaction` (see `saveGroup`/`updateGroupMetadata`) instead of resurrecting the generic extension.
- **`storage_performance.dart`** — `StoragePerformanceMonitor` (opt-in via `.enable()`, 1000-entry ring buffer) and the `PerformanceMonitoring` mixin (`measureOperation`/`measureSyncOperation`) the SQLite repository uses.
- **`test/storage_benchmark.dart`** — `BenchmarkConfig`/`BenchmarkResult` (p50/p95/p99/stddev) for load-testing repositories; lives under `packages/caravella_core/test/` (not `lib/`) since it's dev/test-only tooling, not part of the package's public API or production build.
- **`storage_errors.dart`** — the `StorageError` hierarchy: `FileOperationError`, `SerializationError`, `ValidationError` (with a `fieldErrors` map), `EntityNotFoundError`, `DataIntegrityError`, `ConcurrentModificationError`, `MigrationError`, `NotFoundError`.

## Testing

```bash
flutter test test/sqlite_repository_test.dart
flutter test test/storage_migration_test.dart
```

Tests that go through `ExpenseGroupStorageV2` call `useTestDatabase()` (`test/helpers/test_database.dart`): a new SQLite database in a temporary file (`sqflite_common_ffi`). Call it in `setUp` for a clean database per test. Participant, category and expense ids are primary keys across the whole database, so two groups in one test need their own ids, as in the app.

## See also

- [caravella_core reference](PACKAGE_CARAVELLA_CORE.md)
- [App: Settings § Backup & restore](APP_SETTINGS.md#backup--restore) — how the JSON export/import in Settings relates to (but is distinct from) this migration
