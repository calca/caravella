import 'package:uuid/uuid.dart';
import 'expense_category.dart';

class ExpenseDetails {
  final String id; // UDID per la spesa
  final ExpenseCategory category;
  final double? amount;
  final String paidBy;
  final DateTime date;
  final String? note;

  ExpenseDetails({
    required this.category,
    required this.amount,
    required this.paidBy,
    required this.date,
    this.note,
    String? id, // opzionale, generato se mancante
  }) : id = id ?? const Uuid().v4();

  factory ExpenseDetails.fromJson(Map<String, dynamic> json) {
    return ExpenseDetails(
      id: json['id'],
      category: ExpenseCategory.fromJson(json['category']),
      amount:
          json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      paidBy: json['paidBy'],
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.toJson(),
        if (amount != null) 'amount': amount,
        'paidBy': paidBy,
        'date': date.toIso8601String(),
        if (note != null) 'note': note,
      };

  ExpenseDetails copyWith({
    String? id,
    ExpenseCategory? category,
    double? amount,
    String? paidBy,
    DateTime? date,
    String? note,
  }) {
    return ExpenseDetails(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
