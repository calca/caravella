import 'package:flutter/foundation.dart';
import '../model/expense_group.dart';
import '../model/expense_category.dart';
import '../model/expense_participant.dart';
import '../data/expense_group_storage_v2.dart';
import '../services/logging/logger_service.dart';

class ExpenseGroupNotifier extends ChangeNotifier {
  ExpenseGroup? _currentGroup;
  final List<String> _updatedGroupIds = [];
  String? _lastAddedCategory;
  String? _lastAddedParticipant;
  String?
  _lastEvent; // es: 'expense_added', 'category_added', 'participant_added'
  final List<String> _deletedGroupIds = [];

  // Optional callback for platform-specific shortcuts (e.g., Android Quick Actions)
  VoidCallback? _onShortcutsUpdate;

  // Optional callback for canceling notifications when archiving
  Future<void> Function(String groupId)? _onNotificationCancel;

  ExpenseGroup? get currentGroup => _currentGroup;

  int _revision = 0;

  /// Grows every time a group is marked updated or deleted. Unlike
  /// [updatedGroupIds]/[deletedGroupIds], which the first listener may clear,
  /// it can't be consumed: pages alive at the same time (Home and Groups in
  /// the app shell) compare it with the value they last saw.
  int get revision => _revision;

  // IDs of the groups updated since the UI last cleared them
  List<String> get updatedGroupIds => List.unmodifiable(_updatedGroupIds);

  // Last category added
  String? get lastAddedCategory => _lastAddedCategory;
  // Last participant added
  String? get lastAddedParticipant => _lastAddedParticipant;
  String? get lastEvent => _lastEvent;
  // IDs of the groups deleted since the UI last cleared them
  List<String> get deletedGroupIds => List.unmodifiable(_deletedGroupIds);

  String? consumeLastEvent() {
    final e = _lastEvent;
    _lastEvent = null;
    return e;
  }

  void setCurrentGroup(ExpenseGroup group) {
    _currentGroup = group;
    notifyListeners();
  }

  void clearCurrentGroup() {
    _currentGroup = null;
    _lastAddedCategory = null;
    _lastAddedParticipant = null;
    notifyListeners();
  }

  /// Updates only the group's metadata, keeping its expenses.
  Future<void> updateGroupMetadata(ExpenseGroup updatedGroup) async {
    // Keep the current group's expenses
    if (_currentGroup != null && _currentGroup!.id == updatedGroup.id) {
      _currentGroup = updatedGroup.copyWith(expenses: _currentGroup!.expenses);
    }

    if (!_updatedGroupIds.contains(updatedGroup.id)) {
      _updatedGroupIds.add(updatedGroup.id);
    }
    _revision++;

    notifyListeners();

    try {
      await ExpenseGroupStorageV2.updateGroupMetadata(updatedGroup);
      // Update shortcuts when group metadata changes
      _updateShortcuts();
    } catch (e) {
      LoggerService.error(
        'Error updating group metadata',
        name: 'state.notifier',
        error: e,
      );
    }
  }

  Future<void> addCategory(String categoryName) async {
    if (_currentGroup == null) return;

    if (_currentGroup!.categories.any((c) => c.name == categoryName)) {
      _lastAddedCategory = null; // already there: nothing new to preselect
      notifyListeners();
      return;
    }

    final updatedCategories = [..._currentGroup!.categories];
    updatedCategories.add(ExpenseCategory(name: categoryName));

    _currentGroup = _currentGroup!.copyWith(categories: updatedCategories);

    _lastAddedCategory = categoryName;
    _lastEvent = 'category_added';

    // Notify before saving, so the form updates at once
    notifyListeners();

    try {
      await ExpenseGroupStorageV2.updateGroupMetadata(_currentGroup!);
    } catch (e) {
      LoggerService.error(
        'Error updating group metadata after adding category',
        name: 'state.notifier',
        error: e,
      );
    }
  }

