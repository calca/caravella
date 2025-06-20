import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Trip {
  final String title;
  final List<Expense> expenses;
  final List<String> participants;
  final DateTime startDate;
  final DateTime endDate;

  Trip({
    required this.title,
    required this.expenses,
    required this.participants,
    required this.startDate,
    required this.endDate,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      title: json['title'],
      expenses: (json['expenses'] as List<dynamic>?)?.map((e) => Expense.fromJson(e)).toList() ?? [],
      participants: List<String>.from(json['participants'] ?? []),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'participants': participants,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
}

class Expense {
  final String description;
  final double amount;
  final String paidBy;
  final DateTime date;

  Expense({
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'paidBy': paidBy,
        'date': date.toIso8601String(),
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
      return jsonList.map((e) => Trip.fromJson(e)).toList();
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
