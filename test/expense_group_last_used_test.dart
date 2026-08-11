import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  final alice = ExpenseParticipant(id: 'p1', name: 'Alice');
  final bob = ExpenseParticipant(id: 'p2', name: 'Bob');
  final carol = ExpenseParticipant(id: 'p3', name: 'Carol');

  final food = ExpenseCategory(id: 'c1', name: 'Food', createdAt: DateTime(2024));
  final transport = ExpenseCategory(
    id: 'c2',
    name: 'Transport',
    createdAt: DateTime(2024),
  );
  final leisure = ExpenseCategory(
    id: 'c3',
    name: 'Leisure',
    createdAt: DateTime(2024),
  );

  ExpenseDetails expense({
    required ExpenseParticipant paidBy,
    required ExpenseCategory category,
    required DateTime date,
  }) {
    return ExpenseDetails(
      category: category,
      amount: 10,
      paidBy: paidBy,
      date: date,
    );
  }

  group('getParticipantsByLastUsed', () {
    test('orders participants by most recent expense date, descending', () {
      final group = ExpenseGroup(
        title: 'Trip',
        currency: '€',
        participants: [alice, bob, carol],
        expenses: [
          expense(paidBy: alice, category: food, date: DateTime(2024, 1, 1)),
          expense(paidBy: bob, category: food, date: DateTime(2024, 1, 5)),
          expense(paidBy: alice, category: food, date: DateTime(2024, 1, 3)),
        ],
      );

      final ordered = group.getParticipantsByLastUsed();

      // Bob's latest expense (Jan 5) is more recent than Alice's latest
      // (Jan 3, ignoring her older Jan 1 expense); Carol never paid.
      expect(ordered.map((p) => p.id), ['p2', 'p1', 'p3']);
    });

    test('never-used participants are appended in original order', () {
      final group = ExpenseGroup(
        title: 'Trip',
        currency: '€',
        participants: [alice, bob, carol],
        expenses: [
          expense(paidBy: carol, category: food, date: DateTime(2024, 1, 1)),
        ],
      );

      final ordered = group.getParticipantsByLastUsed();

      expect(ordered.map((p) => p.id), ['p3', 'p1', 'p2']);
    });

    test('with no expenses, keeps original participant order', () {
      final group = ExpenseGroup(
        title: 'Trip',
        currency: '€',
        participants: [alice, bob, carol],
        expenses: const [],
      );

      expect(
        group.getParticipantsByLastUsed().map((p) => p.id),
        ['p1', 'p2', 'p3'],
      );
    });
  });

  group('getCategoriesByLastUsed', () {
    test('orders categories by most recent expense date, descending', () {
      final group = ExpenseGroup(
        title: 'Trip',
        currency: '€',
        participants: [alice],
        categories: [food, transport, leisure],
        expenses: [
          expense(paidBy: alice, category: food, date: DateTime(2024, 1, 1)),
          expense(
            paidBy: alice,
            category: transport,
            date: DateTime(2024, 1, 10),
          ),
        ],
      );

      final ordered = group.getCategoriesByLastUsed();

      expect(ordered.map((c) => c.id), ['c2', 'c1', 'c3']);
    });
  });
}
