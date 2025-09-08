import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/details/tabs/settlements_logic.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_details.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';

ExpenseParticipant p(String name) => ExpenseParticipant(name: name);
ExpenseCategory cat(String name) => ExpenseCategory(name: name);

ExpenseDetails exp({required ExpenseParticipant by, required double amount}) =>
    ExpenseDetails(
      category: cat('c'),
      amount: amount,
      paidBy: by,
      date: DateTime(2024, 1, 1),
    );

ExpenseGroup buildGroup({
  required List<ExpenseParticipant> participants,
  required List<ExpenseDetails> expenses,
}) => ExpenseGroup(
  title: 'test',
  expenses: expenses,
  participants: participants,
  currency: '€',
);

void main() {
  group('computeSettlements', () {
    test('returns empty when <2 participants', () {
      final a = p('A');
      final g = buildGroup(participants: [a], expenses: []);
      expect(computeSettlements(g), isEmpty);
    });

    test('returns empty when no expenses', () {
      final a = p('A');
      final b = p('B');
      final g = buildGroup(participants: [a, b], expenses: []);
      expect(computeSettlements(g), isEmpty);
    });

    test('balanced simple case (equal payments)', () {
      final a = p('A');
      final b = p('B');
      final g = buildGroup(
        participants: [a, b],
        expenses: [
          exp(by: a, amount: 50),
          exp(by: b, amount: 50),
        ],
      );
      expect(computeSettlements(g), isEmpty);
    });

    test('two participants simple settlement', () {
      final a = p('A');
      final b = p('B');
      final g = buildGroup(
        participants: [a, b],
        expenses: [exp(by: a, amount: 100)],
      );
      final settlements = computeSettlements(g);
      expect(settlements.length, 1);
      expect(settlements.first['from'], b.name);
      expect(settlements.first['to'], a.name);
      expect(settlements.first['amount'], closeTo(50, 0.0001));
    });

    test('three participants uneven payments', () {
      final a = p('A');
      final b = p('B');
      final c = p('C');
      // Total 300, fair share 100
      final g = buildGroup(
        participants: [a, b, c],
        expenses: [
          exp(by: a, amount: 150),
          exp(by: b, amount: 100),
          exp(by: c, amount: 50),
        ],
      );
      final settlements = computeSettlements(g);
      // C owes A 50
      // (A paid 150, should pay 100 => +50 credit; C paid 50, should pay 100 => -50)
      expect(settlements.length, 1);
      final s = settlements.first;
      expect(s['from'], c.name);
      expect(s['to'], a.name);
      expect(s['amount'], closeTo(50, 0.0001));
    });

    test('four participants chain settlements', () {
      final a = p('A');
      final b = p('B');
      final c = p('C');
      final d = p('D');
      // Total 400 => fair share 100
      // A pays 200 (+100), B pays 100 (0), C pays 60 (-40), D pays 40 (-60)
      final g = buildGroup(
        participants: [a, b, c, d],
        expenses: [
          exp(by: a, amount: 200),
          exp(by: b, amount: 100),
          exp(by: c, amount: 60),
          exp(by: d, amount: 40),
        ],
      );
      final settlements = computeSettlements(g);
      // Expect 2 settlements (C->A 40, D->A 60) order may vary but amounts sum to 100
      expect(settlements.length, 2);
      final totalToA = settlements
          .where((s) => s['to'] == a.name)
          .fold<double>(0.0, (sum, s) => sum + (s['amount'] as double));
      expect(totalToA, closeTo(100, 0.001));
    });

    test('rounding tolerance small residuals ignored', () {
      final a = p('A');
      final b = p('B');
      // Total 100.01 => fair share 50.005; simulate floating noise
      final g = buildGroup(
        participants: [a, b],
        expenses: [
          exp(by: a, amount: 50.01),
          exp(by: b, amount: 50.00),
        ],
      );
      final settlements = computeSettlements(g);
      // difference is 0.01 -> each share 0.005 diff < 0.01 threshold => empty
      expect(settlements, isEmpty);
    });

    test('participant with zero expenses still considered', () {
      final a = p('A');
      final b = p('B');
      final c = p('C');
      // Total 90 => share 30; A pays 90 others 0 => B owes 30, C owes 30
      final g = buildGroup(
        participants: [a, b, c],
        expenses: [exp(by: a, amount: 90)],
      );
      final settlements = computeSettlements(g);
      expect(settlements.length, 2);
      final amounts = settlements.map((s) => s['amount'] as double).toList();
      amounts.sort();
      expect(amounts, [30, 30]);
      // Ensure both B and C pay A
      expect(settlements.every((s) => s['to'] == a.name), isTrue);
    });
  });
}
