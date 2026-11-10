import 'package:uuid/uuid.dart';

/// A payment between two participants that settles (part of) a group, ticked
/// as paid in Balances → Settle up: [fromId] gave [toId] [amount] (in the
/// group currency) on [date].
///
/// It is not an expense: it never shows in the expense list, totals or
/// statistics, and only moves the two people's balances
/// (see `computeBalances`).
class SettlePayment {
  final String id;
  final String fromId;
  final String toId;
  final double amount;
  final DateTime date;

  SettlePayment({
    String? id,
    required this.fromId,
    required this.toId,
    required this.amount,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  factory SettlePayment.fromJson(Map<String, dynamic> json) => SettlePayment(
    id: json['id'] as String,
    fromId: json['fromId'] as String,
    toId: json['toId'] as String,
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromId': fromId,
    'toId': toId,
    'amount': amount,
    'date': date.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is SettlePayment &&
      other.id == id &&
      other.fromId == fromId &&
      other.toId == toId &&
      other.amount == amount &&
      other.date == date;

  @override
  int get hashCode => Object.hash(id, fromId, toId, amount, date);
}
