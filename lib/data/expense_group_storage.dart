import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'expense_group.dart';
import 'expense_details.dart';

class ExpenseGroupStorage {
  static const String fileName = 'expense_group_storage.json';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  static Future<List<ExpenseGroup>> _readAllGroups() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((e) => ExpenseGroup.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> writeTrips(List<ExpenseGroup> trips) async {
    // Enforce pin constraint: only one group can be pinned at a time
    String? pinnedGroupId;
    for (final trip in trips) {
      if (trip.pinned) {
        if (pinnedGroupId == null) {
          pinnedGroupId = trip.id;
        } else {
          // Multiple pinned groups found, unpin all except the first one
          final index = trips.indexWhere((t) => t.id == trip.id);
          if (index != -1) {
            trips[index] = trips[index].copyWith(pinned: false);
          }
        }
      }
    }
    
    final file = await _getFile();
    final jsonList = trips.map((v) => v.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  static Future<void> saveTrip(ExpenseGroup trip) async {
    final trips = await _readAllGroups();
    final index = trips.indexWhere((t) => t.id == trip.id);

    if (index != -1) {
      trips[index] = trip;
    } else {
      trips.add(trip);
    }

    await writeTrips(trips);
  }

  static Future<ExpenseGroup?> getTripById(String id) async {
    final trips = await _readAllGroups();
    final found = trips.where((trip) => trip.id == id);
    return found.isNotEmpty ? found.first : null;
  }

  static Future<ExpenseDetails?> getExpenseById(
      String tripId, String expenseId) async {
    final trip = await getTripById(tripId);
    if (trip == null) return null;
    final found = trip.expenses.where((expense) => expense.id == expenseId);
    return found.isNotEmpty ? found.first : null;
  }

  /// Imposta un viaggio come pinnato, rimuovendo il pin da tutti gli altri
  static Future<void> setPinnedTrip(String tripId) async {
    final trips = await _readAllGroups();

    for (var i = 0; i < trips.length; i++) {
      if (trips[i].id == tripId) {
        trips[i] = trips[i].copyWith(pinned: true);
      } else if (trips[i].pinned) {
        trips[i] = trips[i].copyWith(pinned: false);
      }
    }

    await writeTrips(trips);
  }

  /// Rimuove il pin da un viaggio
  static Future<void> removePinnedTrip(String tripId) async {
    final trips = await _readAllGroups();
    final index = trips.indexWhere((trip) => trip.id == tripId);

    if (index != -1 && trips[index].pinned) {
      trips[index] = trips[index].copyWith(pinned: false);
      await writeTrips(trips);
    }
  }

  /// Restituisce il gruppo attualmente pinnato, se esiste e non è archiviato
  static Future<ExpenseGroup?> getPinnedTrip() async {
    final trips = await _readAllGroups();
    final found = trips.where((trip) => trip.pinned && !trip.archived);
    return found.isNotEmpty ? found.first : null;
  }

  /// Archivia un gruppo di spese
  static Future<void> archiveGroup(String groupId) async {
    final trips = await _readAllGroups();
    final index = trips.indexWhere((trip) => trip.id == groupId);

    if (index != -1) {
      trips[index] = trips[index].copyWith(archived: true);
      await writeTrips(trips);
    }
  }

  /// Rimuove dall'archivio un gruppo di spese
  static Future<void> unarchiveGroup(String groupId) async {
    final trips = await _readAllGroups();
    final index = trips.indexWhere((trip) => trip.id == groupId);

    if (index != -1 && trips[index].archived) {
      trips[index] = trips[index].copyWith(archived: false);
      await writeTrips(trips);
    }
  }

  /// Restituisce tutti i gruppi archiviati ordinati per timestamp di creazione (dal più recente)
  static Future<List<ExpenseGroup>> getArchivedGroups() async {
    final trips = await _readAllGroups();
    final archivedTrips = trips.where((trip) => trip.archived).toList();

    // Ordina per timestamp di creazione (dal più recente al più vecchio)
    archivedTrips.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return archivedTrips;
  }

  /// Restituisce tutti i gruppi non archiviati ordinati per timestamp di creazione (dal più recente)
  static Future<List<ExpenseGroup>> getActiveGroups() async {
    final trips = await _readAllGroups();
    final activeTrips = trips.where((trip) => !trip.archived).toList();

    // Ordina per timestamp di creazione (dal più recente al più vecchio)
    activeTrips.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activeTrips;
  }

  /// Restituisce TUTTI i gruppi (inclusi quelli archiviati) ordinati per timestamp di creazione (dal più recente)
  static Future<List<ExpenseGroup>> getAllGroups() async {
    final trips = await _readAllGroups();

    // Ordina per timestamp di creazione (dal più recente al più vecchio)
    trips.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return trips;
  }
}
