import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'trip.dart';
import 'expense.dart';

class TripsStorage {
  static const String fileName = 'trips.json';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  static Future<List<Trip>> readTrips() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      final trips = jsonList.map((e) => Trip.fromJson(e)).toList();
      trips.sort((a, b) => b.startDate
          .compareTo(a.startDate)); // Ordina dal più recente (startDate)
      return trips;
    } catch (e) {
      return [];
    }
  }

  static Future<void> writeTrips(List<Trip> trips) async {
    final file = await _getFile();
    final jsonList = trips.map((v) => v.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  static Future<Trip?> getTripById(String id) async {
    final trips = await readTrips();
    try {
      return trips.firstWhere((trip) => trip.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<Expense?> getExpenseById(
      String tripId, String expenseId) async {
    final trip = await getTripById(tripId);
    if (trip == null) return null;
    try {
      return trip.expenses.firstWhere((expense) => expense.id == expenseId);
    } catch (_) {
      return null;
    }
  }

  /// Restituisce tutti i viaggi validi per una data specifica
  /// (dove la data è compresa tra startDate e endDate inclusi)
  /// ordinati per startDate (dal più recente)
  static Future<List<Trip>> currentTrips(DateTime date) async {
    final trips = await readTrips();
    final validTrips = trips.where((trip) {
      final startDate = DateTime(
          trip.startDate.year, trip.startDate.month, trip.startDate.day);
      final endDate =
          DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);
      final checkDate = DateTime(date.year, date.month, date.day);

      return (checkDate.isAfter(startDate) ||
              checkDate.isAtSameMomentAs(startDate)) &&
          (checkDate.isBefore(endDate) || checkDate.isAtSameMomentAs(endDate));
    }).toList();

    // Ordina per startDate (dal più recente al più vecchio)
    validTrips.sort((a, b) => b.startDate.compareTo(a.startDate));
    return validTrips;
  }
}
