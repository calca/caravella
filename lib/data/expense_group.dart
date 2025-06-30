import 'package:uuid/uuid.dart';
import 'expense_details.dart';

class ExpenseGroup {
  final String id; // UDID per il gruppo di spese
  final String title;
  final List<ExpenseDetails> expenses;
  final List<String> participants;
  final DateTime? startDate;
  final DateTime? endDate;
  final String currency; // Nuovo campo
  final List<String> categories;
  final DateTime timestamp; // Nuovo campo timestamp
  final bool pinned; // Nuovo campo per pinnare il gruppo

  ExpenseGroup({
    required this.title,
    required this.expenses,
    required this.participants,
    this.startDate,
    this.endDate,
    required this.currency, // Nuovo campo obbligatorio
    this.categories = const [], // Default empty list
    DateTime? timestamp, // opzionale, default a now
    String? id, // opzionale, generato se mancante
    this.pinned = false, // Default a false
  })  : timestamp = timestamp ?? DateTime.now(),
        id = id ?? const Uuid().v4();

  factory ExpenseGroup.fromJson(Map<String, dynamic> json) {
    return ExpenseGroup(
      id: json['id'],
      title: json['title'],
      expenses: (json['expenses'] as List<dynamic>?)
              ?.map((e) => ExpenseDetails.fromJson(e))
              .toList() ??
          [],
      participants: List<String>.from(json['participants'] ?? []),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
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
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'currency': currency,
        'categories': categories,
        'timestamp': timestamp.toIso8601String(),
        'pinned': pinned, // Salva il valore pinnato
      };

  ExpenseGroup copyWith({
    String? id,
    String? title,
    List<ExpenseDetails>? expenses,
    List<String>? participants,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
    List<String>? categories,
    DateTime? timestamp,
    bool? pinned,
  }) {
    return ExpenseGroup(
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

  static ExpenseGroup empty() {
    return ExpenseGroup(
      title: '',
      expenses: const [],
      participants: const [],
      startDate: null,
      endDate: null,
      currency: '€',
      categories: const [],
      timestamp: DateTime.now(),
      id: 'empty',
      pinned: false,
    );
  }
}
