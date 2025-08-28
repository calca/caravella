// ignore_for_file: avoid_print, unused_element, unnecessary_brace_in_string_interps
import 'model/expense_group.dart';
import 'model/expense_details.dart';
import 'expense_group_repository.dart';
import 'file_based_expense_group_repository.dart';

/// Backward-compatible wrapper for ExpenseGroupStorage
/// Maintains the same API while using the improved repository internally
class ExpenseGroupStorageV2 {
  static const String fileName = 'expense_group_storage.json';

  // Singleton repository instance
  static final IExpenseGroupRepository _repository =
      FileBasedExpenseGroupRepository();

  /// Private method to read all groups (for internal use)
  static Future<List<ExpenseGroup>> _readAllGroups() async {
    final result = await _repository.getAllGroups();
    return result.unwrapOr([]);
  }

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
        print('Warning: Failed to pin group $groupId: ${result.error}');
      }
    } else {
      final result = await _repository.removePinnedGroup(groupId);
      if (result.isFailure) {
        print(
          'Warning: Failed to remove pin from group $groupId: ${result.error}',
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
        print('Warning: Failed to archive group $groupId: ${result.error}');
      }
    } else {
      final result = await _repository.unarchiveGroup(groupId);
      if (result.isFailure) {
        print('Warning: Failed to unarchive group $groupId: ${result.error}');
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
      print(
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
      print('Warning: Failed to get group $groupId: ${groupResult.error}');
      return;
    }

    final group = groupResult.unwrapOr(null);
    if (group == null) {
      print('Warning: Group $groupId not found');
      return;
    }

    final updatedExpenses = List<ExpenseDetails>.from(group.expenses)
      ..add(expense);
    final updatedGroup = group.copyWith(expenses: updatedExpenses);

    final saveResult = await _repository.saveGroup(updatedGroup);
    if (saveResult.isFailure) {
      print(
        'Warning: Failed to save group $groupId after adding expense: ${saveResult.error}',
      );
    }
  }

  /// Adds a whole ExpenseGroup to storage. If a group with the same id
  /// already exists it will be replaced; otherwise the group is appended.
  static Future<void> addExpenseGroup(ExpenseGroup group) async {
    final result = await _repository.addExpenseGroup(group);
    if (result.isFailure) {
      print('Warning: Failed to add group ${group.id}: ${result.error}');
    }
  }

  /// Updates an existing expense in an expense group
  static Future<void> updateExpenseToGroup(
    String groupId,
    ExpenseDetails updatedExpense,
  ) async {
    final groupResult = await _repository.getGroupById(groupId);
    if (groupResult.isFailure) {
      print('Warning: Failed to get group $groupId: ${groupResult.error}');
      return;
    }

    final group = groupResult.unwrapOr(null);
    if (group == null) {
      print('Warning: Group $groupId not found');
      return;
    }

    // Find the expense to update by its ID
    final expenseIndex = group.expenses.indexWhere(
      (expense) => expense.id == updatedExpense.id,
    );
    if (expenseIndex == -1) {
      print(
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
      print(
        'Warning: Failed to save group $groupId after updating expense: ${saveResult.error}',
      );
    }
  }

  /// Removes an expense from an expense group
  static Future<void> removeExpenseFromGroup(
    String groupId,
    String expenseId,
  ) async {
    final groupResult = await _repository.getGroupById(groupId);
    if (groupResult.isFailure) {
      print('Warning: Failed to get group $groupId: ${groupResult.error}');
      return;
    }

    final group = groupResult.unwrapOr(null);
    if (group == null) {
      print('Warning: Group $groupId not found');
      return;
    }

    final updatedExpenses = group.expenses
        .where((e) => e.id != expenseId)
        .toList();
    final updatedGroup = group.copyWith(expenses: updatedExpenses);

    final saveResult = await _repository.saveGroup(updatedGroup);
    if (saveResult.isFailure) {
      print(
        'Warning: Failed to save group $groupId after removing expense: ${saveResult.error}',
      );
    }
  }

  /// Deletes a group by its id
  static Future<void> deleteGroup(String groupId) async {
    final result = await _repository.deleteGroup(groupId);
    if (result.isFailure) {
      print('Warning: Failed to delete group $groupId: ${result.error}');
    }
  }
}
