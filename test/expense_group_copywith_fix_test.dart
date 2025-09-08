import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';

void main() {
  group('ExpenseGroup.copyWith Fix Validation', () {
    test('copyWith preserves existing values when parameters not provided', () {
      const originalColor = 0xFFE57373;
      const originalFile = '/path/to/image.jpg';
      
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Group',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        currency: 'EUR',
        color: originalColor,
        file: originalFile,
      );

      // Test 1: copyWith() with no parameters should preserve all values
      final copyWithNoParams = originalGroup.copyWith();
      expect(copyWithNoParams.color, equals(originalColor));
      expect(copyWithNoParams.file, equals(originalFile));
      expect(copyWithNoParams.title, equals('Test Group'));

      // Test 2: copyWith() with some parameters should preserve unspecified values
      final copyWithSomeParams = originalGroup.copyWith(title: 'New Title');
      expect(copyWithSomeParams.color, equals(originalColor));
      expect(copyWithSomeParams.file, equals(originalFile));
      expect(copyWithSomeParams.title, equals('New Title'));
    });

    test('copyWith can explicitly set nullable fields to null', () {
      const originalColor = 0xFFE57373;
      const originalFile = '/path/to/image.jpg';
      
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Group',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        currency: 'EUR',
        color: originalColor,
        file: originalFile,
      );

      // Test: Explicit null values should be respected
      final groupWithNulls = originalGroup.copyWith(
        color: null,
        file: null,
      );
      
      expect(groupWithNulls.color, isNull);
      expect(groupWithNulls.file, isNull);
      expect(groupWithNulls.title, equals('Test Group')); // Other fields preserved
    });

    test('copyWith can set nullable fields to new non-null values', () {
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Group',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        currency: 'EUR',
        color: null,
        file: null,
      );

      const newColor = 0xFF42A5F5;
      const newFile = '/new/path/image.jpg';

      final updatedGroup = originalGroup.copyWith(
        color: newColor,
        file: newFile,
      );
      
      expect(updatedGroup.color, equals(newColor));
      expect(updatedGroup.file, equals(newFile));
    });

    test('copyWith mixed usage works correctly', () {
      const originalColor = 0xFFE57373;
      const originalFile = '/path/to/image.jpg';
      
      final originalGroup = ExpenseGroup(
        id: 'test-id',
        title: 'Test Group',
        participants: [ExpenseParticipant(name: 'Alice')],
        categories: [ExpenseCategory(name: 'Food')],
        expenses: [],
        currency: 'EUR',
        color: originalColor,
        file: originalFile,
      );

      // Test: Keep color, remove file, change title
      final mixedUpdate = originalGroup.copyWith(
        title: 'Updated Title',
        file: null, // Remove file
        // color not specified, should be preserved
      );
      
      expect(mixedUpdate.title, equals('Updated Title'));
      expect(mixedUpdate.file, isNull);
      expect(mixedUpdate.color, equals(originalColor)); // Preserved
    });
  });
}