  Future<void> addParticipant(String participantName) async {
    if (_currentGroup == null) return;

    if (_currentGroup!.participants.any((p) => p.name == participantName)) {
      _lastAddedParticipant = null; // already there: nothing new to preselect
      notifyListeners();
      return;
    }

    final updatedParticipants = [..._currentGroup!.participants];
    updatedParticipants.add(ExpenseParticipant(name: participantName));

    _currentGroup = _currentGroup!.copyWith(participants: updatedParticipants);

    _lastAddedParticipant = participantName;
    _lastEvent = 'participant_added';

    // Notify before saving, so the form updates at once
    notifyListeners();

    try {
      await ExpenseGroupStorageV2.updateGroupMetadata(_currentGroup!);
    } catch (e) {
      LoggerService.error(
        'Error updating group metadata after adding participant',
        name: 'state.notifier',
        error: e,
      );
    }
  }

  /// Reloads the current group from storage, after a change made elsewhere.
  Future<void> refreshGroup() async {
    if (_currentGroup == null) return;

    try {
      final updatedGroup = await ExpenseGroupStorageV2.getTripById(
        _currentGroup!.id,
      );
      if (updatedGroup != null) {
        _currentGroup = updatedGroup;
        notifyListeners();
      }
    } catch (e) {
      LoggerService.error(
        'Error refreshing group',
        name: 'state.notifier',
        error: e,
      );
    }
  }

  /// Clears [updatedGroupIds], once the UI has handled them.
  void clearUpdatedGroups() {
    _updatedGroupIds.clear();
  }

  /// Clears the deleted group IDs, once the UI has handled them.
  void clearDeletedGroups() {
    _deletedGroupIds.clear();
  }

  /// Tells listeners that [groupId] changed elsewhere.
  void notifyGroupUpdated(String groupId) {
    if (!_updatedGroupIds.contains(groupId)) {
      _updatedGroupIds.add(groupId);
    }
    _revision++;
    notifyListeners();
  }

  /// Tells listeners that [groupId] was deleted.
  void notifyGroupDeleted(String groupId) {
    if (!_deletedGroupIds.contains(groupId)) {
      _deletedGroupIds.add(groupId);
    }
    _revision++;
    notifyListeners();
    // Update shortcuts when group is deleted
    _updateShortcuts();
  }

  /// Update pin state of a group
  Future<void> updateGroupPin(String groupId, bool pinned) async {
    await ExpenseGroupStorageV2.updateGroupPin(groupId, pinned);

    // Update current group if it's the one being modified
    if (_currentGroup?.id == groupId) {
      final updatedGroup = await ExpenseGroupStorageV2.getTripById(groupId);
      if (updatedGroup != null) {
        _currentGroup = updatedGroup;
      }
    }

    // Notify that this group was updated
    if (!_updatedGroupIds.contains(groupId)) {
      _updatedGroupIds.add(groupId);
    }
    _revision++;

    notifyListeners();
    _updateShortcuts();
  }

  /// Update archive state of a group
  Future<void> updateGroupArchive(String groupId, bool archived) async {
    // If archiving (not unarchiving), cancel the notification via callback
    if (archived && _onNotificationCancel != null) {
      await _onNotificationCancel!(groupId);
    }

    await ExpenseGroupStorageV2.updateGroupArchive(groupId, archived);

    // Update current group if it's the one being modified
    if (_currentGroup?.id == groupId) {
      final updatedGroup = await ExpenseGroupStorageV2.getTripById(groupId);
      if (updatedGroup != null) {
        _currentGroup = updatedGroup;
      }
    }

    // Notify that this group was updated
    if (!_updatedGroupIds.contains(groupId)) {
      _updatedGroupIds.add(groupId);
    }
    _revision++;

    notifyListeners();
    _updateShortcuts();
  }

  /// Update Android shortcuts (Quick Actions)
  void _updateShortcuts() {
    _onShortcutsUpdate?.call();
  }

  /// Set callback for shortcuts update (platform-specific)
  void setShortcutsUpdateCallback(VoidCallback? callback) {
    _onShortcutsUpdate = callback;
  }

  /// Set callback for canceling notifications when archiving groups
  void setNotificationCancelCallback(Future<void> Function(String)? callback) {
    _onNotificationCancel = callback;
  }
}
