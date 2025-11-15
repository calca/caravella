import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('ExpenseDetails attachments', () {
    test('creates expense with empty attachments by default', () {
      final expense = ExpenseDetails(
        name: 'Test Expense',
        amount: 100.0,
        paidBy: ExpenseParticipant(name: 'Alice'),
        category: ExpenseCategory(name: 'food'),
        date: DateTime.now(),
      );

      expect(expense.attachments, isEmpty);
    });

    test('creates expense with provided attachments', () {
      final attachments = [
        '/path/to/image1.jpg',
        '/path/to/image2.png',
      ];
      
      final expense = ExpenseDetails(
        name: 'Test Expense',
        amount: 100.0,
        paidBy: ExpenseParticipant(name: 'Alice'),
        category: ExpenseCategory(name: 'food'),
        date: DateTime.now(),
        attachments: attachments,
      );

      expect(expense.attachments, equals(attachments));
      expect(expense.attachments.length, equals(2));
    });

    test('serializes and deserializes attachments correctly', () {
      final attachments = [
        '/path/to/image1.jpg',
        '/path/to/document.pdf',
        '/path/to/video.mp4',
      ];
      
      final expense = ExpenseDetails(
        id: 'test-123',
        name: 'Test Expense',
        amount: 100.0,
        paidBy: ExpenseParticipant(name: 'Alice'),
        category: ExpenseCategory(name: 'food'),
        date: DateTime(2024, 1, 1),
        attachments: attachments,
      );

      final json = expense.toJson();
      expect(json['attachments'], equals(attachments));

      final deserialized = ExpenseDetails.fromJson(json);
      expect(deserialized.attachments, equals(attachments));
      expect(deserialized.attachments.length, equals(3));
    });

    test('toJson omits attachments when empty', () {
      final expense = ExpenseDetails(
        name: 'Test Expense',
        amount: 100.0,
        paidBy: ExpenseParticipant(name: 'Alice'),
        category: ExpenseCategory(name: 'food'),
        date: DateTime.now(),
      );

      final json = expense.toJson();
      expect(json.containsKey('attachments'), isFalse);
    });

    test('fromJson handles missing attachments field', () {
      final json = {
        'id': 'test-123',
        'name': 'Test Expense',
        'amount': 100.0,
        'paidBy': {'name': 'Alice', 'id': 'alice-1'},
        'category': {'name': 'food', 'id': 'food-1', 'createdAt': '2024-01-01T00:00:00.000'},
        'date': '2024-01-01T00:00:00.000',
      };

      final expense = ExpenseDetails.fromJson(json);
      expect(expense.attachments, isEmpty);
    });

    test('copyWith preserves attachments when not specified', () {
      final attachments = ['/path/to/image.jpg'];
      
      final expense = ExpenseDetails(
        name: 'Test Expense',
        amount: 100.0,
        paidBy: ExpenseParticipant(name: 'Alice'),
        category: ExpenseCategory(name: 'food'),
        date: DateTime.now(),
        attachments: attachments,
      );

      final updated = expense.copyWith(amount: 150.0);
      expect(updated.attachments, equals(attachments));
      expect(updated.amount, equals(150.0));
    });

    test('copyWith can update attachments', () {
      final originalAttachments = ['/path/to/image1.jpg'];
      final newAttachments = [
        '/path/to/image1.jpg',
        '/path/to/image2.jpg',
      ];
      
      final expense = ExpenseDetails(
        name: 'Test Expense',
        amount: 100.0,
        paidBy: ExpenseParticipant(name: 'Alice'),
        category: ExpenseCategory(name: 'food'),
        date: DateTime.now(),
        attachments: originalAttachments,
      );

      final updated = expense.copyWith(attachments: newAttachments);
      expect(updated.attachments, equals(newAttachments));
      expect(updated.attachments.length, equals(2));
    });

    test('copyWith can clear attachments', () {
      final attachments = ['/path/to/image.jpg'];
      
      final expense = ExpenseDetails(
        name: 'Test Expense',
        amount: 100.0,
        paidBy: ExpenseParticipant(name: 'Alice'),
        category: ExpenseCategory(name: 'food'),
        date: DateTime.now(),
        attachments: attachments,
      );

      final updated = expense.copyWith(attachments: []);
      expect(updated.attachments, isEmpty);
    });

    test('attachments list is independent between instances', () {
      final attachments = ['/path/to/image.jpg'];
      
      final expense1 = ExpenseDetails(
        name: 'Test Expense 1',
        amount: 100.0,
        paidBy: ExpenseParticipant(name: 'Alice'),
        category: ExpenseCategory(name: 'food'),
        date: DateTime.now(),
        attachments: attachments,
      );

      final expense2 = expense1.copyWith(name: 'Test Expense 2');
      
      // Modifying the source list should not affect the copied expense
      attachments.add('/path/to/image2.jpg');
      
      expect(expense1.attachments.length, equals(1));
      expect(expense2.attachments.length, equals(1));
    });
  });
}
