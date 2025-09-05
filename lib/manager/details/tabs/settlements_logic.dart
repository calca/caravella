import 'package:io_caravella_egm/data/model/expense_group.dart';

/// Computes minimal settlements between participants to balance accounts.
/// Returns a list of maps with keys: 'from', 'to', 'amount'.
List<Map<String, dynamic>> computeSettlements(ExpenseGroup trip) {
  if (trip.participants.length < 2 || trip.expenses.isEmpty) return [];

  final balances = <String, double>{};
  final total = trip.expenses.fold<double>(
    0.0,
    (s, e) => s + (e.amount ?? 0.0),
  );
  final fairShare = total / trip.participants.length;

  for (final p in trip.participants) {
    balances[p.name] = 0.0;
  }
  for (final e in trip.expenses) {
    if (e.amount != null) {
      balances[e.paidBy.name] = (balances[e.paidBy.name] ?? 0) + e.amount!;
    }
  }
  for (final p in trip.participants) {
    balances[p.name] = (balances[p.name] ?? 0) - fairShare;
  }

  final creditors = <MapEntry<String, double>>[];
  final debtors = <MapEntry<String, double>>[];
  balances.forEach((k, v) {
    if (v > 0.01) {
      creditors.add(MapEntry(k, v));
    } else if (v < -0.01) {
      debtors.add(MapEntry(k, -v));
    }
  });
  creditors.sort((a, b) => b.value.compareTo(a.value));
  debtors.sort((a, b) => b.value.compareTo(a.value));

  final settlements = <Map<String, dynamic>>[];
  var ci = 0;
  var di = 0;
  while (ci < creditors.length && di < debtors.length) {
    final c = creditors[ci];
    final d = debtors[di];
    final amount = c.value < d.value ? c.value : d.value;
    settlements.add({'from': d.key, 'to': c.key, 'amount': amount});
    creditors[ci] = MapEntry(c.key, c.value - amount);
    debtors[di] = MapEntry(d.key, d.value - amount);
    if (creditors[ci].value < 0.01) ci++;
    if (debtors[di].value < 0.01) di++;
  }
  return settlements;
}
