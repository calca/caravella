import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('Storage Errors', () {
    test('FileOperationError should format correctly', () {
      final error = FileOperationError(
        'Failed to read file',
        details: 'Permission denied',
        cause: Exception('Access denied'),
      );

      expect(error.toString(), contains('FileOperationError'));
      expect(error.toString(), contains('Failed to read file'));
      expect(error.toString(), contains('Permission denied'));
    });

    test('ValidationError should include field errors', () {
      final error = ValidationError(
        'Validation failed',
        fieldErrors: {'name': 'Required', 'amount': 'Must be positive'},
      );

      expect(error.toString(), contains('ValidationError'));
      expect(error.toString(), contains('name: Required'));
      expect(error.toString(), contains('amount: Must be positive'));
    });

    test('EntityNotFoundError should format correctly', () {
      final error = EntityNotFoundError('ExpenseGroup', 'test-id');

      expect(
        error.toString(),
        contains('ExpenseGroup with id "test-id" not found'),
      );
    });
  });

  group('StorageResult', () {
    test('success result should work correctly', () {
      final result = StorageResult.success('test data');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, equals('test data'));
      expect(result.error, isNull);
      expect(result.unwrap(), equals('test data'));
      expect(result.unwrapOr('fallback'), equals('test data'));
    });

    test('failure result should work correctly', () {
      final error = ValidationError('Test error');
      final result = StorageResult<String>.failure(error);

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.data, isNull);
      expect(result.error, equals(error));
      expect(result.unwrapOr('fallback'), equals('fallback'));

      expect(() => result.unwrap(), throwsA(isA<ValidationError>()));
    });

    test('map should transform success values', () {
      final result = StorageResult.success(5);
      final mapped = result.map<String>((value) => 'Value: $value');

      expect(mapped.isSuccess, isTrue);
      expect(mapped.unwrap(), equals('Value: 5'));
    });

    test('map should preserve failure', () {
      final error = ValidationError('Test error');
      final result = StorageResult<int>.failure(error);
      final mapped = result.map<String>((value) => 'Value: $value');

      expect(mapped.isFailure, isTrue);
      expect(mapped.error, equals(error));
    });
  });

  group('ExpenseGroupValidator', () {
    late ExpenseGroup validGroup;
    late ExpenseParticipant participant1;
    late ExpenseParticipant participant2;
    late ExpenseCategory category;

    setUp(() {
      participant1 = ExpenseParticipant(name: 'John', id: 'p1');
      participant2 = ExpenseParticipant(name: 'Jane', id: 'p2');
      category = ExpenseCategory(name: 'Food', id: 'c1');

      validGroup = ExpenseGroup(
        id: 'group1',
        title: 'Test Group',
        currency: 'USD',
        participants: [participant1, participant2],
        categories: [category],
        expenses: [
          ExpenseDetails(
            id: 'e1',
            category: category,
            amount: 50.0,
            paidBy: participant1,
            date: DateTime.now(),
            name: 'Lunch',
          ),
        ],
        timestamp: DateTime.now(),
      );
    });

    test('should validate a correct group', () {
      final result = ExpenseGroupValidator.validate(validGroup);
      expect(result.isSuccess, isTrue);
    });

    test('should reject empty title', () {
      final invalidGroup = validGroup.copyWith(title: '');
      final result = ExpenseGroupValidator.validate(invalidGroup);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationError>());
      final error = result.error as ValidationError;
      expect(error.fieldErrors!['title'], contains('empty'));
    });

    test('should reject empty currency', () {
      final invalidGroup = validGroup.copyWith(currency: '');
      final result = ExpenseGroupValidator.validate(invalidGroup);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationError>());
      final error = result.error as ValidationError;
      expect(error.fieldErrors!['currency'], contains('empty'));
    });

    test('should reject invalid date range', () {
      final startDate = DateTime.now();
      final endDate = startDate.subtract(const Duration(days: 1));

      final invalidGroup = validGroup.copyWith(
        startDate: startDate,
        endDate: endDate,
      );

      final result = ExpenseGroupValidator.validate(invalidGroup);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationError>());
      final error = result.error as ValidationError;
      expect(
        error.fieldErrors!['dates'],
        contains('Start date cannot be after end date'),
      );
    });

    test('should reject duplicate participant IDs', () {
      final duplicateParticipant = ExpenseParticipant(
        name: 'Duplicate',
        id: 'p1',
      ); // Same ID as participant1
      final invalidGroup = validGroup.copyWith(
        participants: [participant1, participant2, duplicateParticipant],
      );

      final result = ExpenseGroupValidator.validate(invalidGroup);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationError>());
      final error = result.error as ValidationError;
      expect(
        error.fieldErrors!['participants'],
        contains('Duplicate participant IDs'),
      );
    });

    test('should reject empty participant name', () {
      final emptyParticipant = ExpenseParticipant(name: '', id: 'p3');
      final invalidGroup = validGroup.copyWith(
        participants: [participant1, emptyParticipant],
      );

      final result = ExpenseGroupValidator.validate(invalidGroup);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationError>());
      final error = result.error as ValidationError;
      expect(error.fieldErrors!['participants'], contains('cannot be empty'));
    });

    test('should reject duplicate category IDs', () {
      final duplicateCategory = ExpenseCategory(
        name: 'Duplicate',
        id: 'c1',
      ); // Same ID as category
      final invalidGroup = validGroup.copyWith(
        categories: [category, duplicateCategory],
      );

      final result = ExpenseGroupValidator.validate(invalidGroup);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationError>());
      final error = result.error as ValidationError;
      expect(
        error.fieldErrors!['categories'],
        contains('Duplicate category IDs'),
      );
    });

    test('should reject negative expense amount', () {
      final invalidExpense = ExpenseDetails(
        id: 'e2',
        category: category,
        amount: -10.0,
        paidBy: participant1,
        date: DateTime.now(),
        name: 'Invalid',
      );

      final invalidGroup = validGroup.copyWith(expenses: [invalidExpense]);

      final result = ExpenseGroupValidator.validate(invalidGroup);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationError>());
      final error = result.error as ValidationError;
      expect(error.fieldErrors!['expense_0'], contains('must be positive'));
    });

    test('should reject expense with non-existent participant', () {
      final unknownParticipant = ExpenseParticipant(
        name: 'Unknown',
        id: 'unknown',
      );
      final invalidExpense = ExpenseDetails(
        id: 'e2',
        category: category,
        amount: 10.0,
        paidBy: unknownParticipant,
        date: DateTime.now(),
        name: 'Invalid',
      );

      final invalidGroup = validGroup.copyWith(expenses: [invalidExpense]);

      final result = ExpenseGroupValidator.validate(invalidGroup);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationError>());
      final error = result.error as ValidationError;
      expect(
        error.fieldErrors!['expense_0'],
        contains('non-existent participant'),
      );
    });

    test('should reject expense with non-existent category', () {
      final unknownCategory = ExpenseCategory(name: 'Unknown', id: 'unknown');
      final invalidExpense = ExpenseDetails(
        id: 'e2',
        category: unknownCategory,
        amount: 10.0,
        paidBy: participant1,
        date: DateTime.now(),
        name: 'Invalid',
      );

      final invalidGroup = validGroup.copyWith(expenses: [invalidExpense]);

      final result = ExpenseGroupValidator.validate(invalidGroup);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<ValidationError>());
      final error = result.error as ValidationError;
      expect(
        error.fieldErrors!['expense_0'],
        contains('non-existent category'),
      );
    });
  });

  group('Data Integrity Validation', () {
    test('should detect duplicate group IDs', () {
      final group1 = ExpenseGroup(
        id: 'duplicate-id',
        title: 'Group 1',
        currency: 'USD',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
      );

      final group2 = ExpenseGroup(
        id: 'duplicate-id', // Same ID!
        title: 'Group 2',
        currency: 'USD',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
      );

      final result = ExpenseGroupValidator.validateDataIntegrity([
        group1,
        group2,
      ]);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<DataIntegrityError>());
      final error = result.error as DataIntegrityError;
      expect(error.details, contains('Duplicate group IDs found'));
    });

    test('should detect multiple pinned groups', () {
      final group1 = ExpenseGroup(
        id: 'group1',
        title: 'Group 1',
        currency: 'USD',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
        pinned: true,
        archived: false,
      );

      final group2 = ExpenseGroup(
        id: 'group2',
        title: 'Group 2',
        currency: 'USD',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
        pinned: true,
        archived: false,
      );

      final result = ExpenseGroupValidator.validateDataIntegrity([
        group1,
        group2,
      ]);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<DataIntegrityError>());
      final error = result.error as DataIntegrityError;
      expect(error.details, contains('Multiple groups are pinned'));
    });

    test('should allow multiple pinned groups if they are archived', () {
      final group1 = ExpenseGroup(
        id: 'group1',
        title: 'Group 1',
        currency: 'USD',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
        pinned: true,
        archived: true, // Archived
      );

      final group2 = ExpenseGroup(
        id: 'group2',
        title: 'Group 2',
        currency: 'USD',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
        pinned: true,
        archived: false, // Active
      );

      final result = ExpenseGroupValidator.validateDataIntegrity([
        group1,
        group2,
      ]);

      // Still valid: only one active pinned group
      expect(result.isSuccess, isTrue);
      final issues = result.unwrap();
      expect(
        issues.any((issue) => issue.contains('Multiple groups are pinned')),
        isFalse,
      );
    });

    test('should detect individual group validation errors', () {
      final invalidGroup = ExpenseGroup(
        id: 'invalid',
        title: '', // Empty title
        currency: 'USD',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
      );

      final result = ExpenseGroupValidator.validateDataIntegrity([
        invalidGroup,
      ]);

      expect(result.isFailure, isTrue);
      expect(result.error, isA<DataIntegrityError>());
      final error = result.error as DataIntegrityError;
      expect(error.details, contains('Group "'));
      expect(error.details, contains('invalid'));
    });

    test('should pass for valid data', () {
      final group1 = ExpenseGroup(
        id: 'group1',
        title: 'Group 1',
        currency: 'USD',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
        pinned: true,
      );

      final group2 = ExpenseGroup(
        id: 'group2',
        title: 'Group 2',
        currency: 'USD',
        participants: [],
        categories: [],
        expenses: [],
        timestamp: DateTime.now(),
        pinned: false,
      );

      final result = ExpenseGroupValidator.validateDataIntegrity([
        group1,
        group2,
      ]);

      expect(result.isSuccess, isTrue);
      final issues = result.unwrap();
      expect(issues, isEmpty);
    });
  });
}
