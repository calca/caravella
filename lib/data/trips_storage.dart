import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'expense.dart';

class Trip {
  final String id; // UDID per il viaggio
  final String title;
  final List<Expense> expenses;
  final List<String> participants;
  final DateTime startDate;
  final DateTime endDate;
  final String currency; // Nuovo campo
  final List<String> categories;
  final DateTime timestamp; // Nuovo campo timestamp

  Trip({
    required this.title,
    required this.expenses,
    required this.participants,
    required this.startDate,
    required this.endDate,
    required this.currency, // Nuovo campo obbligatorio
    this.categories = const [], // Default empty list
    DateTime? timestamp, // opzionale, default a now
    String? id, // opzionale, generato se mancante
  })  : timestamp = timestamp ?? DateTime.now(),
        id = id ?? const Uuid().v4();

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      title: json['title'],
      expenses: (json['expenses'] as List<dynamic>?)
              ?.map((e) => Expense.fromJson(e))
              .toList() ??
          [],
      participants: List<String>.from(json['participants'] ?? []),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      currency: json['currency'] ?? '€', // Default a euro se mancante
      categories: (json['categories'] is List)
          ? List<String>.from(json['categories'] ?? [])
          : [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'participants': participants,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'currency': currency,
        'categories': categories,
        'timestamp': timestamp.toIso8601String(),
      };
}

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
}
