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
  final bool pinned; // Nuovo campo per pinnare il viaggio

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
    this.pinned = false, // Default a false
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
      pinned: json['pinned'] ?? false, // Legge il valore pinnato
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
        'pinned': pinned, // Salva il valore pinnato
      };

  Trip copyWith({
    String? id,
    String? title,
    List<Expense>? expenses,
    List<String>? participants,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
    List<String>? categories,
    DateTime? timestamp,
    bool? pinned,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      expenses: expenses ?? this.expenses,
      participants: participants ?? this.participants,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currency: currency ?? this.currency,
      categories: categories ?? this.categories,
      timestamp: timestamp ?? this.timestamp,
      pinned: pinned ?? this.pinned,
    );
  }

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
      pinned: false,
    );
  }
}
