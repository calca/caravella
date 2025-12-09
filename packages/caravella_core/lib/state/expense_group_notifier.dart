import 'package:flutter/foundation.dart';
import '../model/expense_group.dart';
import '../model/expense_category.dart';
import '../data/expense_group_storage_v2.dart';

class ExpenseGroupNotifier extends ChangeNotifier {
  ExpenseGroup? _currentGroup;
  final List<String> _updatedGroupIds = [];
  String? _lastAddedCategory;
  String? _lastEvent; // es: 'expense_added', 'category_added'
  final List<String> _deletedGroupIds = [];

  // Optional callback for platform-specific shortcuts (e.g., Android Quick Actions)
  VoidCallback? _onShortcutsUpdate;

  // Optional callback for canceling notifications when archiving
  Future<void> Function(String groupId)? _onNotificationCancel;

  ExpenseGroup? get currentGroup => _currentGroup;

  // Lista degli ID dei gruppi che sono stati aggiornati
  List<String> get updatedGroupIds => List.unmodifiable(_updatedGroupIds);

  // Ultima categoria aggiunta
  String? get lastAddedCategory => _lastAddedCategory;
  String? get lastEvent => _lastEvent;
  // Lista degli ID dei gruppi che sono stati cancellati
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
    _lastAddedCategory = null; // Pulisci anche l'ultima categoria
    notifyListeners();
  }

  /// Aggiorna solo i metadati del gruppo preservando le spese esistenti
  Future<void> updateGroupMetadata(ExpenseGroup updatedGroup) async {
    // Aggiorna lo stato corrente preservando le spese se presente
    if (_currentGroup != null && _currentGroup!.id == updatedGroup.id) {
      _currentGroup = updatedGroup.copyWith(expenses: _currentGroup!.expenses);
    }

    // Aggiungi l'ID alla lista dei gruppi aggiornati
    if (!_updatedGroupIds.contains(updatedGroup.id)) {
      _updatedGroupIds.add(updatedGroup.id);
    }

    notifyListeners();

    // Persisti le modifiche preservando le spese
    try {
      await ExpenseGroupStorageV2.updateGroupMetadata(updatedGroup);
      // Update shortcuts when group metadata changes
      _updateShortcuts();
    } catch (e) {
      debugPrint('Error updating group metadata: $e');
    }
  }

  Future<void> addCategory(String categoryName) async {
    if (_currentGroup == null) return;

    // Controlla se la categoria esiste già
    if (_currentGroup!.categories.any((c) => c.name == categoryName)) {
      _lastAddedCategory =
          null; // La categoria esiste già, non c'è nulla di nuovo da preselezionare
      notifyListeners();
      return;
    }

    final updatedCategories = [..._currentGroup!.categories];
    updatedCategories.add(ExpenseCategory(name: categoryName));

    // Aggiorna il gruppo corrente con le nuove categorie
    _currentGroup = _currentGroup!.copyWith(categories: updatedCategories);

    // Memorizza l'ultima categoria aggiunta
    _lastAddedCategory = categoryName;
    _lastEvent = 'category_added';

    // Notifica i listener prima di persistere
    notifyListeners();

    // Persisti le modifiche
    try {
      await ExpenseGroupStorageV2.updateGroupMetadata(_currentGroup!);
    } catch (e) {
      debugPrint('Error updating group metadata after adding category: $e');
    }
  }

  // Nuovo metodo per aggiornare l'intero gruppo (per quando viene modificato dall'esterno)
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
      debugPrint('Error refreshing group: $e');
    }
  }

  // Metodo per pulire la lista degli aggiornamenti (chiamato dopo che la UI è stata aggiornata)
  void clearUpdatedGroups() {
    _updatedGroupIds.clear();
  }

  /// Metodo per pulire la lista dei gruppi cancellati
  void clearDeletedGroups() {
    _deletedGroupIds.clear();
  }

  // Metodo per notificare un aggiornamento di gruppo dall'esterno
  void notifyGroupUpdated(String groupId) {
    if (!_updatedGroupIds.contains(groupId)) {
      _updatedGroupIds.add(groupId);
    }
    notifyListeners();
  }

  /// Metodo per notificare che un gruppo è stato cancellato
  void notifyGroupDeleted(String groupId) {
    if (!_deletedGroupIds.contains(groupId)) {
      _deletedGroupIds.add(groupId);
    }
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
