import 'expense_group.dart';
import 'expense_group_repository.dart';
import 'storage_errors.dart';
import 'file_based_expense_group_repository.dart';
import 'package:flutter/foundation.dart';

/// Represents a batch of operations that should be executed atomically
class StorageTransaction {
  final List<TransactionOperation> _operations = [];
  bool _isExecuted = false;

  /// Adds a save operation to the transaction
  void saveGroup(ExpenseGroup group) {
    _checkNotExecuted();
    _operations.add(_SaveOperation(group));
  }

  /// Adds a delete operation to the transaction
  void deleteGroup(String groupId) {
    _checkNotExecuted();
    _operations.add(_DeleteOperation(groupId));
  }

  /// Adds a pin operation to the transaction
  void setPinnedGroup(String groupId) {
    _checkNotExecuted();
    _operations.add(_SetPinnedOperation(groupId));
  }

  /// Adds an unpin operation to the transaction
  void removePinnedGroup(String groupId) {
    _checkNotExecuted();
    _operations.add(_RemovePinnedOperation(groupId));
  }

  /// Adds an archive operation to the transaction
  void archiveGroup(String groupId) {
    _checkNotExecuted();
    _operations.add(_ArchiveOperation(groupId));
  }

  /// Adds an unarchive operation to the transaction
  void unarchiveGroup(String groupId) {
    _checkNotExecuted();
    _operations.add(_UnarchiveOperation(groupId));
  }

  /// Adds a metadata update operation to the transaction
  void updateGroupMetadata(ExpenseGroup group) {
    _checkNotExecuted();
    _operations.add(_UpdateMetadataOperation(group));
  }

  void _checkNotExecuted() {
    if (_isExecuted) {
      throw StateError('Transaction has already been executed');
    }
  }

  /// Number of operations in this transaction
  int get operationCount => _operations.length;

  /// Whether this transaction is empty
  bool get isEmpty => _operations.isEmpty;

  /// Whether this transaction has been executed
  bool get isExecuted => _isExecuted;

  /// Mark as executed (internal use)
  void _markExecuted() {
    _isExecuted = true;
  }

  /// Test helper to simulate an already executed transaction
  @visibleForTesting
  void markExecutedForTest() => _markExecuted();

  /// Get operations (internal use)
  List<TransactionOperation> get operations => List.unmodifiable(_operations);
}

/// Base class for transaction operations
abstract class TransactionOperation {
  Future<StorageResult<void>> execute(
    IExpenseGroupRepository repository,
    List<ExpenseGroup> currentGroups,
  );

  /// Returns the group ID this operation affects, if any
  String? get affectedGroupId;
}

class _SaveOperation extends TransactionOperation {
  final ExpenseGroup group;

  _SaveOperation(this.group);

  @override
  Future<StorageResult<void>> execute(
    IExpenseGroupRepository repository,
    List<ExpenseGroup> currentGroups,
  ) async {
    // Validation is handled by the repository
    return const StorageResult.success(null);
  }

  @override
  String get affectedGroupId => group.id;
}

class _DeleteOperation extends TransactionOperation {
  final String groupId;

  _DeleteOperation(this.groupId);

  @override
  Future<StorageResult<void>> execute(
    IExpenseGroupRepository repository,
    List<ExpenseGroup> currentGroups,
  ) async {
    final exists = currentGroups.any((g) => g.id == groupId);
    if (!exists) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', groupId),
      );
    }
    return const StorageResult.success(null);
  }

  @override
  String get affectedGroupId => groupId;
}

class _SetPinnedOperation extends TransactionOperation {
  final String groupId;

  _SetPinnedOperation(this.groupId);

  @override
  Future<StorageResult<void>> execute(
    IExpenseGroupRepository repository,
    List<ExpenseGroup> currentGroups,
  ) async {
    final groupList = currentGroups.where((g) => g.id == groupId);
    final group = groupList.isNotEmpty ? groupList.first : null;
    if (group == null) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', groupId),
      );
    }

    if (group.archived) {
      return StorageResult.failure(
        ValidationError('Cannot pin an archived group'),
      );
    }

    return const StorageResult.success(null);
  }

  @override
  String get affectedGroupId => groupId;
}

class _RemovePinnedOperation extends TransactionOperation {
  final String groupId;

  _RemovePinnedOperation(this.groupId);

  @override
  Future<StorageResult<void>> execute(
    IExpenseGroupRepository repository,
    List<ExpenseGroup> currentGroups,
  ) async {
    final exists = currentGroups.any((g) => g.id == groupId);
    if (!exists) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', groupId),
      );
    }
    return const StorageResult.success(null);
  }

  @override
  String get affectedGroupId => groupId;
}

class _ArchiveOperation extends TransactionOperation {
  final String groupId;

  _ArchiveOperation(this.groupId);

  @override
  Future<StorageResult<void>> execute(
    IExpenseGroupRepository repository,
    List<ExpenseGroup> currentGroups,
  ) async {
    final exists = currentGroups.any((g) => g.id == groupId);
    if (!exists) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', groupId),
      );
    }
    return const StorageResult.success(null);
  }

  @override
  String get affectedGroupId => groupId;
}

class _UnarchiveOperation extends TransactionOperation {
  final String groupId;

  _UnarchiveOperation(this.groupId);

  @override
  Future<StorageResult<void>> execute(
    IExpenseGroupRepository repository,
    List<ExpenseGroup> currentGroups,
  ) async {
    final exists = currentGroups.any((g) => g.id == groupId);
    if (!exists) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', groupId),
      );
    }
    return const StorageResult.success(null);
  }

  @override
  String get affectedGroupId => groupId;
}

class _UpdateMetadataOperation extends TransactionOperation {
  final ExpenseGroup group;

