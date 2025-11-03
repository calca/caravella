// Updated wrapper for ExpenseGroupStorage - removes print statements
import '../services/logging/logger_service.dart';
import '../model/expense_group.dart';
import '../model/expense_details.dart';
import '../model/expense_participant.dart';
import '../model/expense_category.dart';
import 'expense_group_repository.dart';
import 'file_based_expense_group_repository.dart';

/// Backward-compatible wrapper for ExpenseGroupStorage
/// Maintains the same API while using the improved repository internally
class ExpenseGroupStorageV2 {
  static const String fileName = 'expense_group_storage.json';

  // Singleton repository instance
  static final IExpenseGroupRepository _repository =
      FileBasedExpenseGroupRepository();

  /// Gets a trip by ID
  static Future<ExpenseGroup?> getTripById(String id) async {
    final result = await _repository.getGroupById(id);
    return result.unwrapOr(null);
  }

  /// Gets an expense by ID within a trip
  static Future<ExpenseDetails?> getExpenseById(
    String tripId,
    String expenseId,
  ) async {
    final result = await _repository.getExpenseById(tripId, expenseId);
    return result.unwrapOr(null);
  }

  /// Returns the currently pinned trip, if exists and not archived
  static Future<ExpenseGroup?> getPinnedTrip() async {
    final result = await _repository.getPinnedGroup();
    return result.unwrapOr(null);
  }

  /// Updates the pinned state of a group. If [pinned] is true, attempts to pin
  /// the group (unpinning others). If false, removes the pin from the group.
  /// This provides a single API that callers can use to toggle pin state.
  static Future<void> updateGroupPin(String groupId, bool pinned) async {
    if (pinned) {
      final result = await _repository.setPinnedGroup(groupId);
      if (result.isFailure) {
        LoggerService.warning(
          'Failed to pin group $groupId: ${result.error}',
          name: 'storage',
        );
      }
    } else {
      final result = await _repository.removePinnedGroup(groupId);
      if (result.isFailure) {
        LoggerService.warning(
          'Failed to remove pin from group $groupId: ${result.error}',
          name: 'storage',
        );
      }
    }
  }

  /// Updates the archived state of a group. If [archived] is true, archives
  /// the group (also unpins it). If false, unarchives the group.
  static Future<void> updateGroupArchive(String groupId, bool archived) async {
    if (archived) {
      final result = await _repository.archiveGroup(groupId);
      if (result.isFailure) {
        LoggerService.warning(
          'Failed to archive group $groupId: ${result.error}',
          name: 'storage',
        );
      }
    } else {
      final result = await _repository.unarchiveGroup(groupId);
      if (result.isFailure) {
        LoggerService.warning(
          'Failed to unarchive group $groupId: ${result.error}',
          name: 'storage',
        );
      }
    }
  }

  /// Returns all archived groups sorted by timestamp (newest first)
  static Future<List<ExpenseGroup>> getArchivedGroups() async {
    final result = await _repository.getArchivedGroups();
    return result.unwrapOr([]);
  }

  /// Returns all active (non-archived) groups sorted by timestamp (newest first)
  static Future<List<ExpenseGroup>> getActiveGroups() async {
    final result = await _repository.getActiveGroups();
    return result.unwrapOr([]);
  }

  /// Returns ALL groups (including archived) sorted by timestamp (newest first)
  static Future<List<ExpenseGroup>> getAllGroups() async {
    final result = await _repository.getAllGroups();
    return result.unwrapOr([]);
  }

  /// Updates only the metadata of a group preserving existing expenses
  static Future<void> updateGroupMetadata(ExpenseGroup updatedGroup) async {
    final result = await _repository.updateGroupMetadata(updatedGroup);
    if (result.isFailure) {
      LoggerService.warning(
        'Warning: Failed to update group metadata ${updatedGroup.id}: ${result.error}',
      );
    }
  }

  /// Gets access to the underlying repository for advanced operations
  static IExpenseGroupRepository get repository => _repository;

  /// Validates a group and returns true if valid
  static bool validateGroup(ExpenseGroup group) {
    final result = _repository.validateGroup(group);
    return result.isSuccess;
  }

  /// Checks data integrity and returns a list of issues found
  static Future<List<String>> checkDataIntegrity() async {
    final result = await _repository.checkDataIntegrity();
    return result.unwrapOr([]);
  }

  /// Clears internal cache (useful for testing)
  static void clearCache() {
    if (_repository is FileBasedExpenseGroupRepository) {
      (_repository as FileBasedExpenseGroupRepository).clearCache();
    }
  }

  /// Forces reload from disk on next access
  static void forceReload() {
    if (_repository is FileBasedExpenseGroupRepository) {
      (_repository as FileBasedExpenseGroupRepository).forceReload();
    }
  }

