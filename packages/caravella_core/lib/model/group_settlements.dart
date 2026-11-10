import 'expense_group.dart';
import 'settle_payment.dart';

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

/// Each participant's balance, keyed by participant id: what they paid
/// minus their equal share of the total. Positive = gets money back,
/// negative = owes. Sums to zero (up to rounding).
Map<String, double> computeBalances(ExpenseGroup trip) {
  final n = trip.participants.length;
  return {
    for (final e in _scaledBalances(trip).entries) e.key: e.value / (n * 100),
  };
}

/// Exact balances as integers: in cents times the number of people
/// (paid·n − total), so an equal share that doesn't divide evenly — 100 €
/// among 3 — still adds up to exactly zero. Doubles would leave "0.01"
/// leftovers.
Map<String, int> _scaledBalances(ExpenseGroup trip) {
  final n = trip.participants.length;
  final paid = {for (final p in trip.participants) p.id: 0};
  var total = 0;
  for (final e in trip.expenses) {
    if (e.amount == null) continue;
    final cents = (e.amount! * 100).round();
    total += cents;
    paid[e.paidBy.id] = (paid[e.paidBy.id] ?? 0) + cents;
  }
  final scaled = {for (final e in paid.entries) e.key: e.value * n - total};
  // A payment ticked in Settle up: the payer's debt shrinks by it, the
  // receiver's credit too. It isn't spending, so the total stays. One
  // naming someone no longer in the group is left out.
  for (final p in trip.payments) {
    if (!scaled.containsKey(p.fromId) || !scaled.containsKey(p.toId)) {
      continue;
    }
    final cents = (p.amount * 100).round() * n;
    scaled[p.fromId] = scaled[p.fromId]! + cents;
    scaled[p.toId] = scaled[p.toId]! - cents;
  }
  return scaled;
}

/// [group] with [settlement] ticked as paid, in full, on [date].
ExpenseGroup markSettlementPaid(
  ExpenseGroup group,
  Settlement settlement, {
  DateTime? date,
}) => group.copyWith(
  payments: [
    ...group.payments,
    SettlePayment(
      fromId: settlement.fromId,
      toId: settlement.toId,
      amount: settlement.amount,
      date: date ?? DateTime.now(),
    ),
  ],
);

/// [group] without the payment [paymentId]: ticked back to not paid.
ExpenseGroup unmarkPayment(ExpenseGroup group, String paymentId) =>
    group.copyWith(
      payments: [
        for (final p in group.payments)
          if (p.id != paymentId) p,
      ],
    );

/// Above this many people with a balance, [computeSettlements] stops
/// searching for the minimum (2^n subsets) and settles greedily.
const int exactSettlementLimit = 16;

/// The payments that settle the group, as few as possible.
///
/// With k people still owing or owed, k − 1 payments always suffice; each
/// set of them whose balances add up to zero on their own saves one, since
/// it can settle among itself. So the minimum is k minus the largest number
/// of such sets the people can be split into, found by a search over the
/// subsets of people (up to [exactSettlementLimit] of them; above that, all
/// of them form one set). A set may be off by up to a cent, which is left
/// out rather than paid as "0.01". Among the splits with the fewest
/// payments it keeps the one whose smallest payment is largest.
///
/// Each set gets whole-cent balances adding up to zero (an odd cent goes to
/// whoever it brings closest to zero), then within it the largest debt pays
/// the largest credit until everyone is even. Largest payments first.
List<Settlement> computeSettlements(ExpenseGroup trip) {
  final n = trip.participants.length;
  if (n < 2 || trip.expenses.isEmpty) return [];
  final open = [
    for (final e in _scaledBalances(trip).entries)
      if (e.value != 0) e,
  ];
  final payments = open.length <= exactSettlementLimit
      ? _fewestPayments(open, n)
      : _settle(open, n);
  payments.sort((a, b) => b.amount.compareTo(a.amount));
  return [
    for (final p in payments)
      Settlement(fromId: p.fromId, toId: p.toId, amount: p.amount / 100),
  ];
}

typedef _Payment = ({String fromId, String toId, int amount});