  _UpdateMetadataOperation(this.group);

  @override
  Future<StorageResult<void>> execute(
    IExpenseGroupRepository repository,
    List<ExpenseGroup> currentGroups,
  ) async {
    final exists = currentGroups.any((g) => g.id == group.id);
    if (!exists) {
      return StorageResult.failure(
        EntityNotFoundError('ExpenseGroup', group.id),
      );
    }
    return const StorageResult.success(null);
  }

  @override
  String get affectedGroupId => group.id;
}

/// Transaction executor that handles atomic operations
class TransactionExecutor {
  final IExpenseGroupRepository _repository;

  TransactionExecutor(this._repository);

  /// Executes a transaction atomically
  Future<StorageResult<void>> execute(StorageTransaction transaction) async {
    if (transaction.isExecuted) {
      return StorageResult.failure(
        ValidationError('Transaction has already been executed'),
      );
    }

    if (transaction.isEmpty) {
      transaction._markExecuted();
      return const StorageResult.success(null);
    }

    try {
      // Load current state
      final currentGroupsResult = await _repository.getAllGroups();
      if (currentGroupsResult.isFailure) {
        return StorageResult.failure(currentGroupsResult.error!);
      }

      List<ExpenseGroup> workingGroups = List.from(currentGroupsResult.data!);

      // Validate all operations first
      for (final operation in transaction.operations) {
        final validationResult = await operation.execute(
          _repository,
          workingGroups,
        );
        if (validationResult.isFailure) {
          return validationResult;
        }
      }

      // Apply all operations to working set
      for (final operation in transaction.operations) {
        workingGroups = _applyOperation(operation, workingGroups);
      }

      // Validate final state
      final integrityResult = ExpenseGroupValidator.validateDataIntegrity(
        workingGroups,
      );
      if (integrityResult.isFailure) {
        return StorageResult.failure(
          DataIntegrityError(
            'Transaction would violate data integrity',
            details: integrityResult.error!.message,
          ),
        );
      }

      // Save the final state (this is the atomic commit point)
      final saveResult = await _saveAllGroups(workingGroups);
      if (saveResult.isFailure) {
        return saveResult;
      }

      transaction._markExecuted();
      return const StorageResult.success(null);
    } catch (e) {
      return StorageResult.failure(
        FileOperationError(
          'Transaction execution failed',
          details: e.toString(),
          cause: e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  /// Applies a single operation to the working group list
  List<ExpenseGroup> _applyOperation(
    TransactionOperation operation,
    List<ExpenseGroup> groups,
  ) {
    final workingGroups = List<ExpenseGroup>.from(groups);

    if (operation is _SaveOperation) {
      final index = workingGroups.indexWhere((g) => g.id == operation.group.id);
      if (index != -1) {
        workingGroups[index] = operation.group;
      } else {
        workingGroups.add(operation.group);
      }
    } else if (operation is _DeleteOperation) {
      workingGroups.removeWhere((g) => g.id == operation.groupId);
    } else if (operation is _SetPinnedOperation) {
      // Unpin all others and pin the target
      for (int i = 0; i < workingGroups.length; i++) {
        if (workingGroups[i].id == operation.groupId) {
          workingGroups[i] = workingGroups[i].copyWith(pinned: true);
        } else if (workingGroups[i].pinned) {
          workingGroups[i] = workingGroups[i].copyWith(pinned: false);
        }
      }
    } else if (operation is _RemovePinnedOperation) {
      final index = workingGroups.indexWhere((g) => g.id == operation.groupId);
      if (index != -1 && workingGroups[index].pinned) {
        workingGroups[index] = workingGroups[index].copyWith(pinned: false);
      }
    } else if (operation is _ArchiveOperation) {
      final index = workingGroups.indexWhere((g) => g.id == operation.groupId);
      if (index != -1) {
        workingGroups[index] = workingGroups[index].copyWith(
          archived: true,
          pinned: false,
        );
      }
    } else if (operation is _UnarchiveOperation) {
      final index = workingGroups.indexWhere((g) => g.id == operation.groupId);
      if (index != -1 && workingGroups[index].archived) {
        workingGroups[index] = workingGroups[index].copyWith(archived: false);
      }
    } else if (operation is _UpdateMetadataOperation) {
      final index = workingGroups.indexWhere((g) => g.id == operation.group.id);
      if (index != -1) {
        // Preserve existing expenses when updating metadata
        final existingExpenses = workingGroups[index].expenses;
        workingGroups[index] = operation.group.copyWith(
          expenses: existingExpenses,
        );
      }
    }

    return workingGroups;
  }

  /// Saves all groups atomically (delegates to repository implementation)
  Future<StorageResult<void>> _saveAllGroups(List<ExpenseGroup> groups) async {
    // For file-based storage, this involves a single file write
    // which is atomic at the filesystem level
    if (_repository is FileBasedExpenseGroupRepository) {
      // ignore: unnecessary_cast
      final repo = _repository as FileBasedExpenseGroupRepository;
      return await repo.saveAllGroups(groups);
    } else {
      // Fallback for other implementations
      for (final group in groups) {
        final result = await _repository.saveGroup(group);
        if (result.isFailure) return result;
      }
      return const StorageResult.success(null);
    }
  }
}

/// Extension to add transaction support to repositories
extension TransactionalRepository on IExpenseGroupRepository {
  /// Executes a transaction atomically
  Future<StorageResult<void>> executeTransaction(
    void Function(StorageTransaction) transactionBuilder,
  ) async {
    final transaction = StorageTransaction();
    transactionBuilder(transaction);

    final executor = TransactionExecutor(this);
    return await executor.execute(transaction);
  }
}
