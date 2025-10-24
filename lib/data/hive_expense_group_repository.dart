import 'package:hive_flutter/hive_flutter.dart';
import 'model/expense_group.dart';
import 'model/expense_details.dart';
import 'expense_group_repository.dart';
import 'storage_errors.dart';
import 'storage_performance.dart';
import 'storage_index.dart';

/// Hive-based implementation of ExpenseGroupRepository for better performance
class HiveExpenseGroupRepository
    with PerformanceMonitoring
    implements IExpenseGroupRepository {
  static const String boxName = 'expense_groups';
  
  // Indexes for fast lookups
  final GroupIndex _groupIndex = GroupIndex();
  final ExpenseIndex _expenseIndex = ExpenseIndex();
  
  // Cached box reference
  Box<ExpenseGroup>? _box;
  
  /// Gets or opens the Hive box
  Future<Box<ExpenseGroup>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    try {
      _box = await Hive.openBox<ExpenseGroup>(boxName);
      return _box!;
    } catch (e) {
      throw FileOperationError(
        'Failed to open Hive box',
        details: e.toString(),
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
  
  /// Loads all groups from Hive and updates indexes
  Future<StorageResult<List<ExpenseGroup>>> _loadGroups() async {
    return await measureOperation(
      'hive_loadGroups',
      () async {
        try {
          final box = await _getBox();
          final groups = box.values.toList();
          
          // Update indexes
          _groupIndex.clear();
          _expenseIndex.clear();
          for (final group in groups) {
            _groupIndex.add(group);
            for (final expense in group.expenses) {
              _expenseIndex.add(group.id, expense);
            }
          }
          
          return StorageResult.success(groups);
        } catch (e) {
          return StorageResult.failure(
            FileOperationError(
              'Failed to load groups from Hive',
              details: e.toString(),
              cause: e is Exception ? e : Exception(e.toString()),
            ),
          );
        }
      },
    );
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getAllGroups() async {
    final result = await _loadGroups();
    if (result.isFailure) return result;
    
    final groups = result.data!;
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return StorageResult.success(groups);
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getActiveGroups() async {
    final result = await _loadGroups();
    if (result.isFailure) return result;
    
    final groups = result.data!
        .where((g) => !g.archived)
        .toList();
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return StorageResult.success(groups);
  }

  @override
  Future<StorageResult<List<ExpenseGroup>>> getArchivedGroups() async {
    final result = await _loadGroups();
    if (result.isFailure) return result;
    
    final groups = result.data!
        .where((g) => g.archived)
        .toList();
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return StorageResult.success(groups);
  }

  @override
  Future<StorageResult<ExpenseGroup?>> getGroupById(String id) async {
    return await measureOperation(
      'hive_getGroupById',
      () async {
        try {
          final box = await _getBox();
          final group = box.get(id);
          return StorageResult.success(group);
        } catch (e) {
          return StorageResult.failure(
            FileOperationError(
              'Failed to get group by id from Hive',
              details: e.toString(),
              cause: e is Exception ? e : Exception(e.toString()),
            ),
          );
        }
      },
    );
  }

  @override
  Future<StorageResult<ExpenseDetails?>> getExpenseById(
    String groupId,
    String expenseId,
  ) async {
    final groupResult = await getGroupById(groupId);
    if (groupResult.isFailure) return StorageResult.failure(groupResult.error!);
    
    final group = groupResult.data;
    if (group == null) {
      return const StorageResult.success(null);
    }
    
    try {
      final expense = group.expenses.firstWhere(
        (e) => e.id == expenseId,
        orElse: () => throw Exception('Expense not found'),
      );
      return StorageResult.success(expense);
    } catch (e) {
      return const StorageResult.success(null);
    }
  }

  @override
  Future<StorageResult<ExpenseGroup?>> getPinnedGroup() async {
    final result = await _loadGroups();
    if (result.isFailure) return StorageResult.failure(result.error!);
    
    try {
      final pinnedGroup = result.data!.firstWhere(
        (g) => g.pinned && !g.archived,
        orElse: () => throw Exception('No pinned group'),
      );
      return StorageResult.success(pinnedGroup);
    } catch (e) {
      return const StorageResult.success(null);
    }
  }

  @override
  Future<StorageResult<void>> saveGroup(ExpenseGroup group) async {
    return await measureOperation(
      'hive_saveGroup',
      () async {
        // Validate first
        final validation = validateGroup(group);
        if (validation.isFailure) return validation;
        
        try {
          final box = await _getBox();
          await box.put(group.id, group);
          
          // Update indexes
          _groupIndex.add(group);
          _expenseIndex.clear();
          for (final expense in group.expenses) {
            _expenseIndex.add(group.id, expense);
          }
          
          return const StorageResult.success(null);
        } catch (e) {
          return StorageResult.failure(
            FileOperationError(
              'Failed to save group to Hive',
              details: e.toString(),
              cause: e is Exception ? e : Exception(e.toString()),
            ),
          );
        }
      },
    );
  }

  @override
  Future<StorageResult<void>> addExpenseGroup(ExpenseGroup group) async {
    return await saveGroup(group);
  }

  @override
  Future<StorageResult<void>> updateGroupMetadata(ExpenseGroup group) async {
    final existingResult = await getGroupById(group.id);
    if (existingResult.isFailure) return StorageResult.failure(existingResult.error!);
    
    final existing = existingResult.data;
    if (existing == null) {
      return StorageResult.failure(
        DataNotFoundError('Group ${group.id} not found'),
      );
    }
    
    final updated = group.copyWith(expenses: existing.expenses);
    return await saveGroup(updated);
  }

  @override
  Future<StorageResult<void>> deleteGroup(String groupId) async {
    return await measureOperation(
      'hive_deleteGroup',
      () async {
        try {
          final box = await _getBox();
          await box.delete(groupId);
          
          // Update indexes
          _groupIndex.remove(groupId);
          _expenseIndex.removeGroup(groupId);
          
          return const StorageResult.success(null);
        } catch (e) {
          return StorageResult.failure(
            FileOperationError(
              'Failed to delete group from Hive',
              details: e.toString(),
              cause: e is Exception ? e : Exception(e.toString()),
            ),
          );
        }
      },
    );
  }

  @override
  Future<StorageResult<void>> setPinnedGroup(String groupId) async {
    final result = await _loadGroups();
    if (result.isFailure) return StorageResult.failure(result.error!);
    
    final groups = result.data!;
    
    // Find the group to pin
    final groupIndex = groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) {
      return StorageResult.failure(
        DataNotFoundError('Group $groupId not found'),
      );
    }
    
    // Cannot pin archived groups
    if (groups[groupIndex].archived) {
      return StorageResult.failure(
        ValidationError('Cannot pin an archived group'),
      );
    }
    
    try {
      final box = await _getBox();
      
      // Unpin all others
      for (var i = 0; i < groups.length; i++) {
        if (groups[i].pinned && i != groupIndex) {
          final updated = groups[i].copyWith(pinned: false);
          await box.put(updated.id, updated);
        }
      }
      
      // Pin the target
      final updated = groups[groupIndex].copyWith(pinned: true);
      await box.put(updated.id, updated);
      
      return const StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        FileOperationError(
          'Failed to set pinned group',
          details: e.toString(),
          cause: e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  @override
  Future<StorageResult<void>> removePinnedGroup(String groupId) async {
    final groupResult = await getGroupById(groupId);
    if (groupResult.isFailure) return StorageResult.failure(groupResult.error!);
    
    final group = groupResult.data;
    if (group == null) {
      return StorageResult.failure(
        DataNotFoundError('Group $groupId not found'),
      );
    }
    
    if (!group.pinned) {
      return const StorageResult.success(null);
    }
    
    final updated = group.copyWith(pinned: false);
    return await saveGroup(updated);
  }

  @override
  Future<StorageResult<void>> archiveGroup(String groupId) async {
    final groupResult = await getGroupById(groupId);
    if (groupResult.isFailure) return StorageResult.failure(groupResult.error!);
    
    final group = groupResult.data;
    if (group == null) {
      return StorageResult.failure(
        DataNotFoundError('Group $groupId not found'),
      );
    }
    
    final updated = group.copyWith(archived: true, pinned: false);
    return await saveGroup(updated);
  }

  @override
  Future<StorageResult<void>> unarchiveGroup(String groupId) async {
    final groupResult = await getGroupById(groupId);
    if (groupResult.isFailure) return StorageResult.failure(groupResult.error!);
    
    final group = groupResult.data;
    if (group == null) {
      return StorageResult.failure(
        DataNotFoundError('Group $groupId not found'),
      );
    }
    
    final updated = group.copyWith(archived: false);
    return await saveGroup(updated);
  }

  @override
  StorageResult<void> validateGroup(ExpenseGroup group) {
    return ExpenseGroupValidator.validate(group);
  }

  @override
  Future<StorageResult<List<String>>> checkDataIntegrity() async {
    final result = await _loadGroups();
    if (result.isFailure) {
      return StorageResult.failure(result.error!);
    }
    
    return ExpenseGroupValidator.validateDataIntegrity(result.data!);
  }
  
  /// Clears internal cache and indexes
  void clearCache() {
    _groupIndex.clear();
    _expenseIndex.clear();
  }
  
  /// Forces reload from Hive on next access
  void forceReload() {
    clearCache();
  }
  
  /// Closes the Hive box
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}
