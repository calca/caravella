import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The round "+" at the end of an add field is a small circle inside the
/// field, not a tall stadium stretched to the field's height.
void main() {
  testWidgets('a 36dp circle inside the field, 48dp to tap', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: CaravellaThemes.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                final s = Theme.of(context).colorScheme;
                return TextField(
                  decoration:
                      FormTheme.getCardDecoration(
                        fillColor: s.surface,
                        borderColor: s.outline,
                        focusColor: s.primary,
                        errorColor: s.error,
                        hintText: 'A friend’s name',
                      ).copyWith(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FieldActionButton(
                            icon: Icons.add_rounded,
                            tooltip: 'Add',
                            onPressed: () {},
                          ),
                        ),
                      ),
                );
              },
            ),
          ),
        ),
      ),
    );

    final circle = find.descendant(
      of: find.byType(IconButton),
      matching: find.byType(Material),
    );
    expect(tester.getSize(circle.first), const Size(36, 36));
    final field = tester.getRect(find.byType(TextField));
    final circleRect = tester.getRect(circle.first);
    expect(circleRect.top, greaterThan(field.top + 4));
    expect(circleRect.bottom, lessThan(field.bottom - 4));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });
}
