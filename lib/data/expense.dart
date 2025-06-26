import 'package:uuid/uuid.dart';

class Expense {
  final String id; // UDID per la spesa
  final String description;
  final double? amount;
  final String paidBy;
  final DateTime date;
  final String? note;

  Expense({
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.date,
    this.note,
    String? id, // opzionale, generato se mancante
  }) : id = id ?? const Uuid().v4();

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      description: json['description'],
      amount:
          json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      paidBy: json['paidBy'],
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        if (amount != null) 'amount': amount,
        'paidBy': paidBy,
        'date': date.toIso8601String(),
        if (note != null) 'note': note,
      };

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    String? paidBy,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
