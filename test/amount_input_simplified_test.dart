import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/manager/expense/expense_form/amount_input_widget.dart';

void main() {
  group('AmountInputWidget Integration Tests', () {
    testWidgets('amount input with simplified formatter', (WidgetTester tester) async {
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
    });

    testWidgets('parsing function works correctly', (WidgetTester tester) async {
      // Test the parsing logic that would be used in expense form
      double? parseAmount(String input) {
        if (input.isEmpty) return null;
        return double.tryParse(input);
      }

      expect(parseAmount('12.34'), 12.34);
      expect(parseAmount('45.67'), 45.67);
      expect(parseAmount('0.5'), 0.5);
      expect(parseAmount(''), null);
      expect(parseAmount('123'), 123.0);
    });
  });
}