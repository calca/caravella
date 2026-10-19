import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('draws a hairline over the card in $brightness', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: CardOutline(
            borderRadius: BorderRadius.circular(24),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(CardOutline),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(box.position, DecorationPosition.foreground);
      final border = (box.decoration as BoxDecoration).border as Border;
      expect(border.top.color, CardOutline.colorFor(brightness));
    });
  }
}
