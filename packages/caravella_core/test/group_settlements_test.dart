import 'dart:math';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

final _cat = ExpenseCategory(id: 'x', name: 'Food');

/// A group of [paid].length people, each paying the listed amounts.
ExpenseGroup _group(List<List<double>> paid) {
  final people = [
    for (var i = 0; i < paid.length; i++)
      ExpenseParticipant(id: 'p$i', name: 'P$i'),
  ];
  return ExpenseGroup(
    title: 'g',
    currency: '€',
    participants: people,
    categories: [_cat],
    expenses: [
      for (var i = 0; i < paid.length; i++)
        for (final a in paid[i])
          ExpenseDetails(
            amount: a,
            date: DateTime(2026, 11, 1),
            paidBy: people[i],
            category: _cat,
          ),
    ],
  );
}

/// Each person's balance in cents after making [settlements].
Map<String, double> _after(ExpenseGroup g, List<Settlement> settlements) {
  final left = {
    for (final e in computeBalances(g).entries) e.key: e.value * 100,
  };
  for (final s in settlements) {
    left[s.fromId] = left[s.fromId]! + s.amount * 100;
    left[s.toId] = left[s.toId]! - s.amount * 100;
  }
  return left;
}

/// The fewest payments for [balances], by trying every split into sets.
int _bruteForce(List<int> balances, int n) {
  var most = 0;
  void place(int i, List<int> sums) {
    if (i == balances.length) {
      if (sums.every((s) => s.abs() <= n)) most = max(most, sums.length);
      return;
    }
    for (var k = 0; k < sums.length; k++) {
      sums[k] += balances[i];
      place(i + 1, sums);
      sums[k] -= balances[i];
    }
    place(i + 1, [...sums, balances[i]]);
  }

  place(0, []);
  return balances.length - most;
}

void main() {
  test('people who can settle among themselves save a payment', () {
    // Balances +4 +3 +3 −6 −4: largest debt to largest credit takes 4.
    final g = _group([
      [14],
      [13],
      [13],
      [4],
      [6],
    ]);
    final s = computeSettlements(g);
    expect(s, hasLength(3));
    expect(s, contains(const Settlement(fromId: 'p4', toId: 'p0', amount: 4)));
    expect(_after(g, s).values, everyElement(closeTo(0, 1e-6)));
  });

  test('a weekend in six: 4 payments instead of 5', () {
    // +70 +10 −50 +40 −20 −50
    final g = _group([
      [120],
      [60],
      [],
      [90],
      [30],
      [],
    ]);
    expect(computeSettlements(g), hasLength(4));
  });

  test('shares that do not divide evenly add no 0.01 payment', () {
    final third = _group([
      [100],
      [],
      [],
    ]);
    final s = computeSettlements(third);
    expect(s.map((x) => x.amount), [33.33, 33.33]);

    expect(
      computeSettlements(
        _group([
          [50.01],
          [50],
        ]),
      ),
      isEmpty,
    );
  });

  test('amounts are whole cents, largest first', () {
    final g = _group([
      [86.57, 44.68],
      [98.67],
      [63.48, 63.73],
      [34.37],
      [108.69],
      [76.41, 72.2],
      [18.13],
      [46.16],
    ]);
    final s = computeSettlements(g);
    for (final x in s) {
      expect(x.amount * 100, closeTo((x.amount * 100).round(), 1e-6));
    }
    final amounts = [for (final x in s) x.amount];
    expect(amounts, [...amounts]..sort((a, b) => b.compareTo(a)));
  });

  test('random groups: the fewest payments, everyone even to a cent', () {
    final r = Random(7);
    for (var t = 0; t < 400; t++) {
      final n = 2 + r.nextInt(7);
      final round = t.isEven;
      final paid = List.generate(n, (_) => <double>[]);
      for (var k = 0; k < 1 + r.nextInt(12); k++) {
        paid[r.nextInt(n)].add(
          round ? 5.0 * (1 + r.nextInt(20)) : (100 + r.nextInt(9000)) / 100,
        );
      }
      final g = _group(paid);
      final s = computeSettlements(g);
      expect(s.every((x) => x.amount > 0), isTrue);
      expect(_after(g, s).values, everyElement(closeTo(0, 1.01)));
      final scaled = [
        for (final v in computeBalances(g).values)
          if ((v * n * 100).round() case final x when x != 0) x,
      ];
      expect(s.length, lessThanOrEqualTo(_bruteForce(scaled, n)));
    }
  });

  test('above the exact limit it still settles everyone', () {
    final n = exactSettlementLimit + 4;
    final g = _group([
      for (var i = 0; i < n; i++) [i * 7.31],
    ]);
    final s = computeSettlements(g);
    expect(s.length, lessThanOrEqualTo(n - 1));
    expect(_after(g, s).values, everyElement(closeTo(0, 1.01)));
  });

  group('payments ticked in Settle up', () {
    // P0 paid 90, P1 and P2 nothing: each owes P0 30.
    ExpenseGroup g0() => _group([
      [90],
      [],
      [],
    ]);

    test('a ticked payment settles it and drops out of Settle up', () {
      final g = g0();
      final first = computeSettlements(g).first;
      final paid = markSettlementPaid(g, first, date: DateTime(2026, 11, 10));
      expect(paid.payments.single.amount, first.amount);
      final left = computeSettlements(paid);
      expect(left.length, 1);
      expect(left.any((s) => s.fromId == first.fromId), isFalse);
      expect(computeBalances(paid)[first.fromId], 0);
    });

    test('all ticked: everyone square, spending unchanged', () {
      var g = g0();
      for (final s in computeSettlements(g)) {
        g = markSettlementPaid(g, s);
      }
      expect(computeSettlements(g), isEmpty);
      expect(computeBalances(g).values.every((v) => v == 0), isTrue);
      expect(g.getTotalExpenses(), 90);
    });

    test('unticking brings it back', () {
      final g = g0();
      final first = computeSettlements(g).first;
      final paid = markSettlementPaid(g, first);
      final back = unmarkPayment(paid, paid.payments.single.id);
      expect(back.payments, isEmpty);
      expect(computeSettlements(back).length, 2);
    });

    test('a payment naming someone not in the group is ignored', () {
      final g = g0().copyWith(
        payments: [
          SettlePayment(
            fromId: 'gone',
            toId: 'p0',
            amount: 30,
            date: DateTime(2026, 11, 10),
          ),
        ],
      );
      expect(computeBalances(g), computeBalances(g0()));
    });

    test('payments survive JSON', () {
      final g = markSettlementPaid(g0(), computeSettlements(g0()).first);
      final back = ExpenseGroup.fromJson(g.toJson());
      expect(back.payments, g.payments);
    });
  });
}
