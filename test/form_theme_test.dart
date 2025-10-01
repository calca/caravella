import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/themes/form_theme.dart';
import 'package:io_caravella_egm/themes/caravella_themes.dart';

void main() {
  group('FormTheme', () {
    testWidgets('FormTheme constants are properly defined', (tester) async {
      // Test that all constants are accessible and have expected values
      expect(FormTheme.fieldVerticalPadding, 8.0);
      expect(FormTheme.fieldHorizontalPadding, 0.0);
      expect(FormTheme.iconSpacing, 6.0);
      expect(FormTheme.fieldSpacing, 16.0);
      expect(FormTheme.sectionSpacing, 24.0);

      expect(
        FormTheme.standardContentPadding,
        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      );
      expect(
        FormTheme.standardIconPadding,
        const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 6.0),
      );
      expect(
        FormTheme.topAlignedIconPadding,
        const EdgeInsets.only(top: 8.0, bottom: 0.0, right: 6.0),
      );
    });

    testWidgets('FormTheme text styles work correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CaravellaThemes.light,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Test that text style methods don't throw and return valid styles
                final fieldStyle = FormTheme.getFieldTextStyle(context);
                final amountStyle = FormTheme.getAmountTextStyle(context);
                final selectStyle = FormTheme.getSelectTextStyle(context);
                final multilineStyle = FormTheme.getMultilineTextStyle(context);

                expect(fieldStyle, isNotNull);
                expect(amountStyle, isNotNull);
                expect(selectStyle, isNotNull);
                expect(multilineStyle, isNotNull);

                return const Text('Test');
              },
            ),
          ),
        ),
      );
    });

    testWidgets('FormTheme decorations work correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CaravellaThemes.light,
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  decoration: FormTheme.getStandardDecoration(
                    hintText: 'Standard field',
                  ),
                ),
                TextField(
                  decoration: FormTheme.getMultilineDecoration(
                    hintText: 'Multiline field',
                  ),
                  maxLines: 3,
                ),
                TextField(
                  decoration: FormTheme.getBorderlessDecoration(
                    hintText: 'Borderless field',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify the widgets render without error
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNWidgets(3));
    });
  });
}
