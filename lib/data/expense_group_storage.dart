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

  static Future<List<ExpenseGroup>> readTrips() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      final trips = jsonList.map((e) => ExpenseGroup.fromJson(e)).toList();
      trips.sort((a, b) {
        // Gestisce il caso di date null
        if (a.startDate == null && b.startDate == null) return 0;
        if (a.startDate == null) return 1; // null va alla fine
        if (b.startDate == null) return -1; // null va alla fine
        return b.startDate!.compareTo(a.startDate!); // Ordina dal più recente
      });
      return trips;
    } catch (e) {
      return [];
    }
  }

  static Future<void> writeTrips(List<ExpenseGroup> trips) async {
    final file = await _getFile();
    final jsonList = trips.map((v) => v.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  static Future<void> saveTrip(ExpenseGroup trip) async {
    final trips = await readTrips();
    final index = trips.indexWhere((t) => t.id == trip.id);

    if (trip.pinned) {
      // Se il viaggio è pinnato, rimuovi il pin da tutti gli altri
      for (var i = 0; i < trips.length; i++) {
        if (trips[i].id != trip.id && trips[i].pinned) {
          trips[i] = trips[i].copyWith(pinned: false);
        }
      }
    }

    if (index != -1) {
      trips[index] = trip;
    } else {
      trips.add(trip);
    }

    await writeTrips(trips);
  }

  static Future<ExpenseGroup?> getTripById(String id) async {
    final trips = await readTrips();
    try {
      return trips.firstWhere((trip) => trip.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<ExpenseDetails?> getExpenseById(
      String tripId, String expenseId) async {
    final trip = await getTripById(tripId);
    if (trip == null) return null;
    try {
      return trip.expenses.firstWhere((expense) => expense.id == expenseId);
    } catch (_) {
      return null;
    }
  }

  /// Restituisce tutti i gruppi validi per una data specifica
  /// (dove la data è compresa tra startDate e endDate inclusi)
  /// ordinati per startDate (dal più recente). Se startDate o endDate sono null,
  /// il gruppo è considerato sempre valido per la data
  static Future<List<ExpenseGroup>> currentTrips(DateTime date) async {
    final trips = await readTrips();
    final validTrips = trips.where((trip) {
      // Escludi i gruppi archiviati
      if (trip.archived) return false;
      
      // Se non ci sono date, il gruppo è sempre valido
      if (trip.startDate == null || trip.endDate == null) return true;
      
      final startDate = DateTime(
          trip.startDate!.year, trip.startDate!.month, trip.startDate!.day);
      final endDate =
          DateTime(trip.endDate!.year, trip.endDate!.month, trip.endDate!.day);
      final checkDate = DateTime(date.year, date.month, date.day);

      return (checkDate.isAfter(startDate) ||
              checkDate.isAtSameMomentAs(startDate)) &&
          (checkDate.isBefore(endDate) || checkDate.isAtSameMomentAs(endDate));
    }).toList();

    // Ordina per startDate (dal più recente al più vecchio)
    validTrips.sort((a, b) {
      if (a.startDate == null && b.startDate == null) return 0;
      if (a.startDate == null) return 1; // null va alla fine
      if (b.startDate == null) return -1; // null va alla fine
      return b.startDate!.compareTo(a.startDate!);
    });
    return validTrips;
  }

  /// Imposta un viaggio come pinnato, rimuovendo il pin da tutti gli altri
  static Future<void> setPinnedTrip(String tripId) async {
    final trips = await readTrips();

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
    final trips = await readTrips();
    final index = trips.indexWhere((trip) => trip.id == tripId);

    if (index != -1 && trips[index].pinned) {
      trips[index] = trips[index].copyWith(pinned: false);
      await writeTrips(trips);
    }
  }

  /// Restituisce il gruppo attualmente pinnato, se esiste e non è archiviato
  static Future<ExpenseGroup?> getPinnedTrip() async {
    final trips = await readTrips();
    try {
      return trips.firstWhere((trip) => trip.pinned && !trip.archived);
    } catch (_) {
      return null;
    }
  }

  /// Archivia un gruppo di spese
  static Future<void> archiveGroup(String groupId) async {
    final trips = await readTrips();
    final index = trips.indexWhere((trip) => trip.id == groupId);

    if (index != -1) {
      trips[index] = trips[index].copyWith(archived: true);
      await writeTrips(trips);
    }
  }

  /// Rimuove dall'archivio un gruppo di spese
  static Future<void> unarchiveGroup(String groupId) async {
    final trips = await readTrips();
    final index = trips.indexWhere((trip) => trip.id == groupId);

    if (index != -1 && trips[index].archived) {
      trips[index] = trips[index].copyWith(archived: false);
      await writeTrips(trips);
    }
  }

  /// Restituisce tutti i gruppi archiviati
  static Future<List<ExpenseGroup>> getArchivedGroups() async {
    final trips = await readTrips();
    return trips.where((trip) => trip.archived).toList();
  }

  /// Restituisce tutti i gruppi non archiviati
  static Future<List<ExpenseGroup>> getActiveGroups() async {
    final trips = await readTrips();
    return trips.where((trip) => !trip.archived).toList();
  }
}
