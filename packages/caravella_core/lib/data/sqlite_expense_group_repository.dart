import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/expense_group.dart';
import '../model/expense_details.dart';
import '../model/expense_participant.dart';
import '../model/expense_category.dart';
import '../services/logging/logger_service.dart';
import 'expense_group_repository.dart';
import 'storage_errors.dart';
import 'storage_performance.dart';
import 'sqlite_group_mapper.dart';
import 'sqlite_schema.dart';
import 'sqlite_tables.dart';

/// SQLite-based implementation of ExpenseGroupRepository
/// Provides better performance and scalability compared to JSON file storage
///
/// Schema creation lives in [createSqliteSchema] (`sqlite_schema.dart`) and
/// row<->model conversion in [SqliteGroupMapper] (`sqlite_group_mapper.dart`);
/// this class only owns the database lifecycle and the `IExpenseGroupRepository`
/// method implementations, each wrapped by [_guarded] to avoid repeating the
/// same try/catch/measureOperation boilerplate.
class SqliteExpenseGroupRepository
    with PerformanceMonitoring
    implements IExpenseGroupRepository {
  static const String _databaseName = 'expense_groups.db';
  static const int _databaseVersion = 4;

  // Table names — accessible for SyncDao and other sync infrastructure
  static const String tableGroups = kTableGroups;
  static const String tableParticipants = kTableParticipants;
  static const String tableCategories = kTableCategories;
  static const String tableExpenses = kTableExpenses;
  static const String tableAttachments = kTableAttachments;
  static const String tableDeviceMeta = kTableDeviceMeta;
  static const String tableSyncLog = kTableSyncLog;
  static const String tablePairedDevices = kTablePairedDevices;

  final SqliteGroupMapper _mapper = const SqliteGroupMapper();

  Database? _database;

  /// Optional custom database path for testing
  final String? _customDatabasePath;

  /// Creates a SQLite repository.
  ///
  /// If [databasePath] is provided, it will be used instead of the default path.
  /// This is useful for testing with in-memory databases or custom paths.
  SqliteExpenseGroupRepository({String? databasePath})
    : _customDatabasePath = databasePath;

  /// Get or initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    try {
      final String path;
      if (_customDatabasePath != null) {
        path = _customDatabasePath;
      } else {
        final databasesPath = await getDatabasesPath();
        path = join(databasesPath, _databaseName);
      }

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: (db, version) => createSqliteSchema(db),
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      throw FileOperationError(
        'Failed to initialize database',
        details: e.toString(),
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Handle database upgrades
  ///
  /// Every database that existed before this sync feature landed is at
  /// on-disk version 2 (bumped previously for aggregation views that were
  /// later dropped without a version change) and has none of the sync
  /// columns/tables below — there was never a real "v2 with sync columns"
  /// database in the wild. So all sync additions are gated on `oldVersion < 3`
  /// as a single step; gating part of them on `oldVersion < 2` (as a separate
  /// step) skipped them entirely for real users, since their on-disk version
  /// is already 2, leaving `deleted`/`device_id`/`updated_at`/`sync_version`
  /// missing and breaking every read (`WHERE deleted = ?`) and write
  /// (`INSERT` with those columns) against the groups table.
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 3) {
      LoggerService.info(
        'Migrating database from v$oldVersion to v3',
        name: 'storage.sqlite',
      );

      // Add sync columns to groups table
      await db.execute(
        "ALTER TABLE $kTableGroups ADD COLUMN device_id TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        'ALTER TABLE $kTableGroups ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $kTableGroups ADD COLUMN deleted INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $kTableGroups ADD COLUMN sync_version INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $kTableGroups ADD COLUMN sync_enabled INTEGER NOT NULL DEFAULT 0',
      );

      // Create new sync tables
      await db.execute('''
        CREATE TABLE $kTableDeviceMeta (
          device_id TEXT PRIMARY KEY,
          device_name TEXT,
          last_seen INTEGER,
          vector_clock TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE $kTableSyncLog (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          peer_id TEXT NOT NULL,
          channel TEXT NOT NULL,
          synced_at INTEGER NOT NULL,
          delta_sent INTEGER NOT NULL DEFAULT 0,
          delta_recv INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Create indexes for sync columns
      await db.execute(
        'CREATE INDEX idx_groups_updated_at ON $kTableGroups(updated_at)',
      );
      await db.execute(
        'CREATE INDEX idx_groups_deleted ON $kTableGroups(deleted)',
      );

      // Backfill: set updated_at = timestamp for all existing groups
      await db.execute(
        'UPDATE $kTableGroups SET updated_at = timestamp WHERE updated_at = 0',
      );

      LoggerService.info(
        'Database migration to v3 complete',
        name: 'storage.sqlite',
      );
    }

    if (oldVersion < 4) {
      LoggerService.info(
        'Migrating database from v$oldVersion to v4',
        name: 'storage.sqlite',
      );

      await db.execute('''
        CREATE TABLE $kTablePairedDevices (
          device_id TEXT PRIMARY KEY,
          device_name TEXT NOT NULL,
          platform TEXT,
          paired_at INTEGER NOT NULL
        )
      ''');

      LoggerService.info(
        'Database migration to v4 complete',
        name: 'storage.sqlite',
      );
    }
  }

  /// Runs [op], measuring its performance (via [measureOperation]) and
  /// converting any thrown [StorageError] — or other exception, wrapped as a
  /// [FileOperationError] with [failureMessage] — into a [StorageResult],
  /// instead of repeating the same try/catch in every method below.
  Future<StorageResult<T>> _guarded<T>(
    String operationName,
    String failureMessage,
    Future<T> Function() op,
  ) {
    return measureOperation<StorageResult<T>>(operationName, () async {
      try {
        return StorageResult.success(await op());
      } catch (e) {
        if (e is StorageError) return StorageResult.failure(e);
        return StorageResult.failure(
          FileOperationError(
            failureMessage,
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getAllGroups() {
    return _guarded('getAllGroups', 'Failed to get all groups', () async {
      final db = await database;
      final groups = await _mapper.loadAllGroups(db);
      groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return groups;
    });
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getActiveGroups() {
    return _guarded(
      'getActiveGroups',
      'Failed to get active groups',
      () async {
        final db = await database;
        final groups = await _mapper.loadAllGroups(db);
        final activeGroups = groups.where((g) => !g.archived).toList();
        activeGroups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return activeGroups;
      },
    );
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getArchivedGroups() {
    return _guarded(
      'getArchivedGroups',
      'Failed to get archived groups',
      () async {
        final db = await database;
        final groups = await _mapper.loadAllGroups(db);
        final archivedGroups = groups.where((g) => g.archived).toList();
        archivedGroups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return archivedGroups;
      },
    );
  }

  @override
  Future<StorageResult<ExpenseGroup?>> getGroupById(String id) {
    return _guarded('getGroupById', 'Failed to get group by ID', () async {
      final db = await database;
      return await _mapper.loadGroupById(db, id);
    });
  }

  @override
  Future<StorageResult<ExpenseDetails?>> getExpenseById(
    String groupId,
    String expenseId,
  ) {
    return _guarded('getExpenseById', 'Failed to get expense by ID', () async {
      final db = await database;
      final group = await _mapper.loadGroupById(db, groupId);
      if (group == null) return null;

      return group.expenses.firstWhere(
        (e) => e.id == expenseId,
        orElse: () => throw NotFoundError('Expense not found: $expenseId'),
      );
    });
  }

  @override
  Future<StorageResult<ExpenseGroup?>> getPinnedGroup() {
    return _guarded('getPinnedGroup', 'Failed to get pinned group', () async {
      final db = await database;
      final groups = await _mapper.loadAllGroups(db);
      return groups.where((g) => g.pinned && !g.archived).firstOrNull;
    });
  }

  @override
  Future<StorageResult<void>> saveGroup(ExpenseGroup group) {
    return _guarded('saveGroup', 'Failed to save group', () async {
      // Validate group before saving; throws the original StorageError on
      // failure, which _guarded converts back into a StorageResult.failure.
      validateGroup(group).unwrap();

      final db = await database;

      await db.transaction((txn) async {
        // Save group metadata
        await txn.insert(
          kTableGroups,
          _mapper.groupToMap(group),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Delete existing related data
        await txn.delete(
          kTableParticipants,
          where: 'group_id = ?',
          whereArgs: [group.id],
        );
        await txn.delete(
          kTableCategories,
          where: 'group_id = ?',
          whereArgs: [group.id],
        );
        await txn.delete(
          kTableExpenses,
          where: 'group_id = ?',
          whereArgs: [group.id],
        );
        // Attachments will be deleted by CASCADE

        // Save participants
        for (final participant in group.participants) {
          await txn.insert(kTableParticipants, {
            'id': participant.id,
            'group_id': group.id,
            'name': participant.name,
          });
        }

        // Save categories
        for (final category in group.categories) {
          await txn.insert(kTableCategories, {
            'id': category.id,
            'group_id': group.id,
            'name': category.name,
          });
        }

        // Save expenses and attachments
        for (final expense in group.expenses) {
          await txn.insert(
            kTableExpenses,
            _mapper.expenseToMap(expense, group.id),
          );

          // Save attachments
          for (final attachment in expense.attachments) {
            await txn.insert(kTableAttachments, {
              'expense_id': expense.id,
              'file_path': attachment,
            });
          }
        }
      });
    });
  }

  @override
  Future<StorageResult<void>> addExpenseGroup(ExpenseGroup group) async {
    return await saveGroup(group);
  }

  @override
  Future<StorageResult<void>> updateGroupMetadata(ExpenseGroup group) {
    return _guarded(
      'updateGroupMetadata',
      'Failed to update group metadata',
      () async {
        final db = await database;

        await db.transaction((txn) async {
          // Update group metadata
          await txn.update(
            kTableGroups,
            _mapper.groupToMap(group),
            where: 'id = ?',
            whereArgs: [group.id],
          );

          // Get existing participant IDs to determine which to delete
          final existingParticipants = await txn.query(
            kTableParticipants,
            columns: ['id'],
            where: 'group_id = ?',
            whereArgs: [group.id],
          );
          final existingParticipantIds = existingParticipants
              .map((row) => row['id'] as String)
              .toSet();

          // Get new participant IDs
          final newParticipantIds = group.participants
              .map((p) => p.id)
              .toSet();

          // Delete participants that are no longer in the group
          final participantsToDelete = existingParticipantIds.difference(
            newParticipantIds,
          );
          for (final id in participantsToDelete) {
            await txn.delete(
              kTableParticipants,
              where: 'id = ? AND group_id = ?',
              whereArgs: [id, group.id],
            );
          }

          // Insert or update participants (using REPLACE for simplicity)
          for (final participant in group.participants) {
            await txn.insert(
              kTableParticipants,
              {
                'id': participant.id,
                'group_id': group.id,
                'name': participant.name,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          // Get existing category IDs to determine which to delete
          final existingCategories = await txn.query(
            kTableCategories,
            columns: ['id'],
            where: 'group_id = ?',
            whereArgs: [group.id],
          );
          final existingCategoryIds = existingCategories
              .map((row) => row['id'] as String)
              .toSet();

          // Get new category IDs
          final newCategoryIds = group.categories.map((c) => c.id).toSet();

          // Delete categories that are no longer in the group
          final categoriesToDelete = existingCategoryIds.difference(
            newCategoryIds,
          );
          for (final id in categoriesToDelete) {
            await txn.delete(
              kTableCategories,
              where: 'id = ? AND group_id = ?',
              whereArgs: [id, group.id],
            );
          }

          // Insert or update categories (using REPLACE for simplicity)
          for (final category in group.categories) {
            await txn.insert(
              kTableCategories,
              {
                'id': category.id,
                'group_id': group.id,
                'name': category.name,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        });
      },
    );
  }

  @override
  Future<StorageResult<void>> deleteGroup(String groupId) {
    return _guarded('deleteGroup', 'Failed to delete group', () async {
      final db = await database;
      await db.delete(kTableGroups, where: 'id = ?', whereArgs: [groupId]);
    });
  }

  @override
  Future<StorageResult<void>> setPinnedGroup(String groupId) {
    return _guarded('setPinnedGroup', 'Failed to set pinned group', () async {
      final db = await database;

      await db.transaction((txn) async {
        // Unpin all groups
        await txn.update(kTableGroups, {'pinned': 0});

        // Pin the specified group
        await txn.update(
          kTableGroups,
          {'pinned': 1},
          where: 'id = ?',
          whereArgs: [groupId],
        );
      });
    });
  }

  @override
  Future<StorageResult<void>> removePinnedGroup(String groupId) {
    return _guarded(
      'removePinnedGroup',
      'Failed to remove pinned group',
      () async {
        final db = await database;
        await db.update(
          kTableGroups,
          {'pinned': 0},
          where: 'id = ?',
          whereArgs: [groupId],
        );
      },
    );
  }

  @override
  Future<StorageResult<void>> archiveGroup(String groupId) {
    return _guarded('archiveGroup', 'Failed to archive group', () async {
      final db = await database;
      await db.update(
        kTableGroups,
        {'archived': 1, 'pinned': 0},
        where: 'id = ?',
        whereArgs: [groupId],
      );
    });
  }

  @override
  Future<StorageResult<void>> unarchiveGroup(String groupId) {
    return _guarded('unarchiveGroup', 'Failed to unarchive group', () async {
      final db = await database;
      await db.update(
        kTableGroups,
        {'archived': 0},
        where: 'id = ?',
        whereArgs: [groupId],
      );
    });
  }

  @override
  StorageResult<void> validateGroup(ExpenseGroup group) {
    return ExpenseGroupValidator.validate(group);
  }

  @override
  Future<StorageResult<List<String>>> checkDataIntegrity() {
    return _guarded(
      'checkDataIntegrity',
      'Failed to check data integrity',
      () async {
        final db = await database;
        final groups = await _mapper.loadAllGroups(db);
        return ExpenseGroupValidator.validateDataIntegrity(groups).unwrap();
      },
    );
  }

  // ---- Aggregation / stats methods ----

  @override
  Future<StorageResult<double>> getTotalExpenses(String groupId) {
    return _guarded(
      'getTotalExpenses',
      'Failed to get total expenses',
      () async {
        final db = await database;
        final rows = await db.rawQuery(
          'SELECT COALESCE(SUM(amount), 0.0) AS total '
          'FROM $kTableExpenses WHERE group_id = ?',
          [groupId],
        );
        return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
      },
    );
  }

  @override
  Future<StorageResult<double>> getTodaySpending(String groupId) {
    return _guarded(
      'getTodaySpending',
      'Failed to get today spending',
      () async {
        final db = await database;
        final now = DateTime.now();
        final startOfDay = DateTime(
          now.year,
          now.month,
          now.day,
        ).millisecondsSinceEpoch;
        final startOfNextDay = DateTime(now.year, now.month, now.day)
            .add(const Duration(days: 1))
            .millisecondsSinceEpoch;
        final rows = await db.rawQuery(
          'SELECT COALESCE(SUM(amount), 0.0) AS today_total '
          'FROM $kTableExpenses '
          'WHERE group_id = ? AND date >= ? AND date < ?',
          [groupId, startOfDay, startOfNextDay],
        );
        return (rows.first['today_total'] as num?)?.toDouble() ?? 0.0;
      },
    );
  }

  @override
  Future<StorageResult<List<ExpenseDetails>>> getRecentExpenses(
    String groupId, {
    int limit = 2,
  }) {
    return _guarded(
      'getRecentExpenses',
      'Failed to get recent expenses',
      () async {
        final db = await database;

        // Load participants and categories first (needed for mapping)
        final participantMaps = await db.query(
          kTableParticipants,
          where: 'group_id = ?',
          whereArgs: [groupId],
        );
        final participants = participantMaps
            .map(
              (m) => ExpenseParticipant(
                id: m['id'] as String,
                name: m['name'] as String,
              ),
            )
            .toList();

        final categoryMaps = await db.query(
          kTableCategories,
          where: 'group_id = ?',
          whereArgs: [groupId],
        );
        final categories = categoryMaps
            .map(
              (m) => ExpenseCategory(
                id: m['id'] as String,
                name: m['name'] as String,
              ),
            )
            .toList();

        final expenseMaps = await db.query(
          kTableExpenses,
          where: 'group_id = ?',
          whereArgs: [groupId],
          orderBy: 'date DESC',
          limit: limit,
        );

        final expenses = <ExpenseDetails>[];
        for (final expenseMap in expenseMaps) {
          final expense = await _mapper.mapToExpense(
            db,
            expenseMap,
            participants,
            categories,
          );
          expenses.add(expense);
        }

        return expenses;
      },
    );
  }

  @override
  Future<StorageResult<int>> getTotalExpenseCount() {
    return _guarded(
      'getTotalExpenseCount',
      'Failed to get total expense count',
      () async {
        final db = await database;
        final rows = await db.rawQuery(
          'SELECT COUNT(*) AS total_count FROM $kTableExpenses',
        );
        return (rows.first['total_count'] as num?)?.toInt() ?? 0;
      },
    );
  }

  /// Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
