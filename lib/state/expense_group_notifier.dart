import 'package:flutter/foundation.dart';
import '../data/expense_details.dart';
import '../data/expense_group.dart';
import '../data/expense_category.dart';
import '../data/expense_group_storage.dart';

class ExpenseGroupNotifier extends ChangeNotifier {
  ExpenseGroup? _currentGroup;
  final List<String> _updatedGroupIds = [];

  ExpenseGroup? get currentGroup => _currentGroup;

  // Lista degli ID dei gruppi che sono stati aggiornati
  List<String> get updatedGroupIds => List.unmodifiable(_updatedGroupIds);

  void setCurrentGroup(ExpenseGroup group) {
    _currentGroup = group;
    notifyListeners();
  }

  void clearCurrentGroup() {
    _currentGroup = null;
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
      final trips = await ExpenseGroupStorage.getAllGroups();
      final idx = trips.indexWhere((g) => g.id == updatedGroup.id);
      if (idx != -1) {
        trips[idx] = updatedGroup;
        await ExpenseGroupStorage.writeTrips(trips);
      }
    } catch (e) {
      debugPrint('Error updating group: $e');
    }
  }

  Future<void> addExpense(dynamic expense) async {
    if (_currentGroup == null) return;

    final updatedExpenses =
        [..._currentGroup!.expenses, expense] as List<ExpenseDetails>;
    final updatedGroup = ExpenseGroup(
      title: _currentGroup!.title,
      expenses: updatedExpenses,
      participants: _currentGroup!.participants,
      startDate: _currentGroup!.startDate,
      endDate: _currentGroup!.endDate,
      currency: _currentGroup!.currency,
      categories: _currentGroup!.categories,
      timestamp: _currentGroup!.timestamp,
      id: _currentGroup!.id,
      file: _currentGroup!.file,
      pinned: _currentGroup!.pinned,
    );

    await updateGroup(updatedGroup);
  }

  Future<void> addCategory(String categoryName) async {
    if (_currentGroup == null) return;

    // Controlla se la categoria esiste già
    if (_currentGroup!.categories.any((c) => c.name == categoryName)) {
      return;
    }

    final updatedCategories = [..._currentGroup!.categories];
    updatedCategories.add(ExpenseCategory(name: categoryName));

    final updatedGroup = ExpenseGroup(
      title: _currentGroup!.title,
      expenses: _currentGroup!.expenses,
      participants: _currentGroup!.participants,
      startDate: _currentGroup!.startDate,
      endDate: _currentGroup!.endDate,
      currency: _currentGroup!.currency,
      categories: updatedCategories,
      timestamp: _currentGroup!.timestamp,
      id: _currentGroup!.id,
      file: _currentGroup!.file,
      pinned: _currentGroup!.pinned,
    );

    await updateGroup(updatedGroup);
  }

  // Nuovo metodo per aggiornare l'intero gruppo (per quando viene modificato dall'esterno)
  Future<void> refreshGroup() async {
    if (_currentGroup == null) return;

    try {
      final updatedGroup =
          await ExpenseGroupStorage.getTripById(_currentGroup!.id);
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

  // Metodo per notificare un aggiornamento di gruppo dall'esterno
  void notifyGroupUpdated(String groupId) {
    if (!_updatedGroupIds.contains(groupId)) {
      _updatedGroupIds.add(groupId);
    }
    notifyListeners();
  }
}