/// Settles a set of [scaled] balances (cents × [n]) adding up to zero, or
/// to within a cent of it.
List<_Payment> _settle(List<MapEntry<String, int>> scaled, int n) {
  // Whole cents adding up to zero: rounded down, then the cents still
  // missing go to those that lost the most, on a tie to whoever it brings
  // closer to zero; a cent too many comes off the other end of that order.
  final cents = <String, int>{};
  final rest = <String, int>{};
  for (final e in scaled) {
    cents[e.key] = (e.value / n).floor();
    rest[e.key] = e.value - cents[e.key]! * n;
  }
  final order = [for (final e in scaled) e.key]
    ..sort((a, b) {
      final byRest = rest[b]!.compareTo(rest[a]!);
      return byRest != 0 ? byRest : cents[a]!.compareTo(cents[b]!);
    });
  final missing = -cents.values.fold(0, (a, b) => a + b);
  for (var i = 0; i < missing.abs() && order.isNotEmpty; i++) {
    final id = missing > 0
        ? order[i % order.length]
        : order[order.length - 1 - i % order.length];
    cents[id] = cents[id]! + missing.sign;
  }

  // Largest debt pays largest credit: at most one payment fewer than
  // people, exactly that when no part of the set adds up to zero.
  final credits = [
    for (final e in cents.entries)
      if (e.value > 0) MapEntry(e.key, e.value),
  ]..sort((a, b) => b.value.compareTo(a.value));
  final debts = [
    for (final e in cents.entries)
      if (e.value < 0) MapEntry(e.key, -e.value),
  ]..sort((a, b) => b.value.compareTo(a.value));
  final payments = <_Payment>[];
  var ci = 0;
  var di = 0;
  while (ci < credits.length && di < debts.length) {
    final c = credits[ci];
    final d = debts[di];
    final amount = c.value < d.value ? c.value : d.value;
    payments.add((fromId: d.key, toId: c.key, amount: amount));
    credits[ci] = MapEntry(c.key, c.value - amount);
    debts[di] = MapEntry(d.key, d.value - amount);
    if (credits[ci].value == 0) ci++;
    if (debts[di].value == 0) di++;
  }
  return payments;
}

/// Splits [scaled] balances (cents × [n]) into as many sets adding up to
/// zero (within a cent) as possible and settles each with [_settle].
List<_Payment> _fewestPayments(List<MapEntry<String, int>> scaled, int n) {
  final k = scaled.length;
  final full = (1 << k) - 1;
  bool even(int sum) => sum.abs() <= n; // within a cent
  final sum = List<int>.filled(1 << k, 0);
  // sets[m]: the most sets adding up to zero that the people in m split
  // into, when m itself adds up to zero (adding people one at a time, each
  // time the running total is even a set closes).
  final sets = List<int>.filled(1 << k, 0);
  for (var m = 1; m <= full; m++) {
    final low = m & -m;
    sum[m] = sum[m ^ low] + scaled[low.bitLength - 1].value;
    var best = 0;
    for (var rest = m; rest != 0; rest &= rest - 1) {
      final s = sets[m ^ (rest & -rest)];
      if (s > best) best = s;
    }
    sets[m] = best + (even(sum[m]) ? 1 : 0);
  }

  final payments = <_Payment>[];
  var left = full;
  while (left != 0) {
    // The set of left's first person: one adding up to zero that leaves
    // the rest as many sets as possible, with the largest smallest payment.
    final first = left & -left;
    final others = left ^ first;
    List<_Payment>? pick;
    var pickMask = 0;
    var pickMin = -1;
    for (var sub = others; ; sub = (sub - 1) & others) {
      final m = sub | first;
      if (even(sum[m]) && sets[left ^ m] == sets[left] - 1) {
        final settled = _settle([
          for (var i = 0; i < k; i++)
            if (m & (1 << i) != 0) scaled[i],
        ], n);
        final smallest = settled.fold<int>(
          settled.isEmpty ? 0 : settled.first.amount,
          (a, p) => p.amount < a ? p.amount : a,
        );
        if (smallest > pickMin) {
          pick = settled;
          pickMask = m;
          pickMin = smallest;
        }
      }
      if (sub == 0) break;
    }
    payments.addAll(pick!);
    left ^= pickMask;
  }
  return payments;
}
