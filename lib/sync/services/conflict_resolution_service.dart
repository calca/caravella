import '../../data/services/logger_service.dart';
import '../../data/model/expense_details.dart';
import '../../data/model/expense_group.dart';

/// Strategy for resolving conflicts
enum ConflictResolutionStrategy {
  /// Last write wins (default)
  lastWriteWins,
  
  /// First write wins
  firstWriteWins,
  
  /// Manual resolution required
  manual,
  
  /// Merge changes automatically
  autoMerge,
}

/// Represents a conflict between two versions of data
class DataConflict<T> {
  final T local;
  final T remote;
  final DateTime localTimestamp;
  final DateTime remoteTimestamp;
  final String conflictType;

  DataConflict({
    required this.local,
    required this.remote,
    required this.localTimestamp,
    required this.remoteTimestamp,
    required this.conflictType,
  });
}

/// Service for handling sync conflicts
class ConflictResolutionService {
  static final ConflictResolutionService _instance =
      ConflictResolutionService._internal();
  factory ConflictResolutionService() => _instance;
  ConflictResolutionService._internal();

  ConflictResolutionStrategy _strategy = ConflictResolutionStrategy.lastWriteWins;

  /// Set the conflict resolution strategy
  void setStrategy(ConflictResolutionStrategy strategy) {
    _strategy = strategy;
    LoggerService.info('Conflict resolution strategy set to: ${strategy.name}');
  }

  /// Get current strategy
  ConflictResolutionStrategy get strategy => _strategy;

  /// Resolve a conflict between two expense versions
  ExpenseDetails? resolveExpenseConflict(DataConflict<ExpenseDetails> conflict) {
    switch (_strategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        return _lastWriteWins(conflict);
      case ConflictResolutionStrategy.firstWriteWins:
        return _firstWriteWins(conflict);
      case ConflictResolutionStrategy.autoMerge:
        return _autoMergeExpense(conflict);
      case ConflictResolutionStrategy.manual:
        // Store for manual resolution
        _storeForManualResolution(conflict);
        return null;
    }
  }

  /// Resolve a conflict between two group versions
  ExpenseGroup? resolveGroupConflict(DataConflict<ExpenseGroup> conflict) {
    switch (_strategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        return _lastWriteWins(conflict);
      case ConflictResolutionStrategy.firstWriteWins:
        return _firstWriteWins(conflict);
      case ConflictResolutionStrategy.autoMerge:
        return _autoMergeGroup(conflict);
      case ConflictResolutionStrategy.manual:
        // Store for manual resolution
        _storeForManualResolution(conflict);
        return null;
    }
  }

  /// Last write wins strategy
  T _lastWriteWins<T>(DataConflict<T> conflict) {
    if (conflict.remoteTimestamp.isAfter(conflict.localTimestamp)) {
      LoggerService.info('Conflict resolved: using remote (newer)');
      return conflict.remote;
    } else {
      LoggerService.info('Conflict resolved: keeping local (newer)');
      return conflict.local;
    }
  }

  /// First write wins strategy
  T _firstWriteWins<T>(DataConflict<T> conflict) {
    if (conflict.localTimestamp.isBefore(conflict.remoteTimestamp)) {
      LoggerService.info('Conflict resolved: keeping local (older)');
      return conflict.local;
    } else {
      LoggerService.info('Conflict resolved: using remote (older)');
      return conflict.remote;
    }
  }

  /// Auto-merge expenses - combine non-conflicting changes
  ExpenseDetails? _autoMergeExpense(DataConflict<ExpenseDetails> conflict) {
    try {
      final local = conflict.local;
      final remote = conflict.remote;

      // Check if they're fundamentally different
      if (local.id != remote.id) {
        LoggerService.warning('Cannot merge: different IDs');
        return _lastWriteWins(conflict);
      }

      // Merge strategy: use newest value for each field
      final merged = ExpenseDetails(
        id: local.id,
        title: conflict.remoteTimestamp.isAfter(conflict.localTimestamp)
            ? remote.title
            : local.title,
        amount: conflict.remoteTimestamp.isAfter(conflict.localTimestamp)
            ? remote.amount
            : local.amount,
        paidBy: conflict.remoteTimestamp.isAfter(conflict.localTimestamp)
            ? remote.paidBy
            : local.paidBy,
        participants: _mergeParticipants(local.participants, remote.participants),
        date: conflict.remoteTimestamp.isAfter(conflict.localTimestamp)
            ? remote.date
            : local.date,
        category: conflict.remoteTimestamp.isAfter(conflict.localTimestamp)
            ? remote.category
            : local.category,
        notes: _mergeNotes(local.notes, remote.notes),
        location: remote.location ?? local.location,
      );

      LoggerService.info('Conflict resolved: auto-merged expense');
      return merged;
    } catch (e) {
      LoggerService.error('Failed to auto-merge expense: $e');
      return _lastWriteWins(conflict);
    }
  }

