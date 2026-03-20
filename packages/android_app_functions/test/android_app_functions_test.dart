import 'package:flutter_test/flutter_test.dart';
import 'package:android_app_functions/android_app_functions.dart';

void main() {
  group('AddExpenseFunctionParams', () {
    test('fromMap parses all fields', () {
      final map = {
        'groupId': 'group-1',
        'amount': 42.5,
        'categoryName': 'Food',
        'note': 'Lunch',
      };
      final params = AddExpenseFunctionParams.fromMap(map);

      expect(params.groupId, 'group-1');
      expect(params.amount, 42.5);
      expect(params.categoryName, 'Food');
      expect(params.note, 'Lunch');
    });

    test('fromMap handles missing optional fields', () {
      final map = {'groupId': 'group-2', 'amount': 10.0};
      final params = AddExpenseFunctionParams.fromMap(map);

      expect(params.groupId, 'group-2');
      expect(params.amount, 10.0);
      expect(params.categoryName, isNull);
      expect(params.note, isNull);
    });

    test('toMap round-trips correctly', () {
      const params = AddExpenseFunctionParams(
        groupId: 'g1',
        amount: 99.9,
        categoryName: 'Transport',
        note: 'Taxi',
      );
      final map = params.toMap();
      final restored = AddExpenseFunctionParams.fromMap(map);

      expect(restored.groupId, params.groupId);
      expect(restored.amount, params.amount);
      expect(restored.categoryName, params.categoryName);
      expect(restored.note, params.note);
    });

    test('toMap omits null optional fields', () {
      const params = AddExpenseFunctionParams(groupId: 'g1', amount: 5.0);
      final map = params.toMap();

      expect(map.containsKey('categoryName'), isFalse);
      expect(map.containsKey('note'), isFalse);
    });
  });

  group('ExpenseBalanceResult', () {
    test('fromMap and toMap round-trip', () {
      final map = {
        'groupId': 'g1',
        'groupTitle': 'Trip to Rome',
        'totalBalance': 250.75,
        'currency': '€',
      };
      final result = ExpenseBalanceResult.fromMap(map);

      expect(result.groupId, 'g1');
      expect(result.groupTitle, 'Trip to Rome');
      expect(result.totalBalance, 250.75);
      expect(result.currency, '€');

      final restored = ExpenseBalanceResult.fromMap(result.toMap());
      expect(restored.groupId, result.groupId);
      expect(restored.totalBalance, result.totalBalance);
    });
  });

  group('TodayTotalResult', () {
    test('fromMap and toMap round-trip', () {
      final map = {
        'groupId': 'g2',
        'groupTitle': 'Weekend',
        'todayTotal': 30.0,
        'currency': '\$',
      };
      final result = TodayTotalResult.fromMap(map);

      expect(result.todayTotal, 30.0);
      expect(result.currency, '\$');

      final restored = TodayTotalResult.fromMap(result.toMap());
      expect(restored.todayTotal, result.todayTotal);
    });
  });

  group('RecentExpensesResult', () {
    test('fromMap parses expenses list', () {
      final map = {
        'groupId': 'g3',
        'groupTitle': 'Barcelona',
        'currency': '€',
        'expenses': [
          {
            'id': 'e1',
            'categoryName': 'Food',
            'amount': 15.0,
            'paidByName': 'Alice',
            'date': '2026-03-10T12:00:00.000Z',
            'note': 'Pizza',
          },
          {
            'id': 'e2',
            'categoryName': 'Transport',
            'amount': 8.5,
            'paidByName': 'Bob',
            'date': '2026-03-10T09:00:00.000Z',
          },
        ],
      };
      final result = RecentExpensesResult.fromMap(map);

      expect(result.groupId, 'g3');
      expect(result.expenses.length, 2);
      expect(result.expenses.first.categoryName, 'Food');
      expect(result.expenses.first.note, 'Pizza');
      expect(result.expenses.last.note, isNull);
    });

    test('fromMap handles empty expenses list', () {
      final map = {
        'groupId': 'g4',
        'groupTitle': 'Empty',
        'currency': '€',
        'expenses': <dynamic>[],
      };
      final result = RecentExpensesResult.fromMap(map);
      expect(result.expenses, isEmpty);
    });

    test('toMap round-trip preserves expense count', () {
      final summary = ExpenseSummary(
        id: 'e1',
        categoryName: 'Food',
        amount: 10.0,
        paidByName: 'Alice',
        date: DateTime.parse('2026-03-10T12:00:00.000'),
      );
      final original = RecentExpensesResult(
        groupId: 'g1',
        groupTitle: 'Test',
        currency: '€',
        expenses: [summary],
      );
      final restored = RecentExpensesResult.fromMap(original.toMap());
      expect(restored.expenses.length, 1);
      expect(restored.expenses.first.id, 'e1');
    });
  });
}
