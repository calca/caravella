import 'package:uuid/uuid.dart';
import 'expense_category.dart';
import 'expense_participant.dart';
import 'expense_location.dart';
import 'expense_payer_share.dart';

class ExpenseDetails {
  final String id; // UDID per la spesa
  final ExpenseCategory category;
  final double? amount;
  final ExpenseParticipant paidBy;
  final DateTime date;
  final String? note;
  final String? name;
  final ExpenseLocation? location;
  final List<ExpensePayerShare>? payers; // optional multi-payer support

  ExpenseDetails({
    required this.category,
    required this.amount,
    required this.paidBy,
    required this.date,
    this.note,
    this.name,
    this.location,
    this.payers,
    String? id, // opzionale, generato se mancante
  }) : id = id ?? const Uuid().v4();

  factory ExpenseDetails.fromJson(Map<String, dynamic> json) {
    final amount = json['amount'] != null
        ? (json['amount'] as num).toDouble()
        : null;
    List<ExpensePayerShare>? payers;
    ExpenseParticipant primaryPaidBy;
    if (json['payers'] != null) {
      payers = (json['payers'] as List<dynamic>)
          .map((p) => ExpensePayerShare.fromJson(p as Map<String, dynamic>))
          .toList();
      if (payers.isNotEmpty) {
        primaryPaidBy = payers.first.participant;
      } else {
        primaryPaidBy = ExpenseParticipant.fromJson(json['paidBy']);
      }
    } else {
      primaryPaidBy = ExpenseParticipant.fromJson(json['paidBy']);
      if (primaryPaidBy.id.isNotEmpty && amount != null) {
        payers = [ExpensePayerShare(participant: primaryPaidBy, share: amount)];
      }
    }
    return ExpenseDetails(
      id: json['id'],
      category: ExpenseCategory.fromJson(json['category']),
      amount: amount,
      paidBy: primaryPaidBy,
      date: DateTime.parse(json['date']),
      note: json['note'],
      name: json['name'],
      location: json['location'] != null
          ? ExpenseLocation.fromJson(json['location'])
          : null,
      payers: payers,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.toJson(),
    if (amount != null) 'amount': amount,
    'paidBy': paidBy.toJson(), // legacy single payer
    'date': date.toIso8601String(),
    if (note != null) 'note': note,
    if (name != null) 'name': name,
    if (location != null) 'location': location!.toJson(),
    if (payers != null) 'payers': payers!.map((p) => p.toJson()).toList(),
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
    List<ExpensePayerShare>? payers,
  }) {
    final newPayers = payers ?? this.payers;
    final newPrimary =
        paidBy ??
        (newPayers != null && newPayers.isNotEmpty
            ? newPayers.first.participant
            : this.paidBy);
    return ExpenseDetails(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      paidBy: newPrimary,
      date: date ?? this.date,
      note: note ?? this.note,
      name: name ?? this.name,
      location: location ?? this.location,
      payers: newPayers,
    );
  }
}
