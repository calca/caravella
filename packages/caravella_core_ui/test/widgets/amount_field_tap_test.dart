import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The amount field is only as wide as its digits: a tap anywhere on its
/// line (on "€", beside a short amount) focuses it too.
void main() {
  testWidgets('a tap beside the digits focuses the field', (tester) async {
    final controller = TextEditingController(text: '5');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: AmountField(
              controller: controller,
              currency: '€',
              label: 'Amount',
              currencyAfter: true,
            ),
          ),
        ),
      ),
    );
    expect(tester.testTextInput.hasAnyClients, isFalse);
    // Far right of the line, past the digits and the currency.
    final line = tester.getRect(find.byType(AmountField));
    await tester.tapAt(Offset(line.right - 10, line.center.dy));
    await tester.pump();
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.focusNode.hasFocus, isTrue);
  });
}