  /// Adds a new expense to an existing expense group
  static Future<void> addExpenseToGroup(
    String groupId,
    ExpenseDetails expense,
  ) async {
    final groupResult = await _repository.getGroupById(groupId);
    if (groupResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to get group $groupId: ${groupResult.error}',
        name: 'storage',
      );
      return;
    }

    final group = groupResult.unwrapOr(null);
    if (group == null) {
      LoggerService.warning(
        'Warning: Group $groupId not found',
        name: 'storage',
      );
      return;
    }

    final updatedExpenses = List<ExpenseDetails>.from(group.expenses)
      ..add(expense);
    final updatedGroup = group.copyWith(expenses: updatedExpenses);

    final saveResult = await _repository.saveGroup(updatedGroup);
    if (saveResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to save group $groupId after adding expense: ${saveResult.error}',
      );
    }
  }

  /// Adds a whole ExpenseGroup to storage. If a group with the same id
  /// already exists it will be replaced; otherwise the group is appended.
  static Future<void> addExpenseGroup(ExpenseGroup group) async {
    final result = await _repository.addExpenseGroup(group);
    if (result.isFailure) {
      LoggerService.warning(
        'Warning: Failed to add group ${group.id}: ${result.error}',
        name: 'storage',
      );
    }
  }

  /// Returns true if the participant with [participantId] is referenced by any
  /// expense in the group identified by [groupId]. If [hintGroup] is provided
  /// it will be used as an optimization to avoid a repository read (useful for
  /// callers that already have the group loaded in memory).
  static Future<bool> isParticipantAssigned(
    String groupId,
    String participantId, [
    ExpenseGroup? hintGroup,
  ]) async {
    final group = hintGroup ?? (await getTripById(groupId));
    if (group == null) return false;
    return group.expenses.any((e) => e.paidBy.id == participantId);
  }

  /// Returns true if the category with [categoryId] is referenced by any
  /// expense in the group identified by [groupId]. Accepts an optional
  /// [hintGroup] to short-circuit a repository lookup.
  static Future<bool> isCategoryAssigned(
    String groupId,
    String categoryId, [
    ExpenseGroup? hintGroup,
  ]) async {
    final group = hintGroup ?? (await getTripById(groupId));
    if (group == null) return false;
    return group.expenses.any((e) => e.category.id == categoryId);
  }

  /// Removes a participant from the group's participants list only if it's
  /// not referenced by any expense. Returns true if the participant was
  /// removed and persisted, false otherwise.
  static Future<bool> removeParticipantIfUnused(
    String groupId,
    String participantId, [
    ExpenseGroup? hintGroup,
  ]) async {
    final group = hintGroup ?? (await getTripById(groupId));
    if (group == null) return false;

    // If the participant is still referenced by any expense, do not remove.
    final isAssigned = group.expenses.any((e) => e.paidBy.id == participantId);
    if (isAssigned) return false;

    final updatedParticipants = group.participants
        .where((p) => p.id != participantId)
        .toList();
    final updatedGroup = group.copyWith(participants: updatedParticipants);

    final saveResult = await _repository.saveGroup(updatedGroup);
    if (saveResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to save group $groupId after removing participant: ${saveResult.error}',
      );
      return false;
    }
    return true;
  }

  /// Updates an existing expense in an expense group
  static Future<void> updateExpenseToGroup(
    String groupId,
    ExpenseDetails updatedExpense,
  ) async {
    final groupResult = await _repository.getGroupById(groupId);
    if (groupResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to get group $groupId: ${groupResult.error}',
        name: 'storage',
      );
      return;
    }

    final group = groupResult.unwrapOr(null);
    if (group == null) {
      LoggerService.warning(
        'Warning: Group $groupId not found',
        name: 'storage',
      );
      return;
    }

    // Find the expense to update by its ID
    final expenseIndex = group.expenses.indexWhere(
      (expense) => expense.id == updatedExpense.id,
    );
    if (expenseIndex == -1) {
      LoggerService.warning(
        'Warning: Expense ${updatedExpense.id} not found in group $groupId',
      );
      return;
    }

    // Create updated expenses list with the modified expense
    final updatedExpenses = List<ExpenseDetails>.from(group.expenses);
    updatedExpenses[expenseIndex] = updatedExpense;

    final updatedGroup = group.copyWith(expenses: updatedExpenses);

    final saveResult = await _repository.saveGroup(updatedGroup);
    if (saveResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to save group $groupId after updating expense: ${saveResult.error}',
      );
    }
  }

  /// Compare original and updated participant lists and propagate any renames
  /// into expenses in a single repository read/save. This centralizes the
  /// logic so callers do not have to loop and call [updateParticipantReferences]
  /// repeatedly (which would load/save the group multiple times).
  static Future<void> updateParticipantReferencesFromDiff(
    String groupId,
    List<ExpenseParticipant> originalParticipants,
    List<ExpenseParticipant> updatedParticipants,
  ) async {
    // Build a map of participant id -> updated participant for those whose
    // display data changed (name or other fields). If nothing changed, return
    // early.
    final Map<String, ExpenseParticipant> changed = {};
    for (final up in updatedParticipants) {
      final orig = originalParticipants.firstWhere(
        (o) => o.id == up.id,
        orElse: () => up,
      );
      if (orig.name != up.name) {
        changed[up.id] = up.copyWith();
      }
    }
    if (changed.isEmpty) return;

    final groupResult = await _repository.getGroupById(groupId);
    if (groupResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to get group $groupId: ${groupResult.error}',
        name: 'storage',
      );
      return;
    }
    final group = groupResult.unwrapOr(null);
    if (group == null) {
      LoggerService.warning(
        'Warning: Group $groupId not found',
        name: 'storage',
      );
      return;
    }

    final updatedExpenses = group.expenses.map((e) {
      final replacement = changed[e.paidBy.id];
      if (replacement != null) {
        return e.copyWith(paidBy: replacement.copyWith());
      }
      return e;
    }).toList();

    final updatedGroup = group.copyWith(expenses: updatedExpenses);
    final saveResult = await _repository.saveGroup(updatedGroup);
    if (saveResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to save group $groupId after updating participant references: ${saveResult.error}',
      );
    }
  }

  /// Compare original and updated category lists and propagate any renames
  /// into expenses in a single repository read/save. Mirrors
  /// [updateParticipantReferencesFromDiff] semantics for categories.
  static Future<void> updateCategoryReferencesFromDiff(
    String groupId,
    List<ExpenseCategory> originalCategories,
    List<ExpenseCategory> updatedCategories,
  ) async {
    final Map<String, ExpenseCategory> changed = {};
    for (final uc in updatedCategories) {
      final oc = originalCategories.firstWhere(
        (o) => o.id == uc.id,
        orElse: () => uc,
      );
      if (oc.name != uc.name) {
        changed[uc.id] = uc.copyWith();
      }
    }
    if (changed.isEmpty) return;

    final groupResult = await _repository.getGroupById(groupId);
    if (groupResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to get group $groupId: ${groupResult.error}',
        name: 'storage',
      );
      return;
    }
    final group = groupResult.unwrapOr(null);
    if (group == null) {
      LoggerService.warning(
        'Warning: Group $groupId not found',
        name: 'storage',
      );
      return;
    }

    final updatedExpenses = group.expenses.map((e) {
      final replacement = changed[e.category.id];
      if (replacement != null) {
        return e.copyWith(category: replacement.copyWith());
      }
      return e;
    }).toList();

    final updatedGroup = group.copyWith(expenses: updatedExpenses);
    final saveResult = await _repository.saveGroup(updatedGroup);
    if (saveResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to save group $groupId after updating category references: ${saveResult.error}',
      );
    }
  }

  /// Removes a category from the group's categories list only if it's
  /// not referenced by any expense. Returns true if the category was
  /// removed and persisted, false otherwise.
  static Future<bool> removeCategoryIfUnused(
    String groupId,
    String categoryId, [
    ExpenseGroup? hintGroup,
  ]) async {
    final group = hintGroup ?? (await getTripById(groupId));
    if (group == null) return false;

    final isAssigned = group.expenses.any((e) => e.category.id == categoryId);
    if (isAssigned) return false;

    final updatedCategories = group.categories
        .where((c) => c.id != categoryId)
        .toList();
    final updatedGroup = group.copyWith(categories: updatedCategories);

    final saveResult = await _repository.saveGroup(updatedGroup);
    if (saveResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to save group $groupId after removing category: ${saveResult.error}',
      );
      return false;
    }
    return true;
  }

  /// Removes an expense from an expense group
  static Future<void> removeExpenseFromGroup(
    String groupId,
    String expenseId,
  ) async {
    final groupResult = await _repository.getGroupById(groupId);
    if (groupResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to get group $groupId: ${groupResult.error}',
      );
      return;
    }

    final group = groupResult.unwrapOr(null);
    if (group == null) {
      LoggerService.warning('Warning: Group $groupId not found');
      return;
    }

    final updatedExpenses = group.expenses
        .where((e) => e.id != expenseId)
        .toList();
    final updatedGroup = group.copyWith(expenses: updatedExpenses);

    final saveResult = await _repository.saveGroup(updatedGroup);
    if (saveResult.isFailure) {
      LoggerService.warning(
        'Warning: Failed to save group $groupId after removing expense: ${saveResult.error}',
      );
    }
  }

  /// Deletes a group by its id
  static Future<void> deleteGroup(String groupId) async {
    final result = await _repository.deleteGroup(groupId);
    if (result.isFailure) {
      LoggerService.warning(
        'Warning: Failed to delete group $groupId: ${result.error}',
      );
    }
  }
}
