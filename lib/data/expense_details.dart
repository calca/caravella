import 'package:uuid/uuid.dart';
import 'expense_category.dart';
import 'expense_participant.dart';
import 'expense_location.dart';

class ExpenseDetails {
  final String id; // UDID per la spesa
  final ExpenseCategory category;
  final double? amount;
  final ExpenseParticipant paidBy;
  final DateTime date;
  final String? note;
  final String? name;
  final ExpenseLocation? location;

  ExpenseDetails({
    required this.category,
    required this.amount,
    required this.paidBy,
    required this.date,
    this.note,
    this.name,
    this.location,
    String? id, // opzionale, generato se mancante
  }) : id = id ?? const Uuid().v4();

  factory ExpenseDetails.fromJson(Map<String, dynamic> json) {
    return ExpenseDetails(
      id: json['id'],
      category: ExpenseCategory.fromJson(json['category']),
      amount:
          json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      paidBy: ExpenseParticipant.fromJson(json['paidBy']),
      date: DateTime.parse(json['date']),
      note: json['note'],
      name: json['name'],
      location: json['location'] != null
          ? ExpenseLocation.fromJson(json['location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.toJson(),
        if (amount != null) 'amount': amount,
        'paidBy': paidBy.toJson(),
        'date': date.toIso8601String(),
        if (note != null) 'note': note,
        if (name != null) 'name': name,
        if (location != null) 'location': location!.toJson(),
      };

  ExpenseDetails copyWith({
    String? id,
    ExpenseCategory? category,
    double? amount,
    ExpenseParticipant? paidBy,
    DateTime? date,
    String? note,
    String? name,
    ExpenseLocation? location,
  }) {
    return ExpenseDetails(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      date: date ?? this.date,
      note: note ?? this.note,
      name: name ?? this.name,
      location: location ?? this.location,
    );
  }
}
