import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final a = ExpenseParticipant(id: 'a', name: 'Anna');
  final b = ExpenseParticipant(id: 'b', name: 'Bea');
  final c = ExpenseParticipant(id: 'c', name: 'Carlo');
  final cat = ExpenseCategory(id: 'x', name: 'Food');

  ExpenseDetails paid(ExpenseParticipant by, double amount) => ExpenseDetails(
    name: 'e',
    amount: amount,
    date: DateTime(2026, 10, 1),
    paidBy: by,
    category: cat,
  );

  test('balance = paid minus equal share, summing to zero', () {
    final group = ExpenseGroup(
      title: 'g',
      expenses: [paid(a, 90), paid(b, 30)],
      participants: [a, b, c],
      categories: [cat],
      currency: '€',
    );
    final balances = computeBalances(group);
    expect(balances['a'], closeTo(50, 1e-9));
    expect(balances['b'], closeTo(-10, 1e-9));
    expect(balances['c'], closeTo(-40, 1e-9));
    expect(balances.values.reduce((x, y) => x + y), closeTo(0, 1e-9));
  });

  test('no participants, no balances', () {
    final group = ExpenseGroup(
      title: 'g',
      expenses: [],
      participants: [],
      currency: '€',
    );
    expect(computeBalances(group), isEmpty);
  });
}
