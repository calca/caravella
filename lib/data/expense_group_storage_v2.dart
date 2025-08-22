// ignore_for_file: avoid_print, unused_element, unnecessary_brace_in_string_interps
import 'expense_group.dart';
import 'expense_details.dart';
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

  /// Writes trips to storage with improved error handling
  static Future<void> writeTrips(List<ExpenseGroup> trips) async {
    for (final trip in trips) {
      final result = await _repository.saveGroup(trip);
      if (result.isFailure) {
        // For backward compatibility, we'll just print the error
        // In a future version, this should throw the error
        print('Warning: Failed to save trip ${trip.id}: ${result.error}');
      }
    }
  }

  /// Saves a single trip
  static Future<void> saveTrip(ExpenseGroup trip) async {
    final result = await _repository.saveGroup(trip);
    if (result.isFailure) {
      // For backward compatibility, we'll just print the error
      print('Warning: Failed to save trip ${trip.id}: ${result.error}');
    }
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

  /// Sets a trip as pinned, removing the pin from all others
  static Future<void> setPinnedTrip(String tripId) async {
    final result = await _repository.setPinnedGroup(tripId);
    if (result.isFailure) {
      print('Warning: Failed to set pinned trip $tripId: ${result.error}');
    }
  }

  /// Removes the pin from a trip
  static Future<void> removePinnedTrip(String tripId) async {
    final result = await _repository.removePinnedGroup(tripId);
    if (result.isFailure) {
      print('Warning: Failed to remove pinned trip $tripId: ${result.error}');
    }
  }

  /// Returns the currently pinned trip, if exists and not archived
  static Future<ExpenseGroup?> getPinnedTrip() async {
    final result = await _repository.getPinnedGroup();
    return result.unwrapOr(null);
  }

  /// Archives a group of expenses
  static Future<void> archiveGroup(String groupId) async {
    final result = await _repository.archiveGroup(groupId);
    if (result.isFailure) {
      print('Warning: Failed to archive group $groupId: ${result.error}');
    }
  }

  /// Unarchives a group of expenses
  static Future<void> unarchiveGroup(String groupId) async {
    final result = await _repository.unarchiveGroup(groupId);
    if (result.isFailure) {
      print('Warning: Failed to unarchive group $groupId: ${result.error}');
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
}
