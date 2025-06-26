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

  static Trip empty() {
    return Trip(
      title: '',
      expenses: const [],
      participants: const [],
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      currency: '€',
      categories: const [],
      timestamp: DateTime.now(),
      id: 'empty',
    );
  }
}
