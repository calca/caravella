import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'expense_group.dart';
import 'expense_details.dart';
import 'expense_group_repository.dart';
import 'storage_errors.dart';
import 'storage_performance.dart';
import 'storage_index.dart';

/// Improved implementation of ExpenseGroupRepository with caching and proper error handling
class FileBasedExpenseGroupRepository
    with PerformanceMonitoring
    implements IExpenseGroupRepository {
  static const String fileName = 'expense_group_storage.json';

  // In-memory cache to improve performance
  List<ExpenseGroup>? _cachedGroups;
  DateTime? _lastCacheUpdate;
  DateTime? _lastFileModification;

  // Indexes for fast lookups
  final GroupIndex _groupIndex = GroupIndex();
  final ExpenseIndex _expenseIndex = ExpenseIndex();

  // Cache validity duration (5 minutes)
  static const Duration cacheValidityDuration = Duration(minutes: 5);

  Future<File> _getFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/$fileName');
    } catch (e) {
      throw FileOperationError(
        'Failed to get storage file path',
        details: e.toString(),
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Checks if cache is still valid
  bool _isCacheValid() {
    if (_cachedGroups == null || _lastCacheUpdate == null) return false;

    final now = DateTime.now();
    final cacheAge = now.difference(_lastCacheUpdate!);

    return cacheAge < cacheValidityDuration;
  }

  /// Invalidates the cache
  void _invalidateCache() {
    _cachedGroups = null;
    _lastCacheUpdate = null;
    _lastFileModification = null;
    _groupIndex.clear();
    _expenseIndex.clear();
  }

  /// Loads groups from file with caching
  Future<StorageResult<List<ExpenseGroup>>> _loadGroups({
    bool forceReload = false,
  }) async {
    return await measureOperation(
      'loadGroups',
      () async {
        try {
          final file = await _getFile();

          // Check if we can use cached data
          if (!forceReload && _isCacheValid()) {
            // Additional check: has file been modified since cache?
            if (_lastFileModification != null && await file.exists()) {
              final stat = await file.stat();
              if (stat.modified.isAtSameMomentAs(_lastFileModification!)) {
                return StorageResult.success(_cachedGroups!);
              }
            } else if (!await file.exists() && _cachedGroups!.isEmpty) {
              // File doesn't exist and cache is empty - valid state
              return StorageResult.success(_cachedGroups!);
            }
          }

          // Load from file
          if (!await file.exists()) {
            _cachedGroups = [];
            _lastCacheUpdate = DateTime.now();
            _lastFileModification = null;
            return StorageResult.success(_cachedGroups!);
          }

          final stat = await file.stat();
          final contents = await file.readAsString();

          if (contents.trim().isEmpty) {
            _cachedGroups = [];
            _lastCacheUpdate = DateTime.now();
            _lastFileModification = stat.modified;
            return StorageResult.success(_cachedGroups!);
          }

          final dynamic jsonData = jsonDecode(contents);

          if (jsonData is! List) {
            throw SerializationError(
              'Invalid JSON format: expected list at root level',
              details: 'Found ${jsonData.runtimeType}',
            );
          }

          final groups = <ExpenseGroup>[];
          for (int i = 0; i < jsonData.length; i++) {
            try {
              final groupData = jsonData[i];
              if (groupData is! Map<String, dynamic>) {
                throw SerializationError(
                  'Invalid group data at index $i: expected object',
                  details: 'Found ${groupData.runtimeType}',
                );
              }
              groups.add(ExpenseGroup.fromJson(groupData));
            } catch (e) {
              throw SerializationError(
                'Failed to deserialize group at index $i',
                details: e.toString(),
                cause: e is Exception ? e : Exception(e.toString()),
              );
            }
          }

          // Validate data integrity
          final integrityCheck = ExpenseGroupValidator.validateDataIntegrity(
            groups,
          );
          if (integrityCheck.isFailure) {
            throw DataIntegrityError(
              'Data integrity validation failed',
              details: integrityCheck.error!.message,
            );
          }

          // Update cache
          _cachedGroups = groups;
          _lastCacheUpdate = DateTime.now();
          _lastFileModification = stat.modified;

          // Update indexes
          _groupIndex.rebuild(groups);
          _expenseIndex.rebuild(groups);

          return StorageResult.success(groups);
        } catch (e) {
          if (e is StorageError) {
            return StorageResult.failure(e);
          }

          return StorageResult.failure(
            FileOperationError(
              'Failed to load groups',
              details: e.toString(),
              cause: e is Exception ? e : Exception(e.toString()),
            ),
          );
        }
      },
      wasFromCache: _isCacheValid() && !forceReload,
      dataSize: _cachedGroups?.length,
    );
  }

  /// Saves groups to file and updates cache
  Future<StorageResult<void>> _saveGroups(List<ExpenseGroup> groups) async {
    return await measureOperation('saveGroups', () async {
      try {
        // Validate data integrity first
        final integrityCheck = ExpenseGroupValidator.validateDataIntegrity(
          groups,
        );
        if (integrityCheck.isFailure) {
          return StorageResult.failure(
            DataIntegrityError(
              'Cannot save: data integrity validation failed',
              details: integrityCheck.error!.message,
            ),
          );
        }

        // Enforce pin constraint: only one group can be pinned at a time
        final groupsToSave = List<ExpenseGroup>.from(groups);
        String? pinnedGroupId;
        for (int i = 0; i < groupsToSave.length; i++) {
          final group = groupsToSave[i];
          if (group.pinned && !group.archived) {
            if (pinnedGroupId == null) {
              pinnedGroupId = group.id;
            } else {
              // Multiple pinned groups found, unpin this one
              groupsToSave[i] = group.copyWith(pinned: false);
            }
          }
        }

        final file = await _getFile();
        final jsonList = groupsToSave.map((group) => group.toJson()).toList();
        final jsonString = jsonEncode(jsonList);

        await file.writeAsString(jsonString);

        // Update cache
        _cachedGroups = groupsToSave;
        _lastCacheUpdate = DateTime.now();

        // Update file modification time
        final stat = await file.stat();
        _lastFileModification = stat.modified;

        // Update indexes
        _groupIndex.rebuild(groupsToSave);
        _expenseIndex.rebuild(groupsToSave);

        return const StorageResult.success(null);
      } catch (e) {
        if (e is StorageError) {
          return StorageResult.failure(e);
        }

        return StorageResult.failure(
          FileOperationError(
            'Failed to save groups',
            details: e.toString(),
            cause: e is Exception ? e : Exception(e.toString()),
          ),
        );
      }
    }, dataSize: groups.length);
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getAllGroups() async {
    return await measureOperation('getAllGroups', () async {
      final result = await _loadGroups();
      if (result.isFailure) return result;

      // Use index for faster sorting if available
      if (!_groupIndex.isEmpty) {
        return StorageResult.success(_groupIndex.getAllGroups());
      }

      final groups = List<ExpenseGroup>.from(result.data!);
      groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return StorageResult.success(groups);
    }, wasFromCache: _isCacheValid());
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getActiveGroups() async {
    return await measureOperation('getActiveGroups', () async {
      final result = await _loadGroups();
      if (result.isFailure) return result;

      // Use index for faster filtering if available
      if (!_groupIndex.isEmpty) {
        return StorageResult.success(_groupIndex.getActiveGroups());
      }

      final activeGroups = result.data!
          .where((group) => !group.archived)
          .toList();
      activeGroups.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return StorageResult.success(activeGroups);
    }, wasFromCache: _isCacheValid());
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getArchivedGroups() async {
    return await measureOperation('getArchivedGroups', () async {
      final result = await _loadGroups();
      if (result.isFailure) return result;

      // Use index for faster filtering if available
      if (!_groupIndex.isEmpty) {
        return StorageResult.success(_groupIndex.getArchivedGroups());
      }

      final archivedGroups = result.data!
          .where((group) => group.archived)
          .toList();
      archivedGroups.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return StorageResult.success(archivedGroups);
    }, wasFromCache: _isCacheValid());
  }

  @override
  Future<StorageResult<ExpenseGroup?>> getGroupById(String id) async {
    return await measureOperation('getGroupById', () async {
      // Try index first for O(1) lookup
      if (!_groupIndex.isEmpty) {
        final group = _groupIndex.getById(id);
        return StorageResult.success(group);
      }

      // Fallback to loading all groups
      final result = await _loadGroups();
      if (result.isFailure) return StorageResult.failure(result.error!);

      final found = result.data!.where((group) => group.id == id);
      return StorageResult.success(found.isNotEmpty ? found.first : null);
    }, wasFromCache: _isCacheValid() && !_groupIndex.isEmpty);
  }

  @override
  Future<StorageResult<ExpenseDetails?>> getExpenseById(
    String groupId,
    String expenseId,
  ) async {
    return await measureOperation('getExpenseById', () async {
      // Try expense index first
      if (!_expenseIndex.isEmpty) {
        final location = _expenseIndex.getExpenseLocation(expenseId);
        if (location != null && location['groupId'] == groupId) {
          final group = _groupIndex.getById(groupId);
          if (group != null) {
            final expenseIndex = location['expenseIndex'] as int;
            if (expenseIndex < group.expenses.length) {
              return StorageResult.success(group.expenses[expenseIndex]);
            }
          }
        }
        return StorageResult.success(null);
      }

      // Fallback to standard lookup
      final groupResult = await getGroupById(groupId);
      if (groupResult.isFailure) {
        return StorageResult.failure(groupResult.error!);
      }

      final group = groupResult.data;
      if (group == null) {
        return StorageResult.failure(
          EntityNotFoundError('ExpenseGroup', groupId),
        );
      }

      final found = group.expenses.where((expense) => expense.id == expenseId);
      return StorageResult.success(found.isNotEmpty ? found.first : null);
    }, wasFromCache: _isCacheValid() && !_expenseIndex.isEmpty);
  }

  @override
  Future<StorageResult<ExpenseGroup?>> getPinnedGroup() async {
    return await measureOperation('getPinnedGroup', () async {
      // Use index for O(1) lookup if available
      if (!_groupIndex.isEmpty) {
        final group = _groupIndex.getPinnedGroup();
        return StorageResult.success(group);
      }

      // Fallback to filtering
      final result = await getActiveGroups();
      if (result.isFailure) return StorageResult.failure(result.error!);

      final found = result.data!.where((group) => group.pinned);
      return StorageResult.success(found.isNotEmpty ? found.first : null);
    }, wasFromCache: _isCacheValid() && !_groupIndex.isEmpty);
  }

  @override
  Future<StorageResult<void>> saveGroup(ExpenseGroup group) async {
    // Validate the group first
    final validation = validateGroup(group);
    if (validation.isFailure) {
      return validation;
    }

    final result = await _loadGroups();
    if (result.isFailure) return StorageResult.failure(result.error!);

    final groups = List<ExpenseGroup>.from(result.data!);
    final index = groups.indexWhere((g) => g.id == group.id);

    if (index != -1) {
      groups[index] = group;
    } else {
      groups.add(group);
    }

    return await _saveGroups(groups);
  }

  @override
  Future<StorageResult<void>> updateGroupMetadata(ExpenseGroup group) async {
    // Validate the group first
    final validation = validateGroup(group);
    if (validation.isFailure) {
      return validation;
    }

    final result = await _loadGroups();
    if (result.isFailure) return StorageResult.failure(result.error!);

    final groups = List<ExpenseGroup>.from(result.data!);
    final index = groups.indexWhere((g) => g.id == group.id);

    if (index == -1) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', group.id),
      );
    }

    // Preserve existing expenses when updating metadata
    final existingExpenses = groups[index].expenses;
    groups[index] = group.copyWith(expenses: existingExpenses);

    return await _saveGroups(groups);
  }

  @override
  Future<StorageResult<void>> deleteGroup(String groupId) async {
    final result = await _loadGroups();
    if (result.isFailure) return StorageResult.failure(result.error!);

    final groups = List<ExpenseGroup>.from(result.data!);
    final index = groups.indexWhere((g) => g.id == groupId);

    if (index == -1) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', groupId),
      );
    }

    groups.removeAt(index);
    return await _saveGroups(groups);
  }

  @override
  Future<StorageResult<void>> setPinnedGroup(String groupId) async {
    final result = await _loadGroups();
    if (result.isFailure) return StorageResult.failure(result.error!);

    final groups = List<ExpenseGroup>.from(result.data!);
    bool groupFound = false;

    // Atomic operation: unpin all others and pin the target
    for (int i = 0; i < groups.length; i++) {
      if (groups[i].id == groupId) {
        if (groups[i].archived) {
          return StorageResult.failure(
            ValidationError('Cannot pin an archived group'),
          );
        }
        groups[i] = groups[i].copyWith(pinned: true);
        groupFound = true;
      } else if (groups[i].pinned) {
        groups[i] = groups[i].copyWith(pinned: false);
      }
    }

    if (!groupFound) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', groupId),
      );
    }

    return await _saveGroups(groups);
  }

  @override
  Future<StorageResult<void>> removePinnedGroup(String groupId) async {
    final result = await _loadGroups();
    if (result.isFailure) return StorageResult.failure(result.error!);

    final groups = List<ExpenseGroup>.from(result.data!);
    final index = groups.indexWhere((g) => g.id == groupId);

    if (index == -1) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', groupId),
      );
    }

    if (groups[index].pinned) {
      groups[index] = groups[index].copyWith(pinned: false);
      return await _saveGroups(groups);
    }

    return const StorageResult.success(null);
  }

  @override
  Future<StorageResult<void>> archiveGroup(String groupId) async {
    final result = await _loadGroups();
    if (result.isFailure) return StorageResult.failure(result.error!);

    final groups = List<ExpenseGroup>.from(result.data!);
    final index = groups.indexWhere((g) => g.id == groupId);

    if (index == -1) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', groupId),
      );
    }

    // Archive and unpin atomically
    groups[index] = groups[index].copyWith(archived: true, pinned: false);
    return await _saveGroups(groups);
  }

  @override
  Future<StorageResult<void>> unarchiveGroup(String groupId) async {
    final result = await _loadGroups();
    if (result.isFailure) return StorageResult.failure(result.error!);

    final groups = List<ExpenseGroup>.from(result.data!);
    final index = groups.indexWhere((g) => g.id == groupId);

    if (index == -1) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', groupId),
      );
    }

    if (groups[index].archived) {
      groups[index] = groups[index].copyWith(archived: false);
      return await _saveGroups(groups);
    }

    return const StorageResult.success(null);
  }

  @override
  StorageResult<void> validateGroup(ExpenseGroup group) {
    return ExpenseGroupValidator.validate(group);
  }

  @override
  Future<StorageResult<List<String>>> checkDataIntegrity() async {
    final result = await _loadGroups(forceReload: true);
    if (result.isFailure) {
      return StorageResult.failure(result.error!);
    }

    return ExpenseGroupValidator.validateDataIntegrity(result.data!);
  }

  /// Clears the cache (useful for testing)
  void clearCache() {
    _invalidateCache();
  }

  /// Forces a reload from disk on next access
  void forceReload() {
    _invalidateCache();
  }

  /// Saves all groups atomically (for transaction support)
  Future<StorageResult<void>> saveAllGroups(List<ExpenseGroup> groups) async {
    return await _saveGroups(groups);
  }

  /// Gets groups by participant ID (indexed query)
  Future<StorageResult<List<ExpenseGroup>>> getGroupsByParticipant(
    String participantId,
  ) async {
    return await measureOperation(
      'getGroupsByParticipant',
      () async {
        await _loadGroups(); // Ensure index is loaded

        if (!_groupIndex.isEmpty) {
          final groups = _groupIndex.getGroupsByParticipant(participantId);
          return StorageResult.success(groups);
        }

        // Fallback to manual filtering
        final allResult = await getAllGroups();
        if (allResult.isFailure) return allResult;

        final groups = allResult.data!
            .where(
              (group) => group.participants.any((p) => p.id == participantId),
            )
            .toList();

        return StorageResult.success(groups);
      },
      wasFromCache: _isCacheValid() && !_groupIndex.isEmpty,
    );
  }

  /// Gets groups by category ID (indexed query)
  Future<StorageResult<List<ExpenseGroup>>> getGroupsByCategory(
    String categoryId,
  ) async {
    return await measureOperation('getGroupsByCategory', () async {
      await _loadGroups(); // Ensure index is loaded

      if (!_groupIndex.isEmpty) {
        final groups = _groupIndex.getGroupsByCategory(categoryId);
        return StorageResult.success(groups);
      }

      // Fallback to manual filtering
      final allResult = await getAllGroups();
      if (allResult.isFailure) return allResult;

      final groups = allResult.data!
          .where((group) => group.categories.any((c) => c.id == categoryId))
          .toList();

      return StorageResult.success(groups);
    }, wasFromCache: _isCacheValid() && !_groupIndex.isEmpty);
  }

  /// Gets groups by currency (indexed query)
  Future<StorageResult<List<ExpenseGroup>>> getGroupsByCurrency(
    String currency,
  ) async {
    return await measureOperation('getGroupsByCurrency', () async {
      await _loadGroups(); // Ensure index is loaded

      if (!_groupIndex.isEmpty) {
        final groups = _groupIndex.getGroupsByCurrency(currency);
        return StorageResult.success(groups);
      }

      // Fallback to manual filtering
      final allResult = await getAllGroups();
      if (allResult.isFailure) return allResult;

      final groups = allResult.data!
          .where((group) => group.currency == currency)
          .toList();

      return StorageResult.success(groups);
    }, wasFromCache: _isCacheValid() && !_groupIndex.isEmpty);
  }

  /// Searches groups by title (indexed query)
  Future<StorageResult<List<ExpenseGroup>>> searchGroupsByTitle(
    String query,
  ) async {
    return await measureOperation('searchGroupsByTitle', () async {
      await _loadGroups(); // Ensure index is loaded

      if (!_groupIndex.isEmpty) {
        final groups = _groupIndex.searchByTitle(query);
        return StorageResult.success(groups);
      }

      // Fallback to manual search
      final allResult = await getAllGroups();
      if (allResult.isFailure) return allResult;

      final lowerQuery = query.toLowerCase();
      final groups = allResult.data!
          .where((group) => group.title.toLowerCase().contains(lowerQuery))
          .toList();

      return StorageResult.success(groups);
    }, wasFromCache: _isCacheValid() && !_groupIndex.isEmpty);
  }

  /// Gets storage statistics including index information
  Map<String, dynamic> getStorageStats() {
    return {
      'cache': {
        'isValid': _isCacheValid(),
        'lastUpdate': _lastCacheUpdate?.toIso8601String(),
        'groupCount': _cachedGroups?.length ?? 0,
      },
      'groupIndex': _groupIndex.getStats(),
      'expenseIndex': _expenseIndex.getStats(),
    };
  }

  /// Validates index consistency (for debugging)
  List<String> validateIndexConsistency() {
    return _groupIndex.validateConsistency();
  }
}
