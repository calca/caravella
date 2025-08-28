import 'package:flutter/foundation.dart';
import '../data/model/expense_details.dart';
import '../data/model/expense_group.dart';
import '../data/model/expense_category.dart';
import '../data/expense_group_storage_v2.dart';

class ExpenseGroupNotifier extends ChangeNotifier {
  ExpenseGroup? _currentGroup;
  final List<String> _updatedGroupIds = [];
  String? _lastAddedCategory;
  String? _lastEvent; // es: 'expense_added', 'category_added'
  final List<String> _deletedGroupIds = [];

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

  Future<void> updateGroup(ExpenseGroup updatedGroup) async {
    _currentGroup = updatedGroup;

    // Aggiungi l'ID alla lista dei gruppi aggiornati
    if (!_updatedGroupIds.contains(updatedGroup.id)) {
      _updatedGroupIds.add(updatedGroup.id);
    }

    notifyListeners();

    // Persisti le modifiche
    try {
      final trips = await ExpenseGroupStorageV2.getAllGroups();
      final idx = trips.indexWhere((g) => g.id == updatedGroup.id);
      if (idx != -1) {
        trips[idx] = updatedGroup;
        await ExpenseGroupStorageV2.writeTrips(trips);
      }
    } catch (e) {
      debugPrint('Error updating group: $e');
    }
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
    } catch (e) {
      debugPrint('Error updating group metadata: $e');
    }
  }

  Future<void> addExpense(ExpenseDetails expense) async {
    if (_currentGroup == null) return;

    final updatedExpenses = [..._currentGroup!.expenses, expense];
    final updatedGroup = _currentGroup!.copyWith(expenses: updatedExpenses);

    _lastEvent = 'expense_added';

    await updateGroup(updatedGroup);
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

    final updatedGroup = _currentGroup!.copyWith(categories: updatedCategories);

    // Memorizza l'ultima categoria aggiunta
    _lastAddedCategory = categoryName;
    _lastEvent = 'category_added';

    await updateGroup(updatedGroup);
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
  }
}
