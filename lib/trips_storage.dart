import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Trip {
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
  }) : timestamp = timestamp ?? DateTime.now();

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
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

class Expense {
  final String description;
  final double amount;
  final String paidBy;
  final DateTime date;
  final String? note;

  Expense({
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.date,
    this.note,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'],
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'paidBy': paidBy,
        'date': date.toIso8601String(),
        if (note != null) 'note': note,
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
      trips.sort((a, b) =>
          b.timestamp.compareTo(a.timestamp)); // Ordina dal più recente
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
}

// RIMUOVO CurrencySelector da qui: ora è in widgets/currency_selector.dart
