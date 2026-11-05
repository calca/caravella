import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the trailing button and the pill tap apart', (tester) async {
    var pill = 0;
    var trailing = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: FormPill(
              label: '12/11 - 26/11',
              onTap: () => pill++,
              trailingIcon: Icons.close_rounded,
              onTrailingTap: () => trailing++,
              trailingLabel: 'Clear',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    expect((pill, trailing), (0, 1));

    await tester.tap(find.text('12/11 - 26/11'));
    expect((pill, trailing), (1, 1));

    expect(find.bySemanticsLabel('Clear'), findsOneWidget);
  });
}
