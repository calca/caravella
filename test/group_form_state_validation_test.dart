import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('GroupFormState validation', () {
    test('isValid should be false when title is empty', () {
      final state = GroupFormState();
      state.addParticipant(ExpenseParticipant(name: 'John', id: 'p1'));
      state.addCategory(ExpenseCategory(name: 'Food', id: 'c1'));

      expect(
        state.isValid,
        isFalse,
        reason: 'Empty title should make form invalid',
      );
    });

    test('isValid should be false when participants list is empty', () {
      final state = GroupFormState();
      state.setTitle('Test Group');
      state.addCategory(ExpenseCategory(name: 'Food', id: 'c1'));

      expect(
        state.isValid,
        isFalse,
        reason: 'Empty participants should make form invalid',
      );
    });

    test('isValid should be false when categories list is empty', () {
      final state = GroupFormState();
      state.setTitle('Test Group');
      state.addParticipant(ExpenseParticipant(name: 'John', id: 'p1'));

      expect(
        state.isValid,
        isFalse,
        reason: 'Empty categories should make form invalid',
      );
    });

    test('isValid should be true when all required fields are present', () {
      final state = GroupFormState();
      state.setTitle('Test Group');
      state.addParticipant(ExpenseParticipant(name: 'John', id: 'p1'));
      state.addCategory(ExpenseCategory(name: 'Food', id: 'c1'));

      expect(
        state.isValid,
        isTrue,
        reason: 'All required fields present should make form valid',
      );
    });

    test('isValid should become false when last category is removed', () {
      final state = GroupFormState();
      state.setTitle('Test Group');
      state.addParticipant(ExpenseParticipant(name: 'John', id: 'p1'));
      state.addCategory(ExpenseCategory(name: 'Food', id: 'c1'));

      expect(state.isValid, isTrue);

      state.removeCategory(0);

      expect(
        state.isValid,
        isFalse,
        reason: 'Removing last category should make form invalid',
      );
    });

    test(
      'isValid should remain true when one category remains after removal',
      () {
        final state = GroupFormState();
        state.setTitle('Test Group');
        state.addParticipant(ExpenseParticipant(name: 'John', id: 'p1'));
        state.addCategory(ExpenseCategory(name: 'Food', id: 'c1'));
        state.addCategory(ExpenseCategory(name: 'Transport', id: 'c2'));

        expect(state.isValid, isTrue);

        state.removeCategory(0);

        expect(
          state.isValid,
          isTrue,
          reason: 'At least one category should keep form valid',
        );
        expect(state.categories.length, equals(1));
      },
    );

    test('isValid should handle whitespace-only title', () {
      final state = GroupFormState();
      state.setTitle('   ');
      state.addParticipant(ExpenseParticipant(name: 'John', id: 'p1'));
      state.addCategory(ExpenseCategory(name: 'Food', id: 'c1'));

      expect(
        state.isValid,
        isFalse,
        reason: 'Whitespace-only title should make form invalid',
      );
    });

    test('isValid should handle title with leading/trailing whitespace', () {
      final state = GroupFormState();
      state.setTitle('  Test Group  ');
      state.addParticipant(ExpenseParticipant(name: 'John', id: 'p1'));
      state.addCategory(ExpenseCategory(name: 'Food', id: 'c1'));

      expect(
        state.isValid,
        isTrue,
        reason: 'Title with content should be valid even with whitespace',
      );
    });

    test('isValid should be false when only start date is selected', () {
      final state = GroupFormState();
      state.setTitle('Trip with partial dates');
      state.addParticipant(ExpenseParticipant(name: 'John', id: 'p1'));
      state.addCategory(ExpenseCategory(name: 'Food', id: 'c1'));
      state.setDates(start: DateTime(2024, 1, 1), end: null);

      expect(
        state.isValid,
        isFalse,
        reason: 'Selecting only the start date should keep the form invalid',
      );

      state.setDates(start: DateTime(2024, 1, 1), end: DateTime(2024, 1, 5));

      expect(
        state.isValid,
        isTrue,
        reason: 'Providing both start and end dates should make the form valid',
      );
    });
  });
}
