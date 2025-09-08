import '../data/model/expense_group.dart';
import '../data/expense_group_storage_v2.dart';
import 'async_state_notifier.dart';

/// Enhanced expense groups notifier that uses AsyncValue patterns
/// Provides reactive state management for loading active and archived groups
class ExpenseGroupsAsyncNotifier extends AsyncListNotifier<ExpenseGroup> {
  static final ExpenseGroupsAsyncNotifier _instance = ExpenseGroupsAsyncNotifier._internal();
  
  factory ExpenseGroupsAsyncNotifier() => _instance;
  
  ExpenseGroupsAsyncNotifier._internal();
  
  /// Loads both active and archived groups
  /// Returns a combined list with active groups first, followed by archived
  Future<void> loadAllGroups() async {
    await execute(() async {
      final results = await Future.wait<List<ExpenseGroup>>([
        ExpenseGroupStorageV2.getActiveGroups(),
        ExpenseGroupStorageV2.getArchivedGroups(),
      ]);
      
      final active = results[0];
      final archived = results[1];
      
      // Combine active and archived groups
      return [...active, ...archived];
    });
  }
  
  /// Loads only active groups
  Future<void> loadActiveGroups() async {
    await execute(() async {
      return await ExpenseGroupStorageV2.getActiveGroups();
    });
  }
  
  /// Loads only archived groups
  Future<void> loadArchivedGroups() async {
    await execute(() async {
      return await ExpenseGroupStorageV2.getArchivedGroups();
    });
  }
  
  /// Refreshes groups in the background without showing loading state
  Future<void> refreshGroupsInBackground() async {
    await executeInBackground(() async {
      final results = await Future.wait<List<ExpenseGroup>>([
        ExpenseGroupStorageV2.getActiveGroups(),
        ExpenseGroupStorageV2.getArchivedGroups(),
      ]);
      
      return [...results[0], ...results[1]];
    });
  }
  
  /// Gets active groups from the current data
  List<ExpenseGroup> get activeGroups {
    if (!hasData) return [];
    return data!.where((group) => !group.isArchived).toList();
  }
  
  /// Gets archived groups from the current data
  List<ExpenseGroup> get archivedGroups {
    if (!hasData) return [];
    return data!.where((group) => group.isArchived).toList();
  }
  
  /// Finds a group by ID from the current data
  ExpenseGroup? findGroupById(String id) {
    if (!hasData) return null;
    try {
      return data!.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Updates a group in the current list and persists the change
  Future<void> updateGroup(ExpenseGroup updatedGroup) async {
    // Update local state immediately for responsive UI
    updateItem((group) => group.id == updatedGroup.id, updatedGroup);
    
    // Persist the change in the background
    try {
      await ExpenseGroupStorageV2.updateGroupMetadata(updatedGroup);
    } catch (e) {
      // If persistence fails, reload the data to restore consistency
      await refreshGroupsInBackground();
      rethrow;
    }
  }
  
  /// Adds a new group to the list and persists it
  Future<void> addGroup(ExpenseGroup newGroup) async {
    try {
      await ExpenseGroupStorageV2.saveTrip(newGroup);
      
      // Add to local state
      addItem(newGroup);
    } catch (e) {
      // If saving fails, reload to ensure consistency
      await refreshGroupsInBackground();
      rethrow;
    }
  }
  
  /// Removes a group from the list and persists the change
  Future<void> deleteGroup(String groupId) async {
    try {
      await ExpenseGroupStorageV2.deleteTrip(groupId);
      
      // Remove from local state
      removeItem(data!.firstWhere((group) => group.id == groupId));
    } catch (e) {
      // If deletion fails, reload to ensure consistency
      await refreshGroupsInBackground();
      rethrow;
    }
  }
  
  /// Archives a group (marks it as archived)
  Future<void> archiveGroup(String groupId) async {
    final group = findGroupById(groupId);
    if (group != null) {
      final archivedGroup = group.copyWith(isArchived: true);
      await updateGroup(archivedGroup);
    }
  }
  
  /// Unarchives a group (marks it as active)
  Future<void> unarchiveGroup(String groupId) async {
    final group = findGroupById(groupId);
    if (group != null) {
      final activeGroup = group.copyWith(isArchived: false);
      await updateGroup(activeGroup);
    }
  }
}