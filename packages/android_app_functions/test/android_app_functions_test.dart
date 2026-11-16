import 'package:android_app_functions/android_app_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddExpenseFunctionParams', () {
    test('fromMap reads the group, category and note', () {
      final params = AddExpenseFunctionParams.fromMap({
        'groupId': 'group-1',
        'groupTitle': 'Norway',
        'categoryName': 'Food',
        'note': 'Lunch',
      });

      expect(params.groupId, 'group-1');
      expect(params.categoryName, 'Food');
      expect(params.note, 'Lunch');
    });

    test('a link with only a category opens the group (no amount needed)', () {
      // What MainActivity sends for an agent's link: never an amount. It used
      // to require one, so such a link failed to open anything.
      final params = AddExpenseFunctionParams.fromMap({
        'groupId': 'group-2',
        'groupTitle': 'Norway',
        'categoryName': 'Transport',
      });

      expect(params.groupId, 'group-2');
      expect(params.categoryName, 'Transport');
      expect(params.note, isNull);
    });

    test('fromMap without a group id throws', () {
      expect(
        () => AddExpenseFunctionParams.fromMap({'note': 'Lunch'}),
        throwsA(isA<TypeError>()),
      );
    });

    test('toMap round-trips and omits what is missing', () {
      const params = AddExpenseFunctionParams(
        groupId: 'g1',
        categoryName: 'Transport',
        note: 'Taxi',
      );
      final restored = AddExpenseFunctionParams.fromMap(params.toMap());
      expect(restored.groupId, 'g1');
      expect(restored.categoryName, 'Transport');
      expect(restored.note, 'Taxi');

      final bare = const AddExpenseFunctionParams(groupId: 'g1').toMap();
      expect(bare.keys, ['groupId']);
    });
  });
}
