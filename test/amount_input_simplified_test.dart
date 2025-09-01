import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';
import 'package:io_caravella_egm/data/model/expense_details.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/manager/expense/expense_form/amount_input_widget.dart';

void main() {
  group('AmountInputWidget Integration Tests', () {
    testWidgets('amount input with simplified formatter', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmountInputWidget(
              controller: controller,
              label: 'Amount',
              currency: '€',
            ),
          ),
        ),
      );

      // Find the text field
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);

      // Test basic decimal input
      await tester.enterText(textField, '12.34');
      expect(controller.text, '12.34');

      // Test comma to dot conversion
      await tester.enterText(textField, '45,67');
      expect(controller.text, '45.67');

      // Test invalid characters are filtered
      await tester.enterText(textField, '12a.3b4');
      expect(controller.text, '12.34');

      // Test leading decimal point
      await tester.enterText(textField, '.75');
      expect(controller.text, '0.75');

      // Test multiple decimal points
      await tester.enterText(textField, '12.34.56');
      expect(controller.text, '12.34');

      // Test decimal place limit
      await tester.enterText(textField, '12.999');
      expect(controller.text, '12.99');
    });

    testWidgets('parsing function works correctly', (
      WidgetTester tester,
    ) async {
      // Test the parsing logic that would be used in expense form
      double? parseAmount(String input) {
        if (input.isEmpty) return null;
        return double.tryParse(input);
      }

      expect(parseAmount('12.34'), 12.34);
      expect(parseAmount('45.67'), 45.67);
      expect(parseAmount('0.5'), 0.5);
      expect(parseAmount('0.75'), 0.75);
      expect(parseAmount(''), null);
      expect(parseAmount('123'), 123.0);
      expect(parseAmount('1000'), 1000.0);
    });

    test('end-to-end amount storage and retrieval', () {
      // Test that amounts parsed from input can be properly stored and serialized
      const inputText = '123.45';
      final parsedAmount = double.tryParse(inputText);

      expect(parsedAmount, 123.45);

      // Create an expense with this amount
      final expense = ExpenseDetails(
        category: ExpenseCategory(
          name: 'Test',
          id: 'test-id',
          createdAt: DateTime.now(),
        ),
        amount: parsedAmount,
        paidBy: ExpenseParticipant(name: 'Test User'),
        date: DateTime.now(),
        name: 'Test Expense',
      );

      expect(expense.amount, 123.45);

      // Test JSON serialization/deserialization
      final json = expense.toJson();
      expect(json['amount'], 123.45);

      final reconstructed = ExpenseDetails.fromJson(json);
      expect(reconstructed.amount, 123.45);

      // Test amount formatting for display/export
      expect(expense.amount?.toStringAsFixed(2), '123.45');
      expect(expense.amount?.toString(), '123.45');
    });

    test('handles edge cases for amount parsing', () {
      double? parseAmount(String input) {
        if (input.isEmpty) return null;
        return double.tryParse(input);
      }

      // Test various edge cases
      expect(parseAmount('0'), 0.0);
      expect(parseAmount('0.0'), 0.0);
      expect(parseAmount('0.00'), 0.0);
      expect(parseAmount('1'), 1.0);
      expect(parseAmount('1.0'), 1.0);
      expect(parseAmount('1.00'), 1.0);
      expect(parseAmount('999.99'), 999.99);
      expect(parseAmount('1000.00'), 1000.0);

      // Invalid inputs should return null
      expect(parseAmount('abc'), null);
      expect(parseAmount('12.34.56'), null);
      expect(parseAmount(''), null);
    });
  });
}