  /// Auto-merge groups - combine non-conflicting changes
  ExpenseGroup? _autoMergeGroup(DataConflict<ExpenseGroup> conflict) {
    try {
      final local = conflict.local;
      final remote = conflict.remote;

      if (local.id != remote.id) {
        LoggerService.warning('Cannot merge: different group IDs');
        return _lastWriteWins(conflict);
      }

      // Merge expenses by combining both lists and removing duplicates
      final Map<String, ExpenseDetails> expenseMap = {};
      for (final expense in local.expenses) {
        expenseMap[expense.id] = expense;
      }
      for (final expense in remote.expenses) {
        if (!expenseMap.containsKey(expense.id)) {
          expenseMap[expense.id] = expense;
        } else {
          // If expense exists in both, resolve conflict
          final localExp = expenseMap[expense.id]!;
          final conflict = DataConflict<ExpenseDetails>(
            local: localExp,
            remote: expense,
            localTimestamp: conflict.localTimestamp,
            remoteTimestamp: conflict.remoteTimestamp,
            conflictType: 'expense',
          );
          final resolved = resolveExpenseConflict(conflict);
          if (resolved != null) {
            expenseMap[expense.id] = resolved;
          }
        }
      }

      final merged = local.copyWith(
        expenses: expenseMap.values.toList(),
        participants: _mergeUniqueParticipants(local.participants, remote.participants),
        categories: _mergeUniqueCategories(local.categories, remote.categories),
      );

      LoggerService.info('Conflict resolved: auto-merged group');
      return merged;
    } catch (e) {
      LoggerService.error('Failed to auto-merge group: $e');
      return _lastWriteWins(conflict);
    }
  }

  /// Merge participant lists
  List<dynamic> _mergeParticipants(List<dynamic> local, List<dynamic> remote) {
    final Set<String> seen = {};
    final List<dynamic> merged = [];

    for (final p in [...local, ...remote]) {
      final id = p.id as String;
      if (!seen.contains(id)) {
        seen.add(id);
        merged.add(p);
      }
    }

    return merged;
  }

  /// Merge unique participants (for group)
  List<dynamic> _mergeUniqueParticipants(List<dynamic> local, List<dynamic> remote) {
    return _mergeParticipants(local, remote);
  }

  /// Merge unique categories
  List<dynamic> _mergeUniqueCategories(List<dynamic> local, List<dynamic> remote) {
    final Set<String> seen = {};
    final List<dynamic> merged = [];

    for (final c in [...local, ...remote]) {
      final name = c.name as String;
      if (!seen.contains(name)) {
        seen.add(name);
        merged.add(c);
      }
    }

    return merged;
  }

  /// Merge notes - append remote notes if different
  String _mergeNotes(String local, String remote) {
    if (local.isEmpty) return remote;
    if (remote.isEmpty) return local;
    if (local == remote) return local;
    
    return '$local\n\n[Merged from other device]\n$remote';
  }

  /// Store conflict for manual resolution
  void _storeForManualResolution<T>(DataConflict<T> conflict) {
    LoggerService.warning(
      'Conflict requires manual resolution: ${conflict.conflictType}',
    );
    // In a real implementation, store in persistent storage
    // and notify user to resolve manually
  }

  /// Get pending conflicts that need manual resolution
  Future<List<DataConflict>> getPendingConflicts() async {
    // In a real implementation, retrieve from storage
    return [];
  }

  /// Mark a conflict as resolved
  Future<void> markResolved(String conflictId) async {
    // In a real implementation, remove from storage
    LoggerService.info('Conflict marked as resolved: $conflictId');
  }
}
