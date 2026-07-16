import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('ExpenseAuthor', () {
    test('serializes and deserializes round-trip', () {
      const author = ExpenseAuthor(
        deviceId: 'device-1',
        deviceName: 'Pixel 7',
        userName: 'Mario',
      );

      final json = author.toJson();
      final deserialized = ExpenseAuthor.fromJson(json);

      expect(deserialized, equals(author));
    });

    test('toJson omits null deviceName/userName', () {
      const author = ExpenseAuthor(deviceId: 'device-1');

      final json = author.toJson();

      expect(json.containsKey('deviceName'), isFalse);
      expect(json.containsKey('userName'), isFalse);
    });

    group('displayName', () {
      test('prefers userName when set', () {
        const author = ExpenseAuthor(
          deviceId: 'device-1',
          deviceName: 'Pixel 7',
          userName: 'Mario',
        );

        expect(author.displayName, equals('Mario'));
      });

      test('falls back to deviceName when userName is null', () {
        const author = ExpenseAuthor(
          deviceId: 'device-1',
          deviceName: 'Pixel 7',
        );

        expect(author.displayName, equals('Pixel 7'));
      });

      test('falls back to deviceName when userName is empty', () {
        const author = ExpenseAuthor(
          deviceId: 'device-1',
          deviceName: 'Pixel 7',
          userName: '',
        );

        expect(author.displayName, equals('Pixel 7'));
      });

      test('is null when neither userName nor deviceName is set', () {
        const author = ExpenseAuthor(deviceId: 'device-1');

        expect(author.displayName, isNull);
      });
    });
  });

  group('ExpenseDetails createdBy/updatedBy', () {
    const author = ExpenseAuthor(
      deviceId: 'device-1',
      deviceName: 'Pixel 7',
      userName: 'Mario',
    );

    ExpenseDetails buildExpense({ExpenseAuthor? createdBy, ExpenseAuthor? updatedBy}) {
      return ExpenseDetails(
        id: 'test-123',
        name: 'Test Expense',
        amount: 100.0,
        paidBy: ExpenseParticipant(name: 'Alice'),
        category: ExpenseCategory(name: 'food'),
        date: DateTime(2024, 1, 1),
        createdBy: createdBy,
        updatedBy: updatedBy,
      );
    }

    test('defaults to null when not provided', () {
      final expense = buildExpense();

      expect(expense.createdBy, isNull);
      expect(expense.updatedBy, isNull);
    });

    test('round-trips through toJson/fromJson', () {
      final expense = buildExpense(createdBy: author, updatedBy: author);

      final json = expense.toJson();
      expect(json['createdBy'], equals(author.toJson()));
      expect(json['updatedBy'], equals(author.toJson()));

      final deserialized = ExpenseDetails.fromJson(json);
      expect(deserialized.createdBy, equals(author));
      expect(deserialized.updatedBy, equals(author));
    });

    test('toJson omits createdBy/updatedBy when null', () {
      final expense = buildExpense();

      final json = expense.toJson();

      expect(json.containsKey('createdBy'), isFalse);
      expect(json.containsKey('updatedBy'), isFalse);
    });

    test('fromJson handles missing createdBy/updatedBy fields', () {
      final json = {
        'id': 'test-123',
        'name': 'Test Expense',
        'amount': 100.0,
        'paidBy': {'name': 'Alice', 'id': 'alice-1'},
        'category': {
          'name': 'food',
          'id': 'food-1',
          'createdAt': '2024-01-01T00:00:00.000',
        },
        'date': '2024-01-01T00:00:00.000',
      };

      final expense = ExpenseDetails.fromJson(json);

      expect(expense.createdBy, isNull);
      expect(expense.updatedBy, isNull);
    });

    test('copyWith preserves createdBy/updatedBy when not specified', () {
      final expense = buildExpense(createdBy: author, updatedBy: author);

      final updated = expense.copyWith(amount: 150.0);

      expect(updated.createdBy, equals(author));
      expect(updated.updatedBy, equals(author));
      expect(updated.amount, equals(150.0));
    });

    test('copyWith can update only updatedBy, preserving createdBy', () {
      const originalAuthor = ExpenseAuthor(deviceId: 'device-1', userName: 'Mario');
      const editorAuthor = ExpenseAuthor(deviceId: 'device-2', userName: 'Luigi');

      final expense = buildExpense(
        createdBy: originalAuthor,
        updatedBy: originalAuthor,
      );

      final edited = expense.copyWith(updatedBy: editorAuthor);

      expect(edited.createdBy, equals(originalAuthor));
      expect(edited.updatedBy, equals(editorAuthor));
    });
  });
}
