import 'package:flutter_test/flutter_test.dart';
import 'package:android_app_functions/android_app_functions.dart';

/// Error paths for the App Functions model parsing and platform gating —
/// the existing `android_app_functions_test.dart` only covers well-formed
/// input. These calls receive whatever an AI agent (or the native Kotlin
/// side) sends over the method channel, so malformed input is a real
/// scenario, not a hypothetical.
void main() {
  group('AddExpenseFunctionParams.fromMap — malformed input', () {
    test('missing groupId throws instead of silently defaulting', () {
      expect(
        () => AddExpenseFunctionParams.fromMap({'amount': 10.0}),
        throwsA(isA<TypeError>()),
      );
    });

    test('missing amount throws instead of silently defaulting', () {
      expect(
        () => AddExpenseFunctionParams.fromMap({'groupId': 'g1'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('ExpenseSummary.fromMap — malformed input', () {
    test('an unparsable date throws FormatException', () {
      final map = {
        'id': 'e1',
        'categoryName': 'Food',
        'paidByName': 'Alice',
        'date': 'not-a-date',
      };

      expect(
        () => ExpenseSummary.fromMap(map),
        throwsFormatException,
      );
    });

    test('a null amount is accepted (pending/draft expenses)', () {
      final summary = ExpenseSummary.fromMap({
        'id': 'e1',
        'categoryName': 'Food',
        'paidByName': 'Alice',
        'date': '2026-03-10T12:00:00.000Z',
      });

      expect(summary.amount, isNull);
    });
  });

  group('RecentExpensesResult.fromMap — malformed input', () {
    test('a missing expenses key defaults to an empty list rather than '
        'throwing', () {
      final result = RecentExpensesResult.fromMap({
        'groupId': 'g1',
        'groupTitle': 'Trip',
        'currency': '€',
      });

      expect(result.expenses, isEmpty);
    });

    test('a malformed entry inside expenses propagates the error', () {
      final map = {
        'groupId': 'g1',
        'groupTitle': 'Trip',
        'currency': '€',
        'expenses': [
          {'id': 'e1', 'categoryName': 'Food', 'paidByName': 'Alice', 'date': 'bad-date'},
        ],
      };

      expect(
        () => RecentExpensesResult.fromMap(map),
        throwsFormatException,
      );
    });
  });

  group('PlatformAppFunctionsManager.initialize — platform gating', () {
    test('is a no-op on non-Android test hosts and never invokes the '
        'callback', () {
      var called = false;

      expect(
        () => PlatformAppFunctionsManager.initialize(
          onAddExpense: (_) => called = true,
        ),
        returnsNormally,
      );
      expect(called, isFalse);
    });
  });
}
