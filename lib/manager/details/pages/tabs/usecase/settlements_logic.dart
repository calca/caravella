import 'package:io_caravella_egm/data/model/expense_group.dart';

/// Strongly-typed settlement item using participant IDs (robust to name changes).
class Settlement {
  final String fromId; // debtor id
  final String toId; // creditor id
  final double amount;

  const Settlement({
    required this.fromId,
    required this.toId,
    required this.amount,
  });

  Settlement copyWith({String? fromId, String? toId, double? amount}) =>
      Settlement(
        fromId: fromId ?? this.fromId,
        toId: toId ?? this.toId,
        amount: amount ?? this.amount,
      );

  Map<String, dynamic> toJson() => {
    'fromId': fromId,
    'toId': toId,
    'amount': amount,
  };

  @override
  String toString() =>
      'Settlement(fromId: $fromId, toId: $toId, amount: $amount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settlement &&
          runtimeType == other.runtimeType &&
          fromId == other.fromId &&
          toId == other.toId &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(fromId, toId, amount);
}

/// Computes minimal settlements between participants to balance accounts.
/// Returns a typed list of [Settlement].
List<Settlement> computeSettlements(ExpenseGroup trip) {
  if (trip.participants.length < 2 || trip.expenses.isEmpty) return [];

  // Balances keyed by participant id
  final balances = <String, double>{};
  final total = trip.expenses.fold<double>(
    0.0,
    (s, e) => s + (e.amount ?? 0.0),
  );
  final fairShare = total / trip.participants.length;

  for (final p in trip.participants) {
    balances[p.id] = 0.0;
  }
  for (final e in trip.expenses) {
    if (e.amount != null) {
      final payers = e.payers;
      if (payers != null && payers.isNotEmpty) {
        for (final ps in payers) {
          balances[ps.participant.id] =
              (balances[ps.participant.id] ?? 0) + ps.share;
        }
      } else {
        balances[e.paidBy.id] = (balances[e.paidBy.id] ?? 0) + e.amount!;
      }
    }
  }
  for (final p in trip.participants) {
    balances[p.id] = (balances[p.id] ?? 0) - fairShare;
  }

  final creditors = <MapEntry<String, double>>[]; // id -> credit
  final debtors = <MapEntry<String, double>>[]; // id -> debt
  balances.forEach((k, v) {
    if (v > 0.01) {
      creditors.add(MapEntry(k, v));
    } else if (v < -0.01) {
      debtors.add(MapEntry(k, -v));
    }
  });
  creditors.sort((a, b) => b.value.compareTo(a.value));
  debtors.sort((a, b) => b.value.compareTo(a.value));

  final settlements = <Settlement>[];
  var ci = 0;
  var di = 0;
  while (ci < creditors.length && di < debtors.length) {
    final c = creditors[ci];
    final d = debtors[di];
    final amount = c.value < d.value ? c.value : d.value;
    settlements.add(Settlement(fromId: d.key, toId: c.key, amount: amount));
    creditors[ci] = MapEntry(c.key, c.value - amount);
    debtors[di] = MapEntry(d.key, d.value - amount);
    if (creditors[ci].value < 0.01) ci++;
    if (debtors[di].value < 0.01) di++;
  }
  return settlements;
}
