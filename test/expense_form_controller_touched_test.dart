import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/expense/state/expense_form_controller.dart';
import 'package:io_caravella_egm/manager/expense/state/expense_form_state.dart';

void main() {
  group('ExpenseFormController touched state', () {
    late ExpenseFormController controller;

    setUp(() {
      controller = ExpenseFormController(
        initialState: ExpenseFormState.initial(
          participants: [ExpenseParticipant(id: '1', name: 'Alice')],
          categories: [
            ExpenseCategory(id: 'c1', name: 'Food', createdAt: DateTime(2024)),
          ],
        ),
        categories: [
          ExpenseCategory(id: 'c1', name: 'Food', createdAt: DateTime(2024)),
        ],
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets(
      'amount field is not touched merely by gaining focus (autofocus)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(
                    key: const Key('amount'),
                    focusNode: controller.amountFocus,
                  ),
                  TextField(
                    key: const Key('name'),
                    focusNode: controller.nameFocus,
                  ),
                ],
              ),
            ),
          ),
        );

        // Simulate autofocus on the amount field when the form opens.
        controller.amountFocus.requestFocus();
        await tester.pumpAndSettle();

        expect(
          controller.amountTouched,
          isFalse,
          reason:
              'Gaining focus alone must not mark the field as touched, '
              'otherwise autofocus would immediately show error styling.',
        );

        // Moving focus away (blur) should mark the amount field as touched.
        controller.nameFocus.requestFocus();
        await tester.pumpAndSettle();

        expect(controller.amountTouched, isTrue);
      },
    );

    testWidgets('name and amount touched states are independent', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  key: const Key('amount'),
                  focusNode: controller.amountFocus,
                ),
                TextField(
                  key: const Key('name'),
                  focusNode: controller.nameFocus,
                ),
              ],
            ),
          ),
        ),
      );

      controller.amountFocus.requestFocus();
      await tester.pumpAndSettle();
      controller.nameFocus.requestFocus();
      await tester.pumpAndSettle();

      // Blurring the amount field must not affect the name field's touched
      // state (previously both fields shared the same `amountTouched` flag).
      expect(controller.amountTouched, isTrue);
      expect(controller.nameTouched, isFalse);
    });
  });
}
