import '../model/expense_group.dart';
import '../model/expense_details.dart';
import 'storage_errors.dart';

/// Result wrapper for storage operations that can fail
class StorageResult<T> {
  final T? data;
  final StorageError? error;

  const StorageResult.success(this.data) : error = null;
  const StorageResult.failure(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  /// Throws the error if this is a failure, otherwise returns the data
  T unwrap() {
    if (error != null) {
      throw error!;
    }
    // At this point data may still be null if T is nullable; caller responsibility.
    return data as T;
  }

  /// Returns the data if success, otherwise returns the fallback value
  T unwrapOr(T fallback) {
    return data ?? fallback;
  }

  /// Maps the success value to a new type
  StorageResult<U> map<U>(U Function(T) transform) {
    if (isFailure) return StorageResult.failure(error!);
    final value = data;
    return StorageResult.success(transform(value as T));
  }
}

/// Interface for expense group repository operations
/// This abstracts storage concerns and enables better testing
abstract class IExpenseGroupRepository {
  /// Gets all groups (active and archived), sorted by timestamp (newest first)
  Future<StorageResult<List<ExpenseGroup>>> getAllGroups();

  /// Gets all active (non-archived) groups, sorted by timestamp (newest first)
  Future<StorageResult<List<ExpenseGroup>>> getActiveGroups();

  /// Gets all archived groups, sorted by timestamp (newest first)
  Future<StorageResult<List<ExpenseGroup>>> getArchivedGroups();

  /// Gets a specific group by ID
  Future<StorageResult<ExpenseGroup?>> getGroupById(String id);

  /// Gets a specific expense within a group
  Future<StorageResult<ExpenseDetails?>> getExpenseById(
    String groupId,
    String expenseId,
  );

  /// Gets the currently pinned group (if any)
  Future<StorageResult<ExpenseGroup?>> getPinnedGroup();

  /// Saves a group (create or update)
  Future<StorageResult<void>> saveGroup(ExpenseGroup group);

  /// Adds a group to storage (append or replace existing with same id).
  /// This is a convenience API that preserves the current behavior of
  /// replacing an existing group with the same id.
  Future<StorageResult<void>> addExpenseGroup(ExpenseGroup group);

  /// Updates only the metadata of a group, preserving expenses
  Future<StorageResult<void>> updateGroupMetadata(ExpenseGroup group);

  /// Deletes a group completely
  Future<StorageResult<void>> deleteGroup(String groupId);

  /// Sets a group as pinned (unpins all others)
  Future<StorageResult<void>> setPinnedGroup(String groupId);

  /// Removes the pin from a group
  Future<StorageResult<void>> removePinnedGroup(String groupId);

  /// Archives a group (also unpins it)
  Future<StorageResult<void>> archiveGroup(String groupId);

  /// Unarchives a group
  Future<StorageResult<void>> unarchiveGroup(String groupId);

  /// Validates that a group is consistent and valid
  StorageResult<void> validateGroup(ExpenseGroup group);

  /// Checks data integrity across all groups
  Future<StorageResult<List<String>>> checkDataIntegrity();
}

/// Validation helper for expense groups
class ExpenseGroupValidator {
  static StorageResult<void> validate(ExpenseGroup group) {
    final errors = <String, String>{};

    // Basic field validation
    if (group.title.trim().isEmpty) {
      errors['title'] = 'Title cannot be empty';
    }

    if (group.currency.trim().isEmpty) {
      errors['currency'] = 'Currency cannot be empty';
    }

    // Date validation
    if (group.startDate != null && group.endDate != null) {
      if (group.startDate!.isAfter(group.endDate!)) {
        errors['dates'] = 'Start date cannot be after end date';
      }
    }

    // Participant validation
    final participantIds = group.participants.map((p) => p.id).toSet();
    if (participantIds.length != group.participants.length) {
      errors['participants'] = 'Duplicate participant IDs found';
    }

    for (final participant in group.participants) {
      if (participant.name.trim().isEmpty) {
        errors['participants'] = 'Participant names cannot be empty';
        break;
      }
    }

    // Category validation
    final categoryIds = group.categories.map((c) => c.id).toSet();
    if (categoryIds.length != group.categories.length) {
      errors['categories'] = 'Duplicate category IDs found';
    }

    // Expense validation
    for (int i = 0; i < group.expenses.length; i++) {
      final expense = group.expenses[i];

      if (expense.amount == null || expense.amount! <= 0) {
        errors['expense_$i'] = 'Expense amount must be positive';
      }

      if (!participantIds.contains(expense.paidBy.id)) {
        errors['expense_$i'] =
            'Expense paidBy refers to non-existent participant';
      }

      if (!categoryIds.contains(expense.category.id)) {
        errors['expense_$i'] =
            'Expense category refers to non-existent category';
      }
    }

    if (errors.isNotEmpty) {
      return StorageResult.failure(
        ValidationError('Group validation failed', fieldErrors: errors),
      );
    }

    return const StorageResult.success(null);
  }

  /// Validates data integrity across multiple groups
  static StorageResult<List<String>> validateDataIntegrity(
    List<ExpenseGroup> groups,
  ) {
    final issues = <String>[];

    // Check for duplicate group IDs
    final groupIds = groups.map((g) => g.id).toSet();
    if (groupIds.length != groups.length) {
      issues.add('Duplicate group IDs found');
    }

    // Check pin constraint (only one group can be pinned)
    final pinnedGroups = groups.where((g) => g.pinned && !g.archived).toList();
    if (pinnedGroups.length > 1) {
      issues.add(
        'Multiple groups are pinned: ${pinnedGroups.map((g) => g.title).join(', ')}',
      );
    }

    // Validate individual groups
    for (final group in groups) {
      final validation = validate(group);
      if (validation.isFailure) {
        issues.add(
          'Group "${group.title}" (${group.id}): ${validation.error!.message}',
        );
      }
    }

    if (issues.isEmpty) {
      return StorageResult.success(issues);
    } else {
      return StorageResult.failure(
        DataIntegrityError(
          'Data integrity validation failed',
          details: issues.join('; '),
        ),
      );
    }
  }
}
