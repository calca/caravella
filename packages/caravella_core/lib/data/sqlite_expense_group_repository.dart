import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/expense_group.dart';
import '../model/expense_details.dart';
import '../model/expense_participant.dart';
import '../model/expense_category.dart';
import '../model/expense_location.dart';
import '../model/expense_group_type.dart';
import 'expense_group_repository.dart';
import 'storage_errors.dart';
import 'storage_performance.dart';

/// SQLite-based implementation of ExpenseGroupRepository
/// Provides better performance and scalability compared to JSON file storage
class SqliteExpenseGroupRepository
    with PerformanceMonitoring
    implements IExpenseGroupRepository {
  static const String _databaseName = 'expense_groups.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _tableGroups = 'groups';
  static const String _tableParticipants = 'participants';
  static const String _tableCategories = 'categories';
  static const String _tableExpenses = 'expenses';
  static const String _tableAttachments = 'attachments';

  Database? _database;

  /// Get or initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
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

  /// Create database schema
  Future<void> _createDatabase(Database db, int version) async {
    // Groups table
    await db.execute('''
      CREATE TABLE $_tableGroups (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        currency TEXT NOT NULL,
        start_date INTEGER,
        end_date INTEGER,
        timestamp INTEGER NOT NULL,
        pinned INTEGER NOT NULL DEFAULT 0,
        archived INTEGER NOT NULL DEFAULT 0,
        file TEXT,
        color INTEGER,
        notification_enabled INTEGER NOT NULL DEFAULT 0,
        group_type TEXT,
        auto_location_enabled INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Participants table
    await db.execute('''
      CREATE TABLE $_tableParticipants (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES $_tableGroups (id) ON DELETE CASCADE
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE $_tableCategories (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES $_tableGroups (id) ON DELETE CASCADE
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE $_tableExpenses (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        name TEXT NOT NULL,
        amount REAL,
        date INTEGER NOT NULL,
        category_id TEXT NOT NULL,
        paid_by_id TEXT NOT NULL,
        location_latitude REAL,
        location_longitude REAL,
        location_name TEXT,
        note TEXT,
        FOREIGN KEY (group_id) REFERENCES $_tableGroups (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES $_tableCategories (id),
        FOREIGN KEY (paid_by_id) REFERENCES $_tableParticipants (id)
      )
    ''');

    // Attachments table
    await db.execute('''
      CREATE TABLE $_tableAttachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expense_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        FOREIGN KEY (expense_id) REFERENCES $_tableExpenses (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_groups_timestamp ON $_tableGroups(timestamp DESC)');
    await db.execute('CREATE INDEX idx_groups_pinned ON $_tableGroups(pinned, archived)');
    await db.execute('CREATE INDEX idx_participants_group ON $_tableParticipants(group_id)');
    await db.execute('CREATE INDEX idx_categories_group ON $_tableCategories(group_id)');
    await db.execute('CREATE INDEX idx_expenses_group ON $_tableExpenses(group_id)');
    await db.execute('CREATE INDEX idx_expenses_date ON $_tableExpenses(date DESC)');
  }

  /// Handle database upgrades
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getAllGroups() async {
    return await measureOperation('getAllGroups', () async {
      try {
        final db = await database;
        final groups = await _loadAllGroups(db);
        groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return StorageResult.success(groups);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to get all groups',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getActiveGroups() async {
    return await measureOperation('getActiveGroups', () async {
      try {
        final db = await database;
        final groups = await _loadAllGroups(db);
        final activeGroups = groups.where((g) => !g.archived).toList();
        activeGroups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return StorageResult.success(activeGroups);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to get active groups',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getArchivedGroups() async {
    return await measureOperation('getArchivedGroups', () async {
      try {
        final db = await database;
        final groups = await _loadAllGroups(db);
        final archivedGroups = groups.where((g) => g.archived).toList();
        archivedGroups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return StorageResult.success(archivedGroups);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to get archived groups',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<ExpenseGroup?>> getGroupById(String id) async {
    return await measureOperation('getGroupById', () async {
      try {
        final db = await database;
        final group = await _loadGroupById(db, id);
        return StorageResult.success(group);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to get group by ID',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<ExpenseDetails?>> getExpenseById(
    String groupId,
    String expenseId,
  ) async {
    return await measureOperation('getExpenseById', () async {
      try {
        final db = await database;
        final group = await _loadGroupById(db, groupId);
        if (group == null) return StorageResult.success(null);
        
        final expense = group.expenses.firstWhere(
          (e) => e.id == expenseId,
          orElse: () => throw NotFoundError('Expense not found: $expenseId'),
        );
        return StorageResult.success(expense);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to get expense by ID',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<ExpenseGroup?>> getPinnedGroup() async {
    return await measureOperation('getPinnedGroup', () async {
      try {
        final db = await database;
        final groups = await _loadAllGroups(db);
        final pinnedGroup = groups.where((g) => g.pinned && !g.archived).firstOrNull;
        return StorageResult.success(pinnedGroup);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to get pinned group',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<void>> saveGroup(ExpenseGroup group) async {
    return await measureOperation('saveGroup', () async {
      try {
        // Validate group before saving
        final validation = validateGroup(group);
        if (validation.isFailure) {
          return StorageResult.failure(validation.error!);
        }

        final db = await database;
        
        await db.transaction((txn) async {
          // Save group metadata
          await txn.insert(
            _tableGroups,
            _groupToMap(group),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          // Delete existing related data
          await txn.delete(_tableParticipants, where: 'group_id = ?', whereArgs: [group.id]);
          await txn.delete(_tableCategories, where: 'group_id = ?', whereArgs: [group.id]);
          await txn.delete(_tableExpenses, where: 'group_id = ?', whereArgs: [group.id]);
          // Attachments will be deleted by CASCADE

          // Save participants
          for (final participant in group.participants) {
            await txn.insert(_tableParticipants, {
              'id': participant.id,
              'group_id': group.id,
              'name': participant.name,
            });
          }

          // Save categories
          for (final category in group.categories) {
            await txn.insert(_tableCategories, {
              'id': category.id,
              'group_id': group.id,
              'name': category.name,
            });
          }

          // Save expenses and attachments
          for (final expense in group.expenses) {
            await txn.insert(_tableExpenses, _expenseToMap(expense, group.id));
            
            // Save attachments
            for (final attachment in expense.attachments) {
              await txn.insert(_tableAttachments, {
                'expense_id': expense.id,
                'file_path': attachment,
              });
            }
          }
        });

        return const StorageResult.success(null);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to save group',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<void>> addExpenseGroup(ExpenseGroup group) async {
    return await saveGroup(group);
  }

  @override
  Future<StorageResult<void>> updateGroupMetadata(ExpenseGroup group) async {
    return await measureOperation('updateGroupMetadata', () async {
      try {
        final db = await database;
        await db.update(
          _tableGroups,
          _groupToMap(group),
          where: 'id = ?',
          whereArgs: [group.id],
        );
        return const StorageResult.success(null);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to update group metadata',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<void>> deleteGroup(String groupId) async {
    return await measureOperation('deleteGroup', () async {
      try {
        final db = await database;
        await db.delete(_tableGroups, where: 'id = ?', whereArgs: [groupId]);
        return const StorageResult.success(null);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to delete group',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<void>> setPinnedGroup(String groupId) async {
    return await measureOperation('setPinnedGroup', () async {
      try {
        final db = await database;
        
        await db.transaction((txn) async {
          // Unpin all groups
          await txn.update(_tableGroups, {'pinned': 0});
          
          // Pin the specified group
          await txn.update(
            _tableGroups,
            {'pinned': 1},
            where: 'id = ?',
            whereArgs: [groupId],
          );
        });
        
        return const StorageResult.success(null);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to set pinned group',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<void>> removePinnedGroup(String groupId) async {
    return await measureOperation('removePinnedGroup', () async {
      try {
        final db = await database;
        await db.update(
          _tableGroups,
          {'pinned': 0},
          where: 'id = ?',
          whereArgs: [groupId],
        );
        return const StorageResult.success(null);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to remove pinned group',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<void>> archiveGroup(String groupId) async {
    return await measureOperation('archiveGroup', () async {
      try {
        final db = await database;
        await db.update(
          _tableGroups,
          {'archived': 1, 'pinned': 0},
          where: 'id = ?',
          whereArgs: [groupId],
        );
        return const StorageResult.success(null);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to archive group',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  Future<StorageResult<void>> unarchiveGroup(String groupId) async {
    return await measureOperation('unarchiveGroup', () async {
      try {
        final db = await database;
        await db.update(
          _tableGroups,
          {'archived': 0},
          where: 'id = ?',
          whereArgs: [groupId],
        );
        return const StorageResult.success(null);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to unarchive group',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  @override
  StorageResult<void> validateGroup(ExpenseGroup group) {
    return ExpenseGroupValidator.validate(group);
  }

  @override
  Future<StorageResult<List<String>>> checkDataIntegrity() async {
    return await measureOperation('checkDataIntegrity', () async {
      try {
        final db = await database;
        final groups = await _loadAllGroups(db);
        return ExpenseGroupValidator.validateDataIntegrity(groups);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }
        return StorageResult.failure(
          FileOperationError(
            'Failed to check data integrity',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    });
  }

  // Helper methods

  /// Load all groups from database
  Future<List<ExpenseGroup>> _loadAllGroups(Database db) async {
    final groupMaps = await db.query(_tableGroups);
    final groups = <ExpenseGroup>[];

    for (final groupMap in groupMaps) {
      final group = await _mapToGroup(db, groupMap);
      groups.add(group);
    }

    return groups;
  }

  /// Load a single group by ID
  Future<ExpenseGroup?> _loadGroupById(Database db, String groupId) async {
    final groupMaps = await db.query(
      _tableGroups,
      where: 'id = ?',
      whereArgs: [groupId],
    );

    if (groupMaps.isEmpty) return null;

    return await _mapToGroup(db, groupMaps.first);
  }

  /// Convert database map to ExpenseGroup
  Future<ExpenseGroup> _mapToGroup(Database db, Map<String, dynamic> map) async {
    final groupId = map['id'] as String;

    // Load participants
    final participantMaps = await db.query(
      _tableParticipants,
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    final participants = participantMaps.map((m) => ExpenseParticipant(
      id: m['id'] as String,
      name: m['name'] as String,
    )).toList();

    // Load categories
    final categoryMaps = await db.query(
      _tableCategories,
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    final categories = categoryMaps.map((m) => ExpenseCategory(
      id: m['id'] as String,
      name: m['name'] as String,
    )).toList();

    // Load expenses
    final expenseMaps = await db.query(
      _tableExpenses,
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'date DESC',
    );
    
    final expenses = <ExpenseDetails>[];
    for (final expenseMap in expenseMaps) {
      final expense = await _mapToExpense(db, expenseMap, participants, categories);
      expenses.add(expense);
    }

    return ExpenseGroup(
      id: groupId,
      title: map['title'] as String,
      currency: map['currency'] as String,
      participants: participants,
      categories: categories,
      expenses: expenses,
      startDate: map['start_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int)
          : null,
      endDate: map['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      pinned: (map['pinned'] as int) == 1,
      archived: (map['archived'] as int) == 1,
      file: map['file'] as String?,
      color: map['color'] as int?,
      notificationEnabled: (map['notification_enabled'] as int) == 1,
      groupType: map['group_type'] != null 
          ? ExpenseGroupType.fromJson(map['group_type'])
          : null,
      autoLocationEnabled: (map['auto_location_enabled'] as int) == 1,
    );
  }

  /// Convert ExpenseGroup to database map
  Map<String, dynamic> _groupToMap(ExpenseGroup group) {
    return {
      'id': group.id,
      'title': group.title,
      'currency': group.currency,
      'start_date': group.startDate?.millisecondsSinceEpoch,
      'end_date': group.endDate?.millisecondsSinceEpoch,
      'timestamp': group.timestamp.millisecondsSinceEpoch,
      'pinned': group.pinned ? 1 : 0,
      'archived': group.archived ? 1 : 0,
      'file': group.file,
      'color': group.color,
      'notification_enabled': group.notificationEnabled ? 1 : 0,
      'group_type': group.groupType?.toJson(),
      'auto_location_enabled': group.autoLocationEnabled ? 1 : 0,
    };
  }

  /// Convert database map to ExpenseDetails
  Future<ExpenseDetails> _mapToExpense(
    Database db,
    Map<String, dynamic> map,
    List<ExpenseParticipant> participants,
    List<ExpenseCategory> categories,
  ) async {
    final paidById = map['paid_by_id'] as String;
    final categoryId = map['category_id'] as String;
    final expenseId = map['id'] as String;

    final paidBy = participants.firstWhere(
      (p) => p.id == paidById,
      orElse: () => ExpenseParticipant(id: paidById, name: 'Unknown'),
    );
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => ExpenseCategory(id: categoryId, name: 'Unknown'),
    );

    // Load attachments
    final attachmentMaps = await db.query(
      _tableAttachments,
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
    final attachments = attachmentMaps
        .map((m) => m['file_path'] as String)
        .toList();

    return ExpenseDetails(
      id: expenseId,
      name: map['name'] as String,
      amount: map['amount'] as double?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      category: category,
      paidBy: paidBy,
      note: map['note'] as String?,
      location: (map['location_latitude'] != null && map['location_longitude'] != null)
          ? ExpenseLocation(
              latitude: map['location_latitude'] as double,
              longitude: map['location_longitude'] as double,
              name: map['location_name'] as String?,
            )
          : null,
      attachments: attachments,
    );
  }

  /// Convert ExpenseDetails to database map
  Map<String, dynamic> _expenseToMap(ExpenseDetails expense, String groupId) {
    return {
      'id': expense.id,
      'group_id': groupId,
      'name': expense.name,
      'amount': expense.amount,
      'date': expense.date.millisecondsSinceEpoch,
      'category_id': expense.category.id,
      'paid_by_id': expense.paidBy.id,
      'note': expense.note,
      'location_latitude': expense.location?.latitude,
      'location_longitude': expense.location?.longitude,
      'location_name': expense.location?.name,
    };
  }

  /// Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
