import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('Participant and Category ID Preservation', () {
    test('ExpenseParticipant copyWith preserves ID when updating name', () {
      // Create a participant with a specific name
      final originalParticipant = ExpenseParticipant(name: 'John Doe');
      final originalId = originalParticipant.id;
      final originalCreatedAt = originalParticipant.createdAt;

      // Update the name using copyWith (simulating the fix)
      final updatedParticipant = originalParticipant.copyWith(
        name: 'John Smith',
      );

      // Verify the ID is preserved but name is updated
      expect(updatedParticipant.id, equals(originalId));
      expect(updatedParticipant.name, equals('John Smith'));
      expect(updatedParticipant.createdAt, equals(originalCreatedAt));
    });

    test('ExpenseCategory copyWith preserves ID when updating name', () {
      // Create a category with a specific name
      final originalCategory = ExpenseCategory(name: 'Food');
      final originalId = originalCategory.id;
      final originalCreatedAt = originalCategory.createdAt;

      // Update the name using copyWith (simulating the fix)
      final updatedCategory = originalCategory.copyWith(name: 'Meals');

      // Verify the ID is preserved but name is updated
      expect(updatedCategory.id, equals(originalId));
      expect(updatedCategory.name, equals('Meals'));
      expect(updatedCategory.createdAt, equals(originalCreatedAt));
    });

    test('Creating new ExpenseParticipant generates new ID', () {
      // Create two participants with the same name
      final participant1 = ExpenseParticipant(name: 'John Doe');
      final participant2 = ExpenseParticipant(name: 'John Doe');

      // Verify they have different IDs
      expect(participant1.id, isNot(equals(participant2.id)));
      expect(participant1.name, equals(participant2.name));
    });

    test('ExpenseParticipant equality is based on ID, not name', () {
      // Create a participant
      final participant = ExpenseParticipant(name: 'John Doe');

      // Update the name
      final updatedParticipant = participant.copyWith(name: 'John Smith');

      // They should be equal (same ID) even though names are different
      expect(participant, equals(updatedParticipant));
      expect(participant.hashCode, equals(updatedParticipant.hashCode));
    });
  });
}
