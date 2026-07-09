import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

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

    testWidgets('FormTheme search pill decoration is configured correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CaravellaThemes.light,
          home: Builder(
            builder: (context) {
              final color = Theme.of(context).colorScheme.surface;
              final decoration = FormTheme.getSearchPillDecoration(
                backgroundColor: color,
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: const Icon(Icons.clear),
              );

              expect(decoration.filled, isTrue);
              expect(decoration.fillColor, equals(color));
              expect(decoration.isDense, isFalse);
              expect(
                decoration.contentPadding,
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              );
              expect(decoration.prefixIcon, isNotNull);
              expect(decoration.suffixIcon, isNotNull);

              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('FormTheme borderless amount decoration is configured correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CaravellaThemes.light,
          home: Builder(
            builder: (context) {
              final style = Theme.of(context).textTheme.bodyLarge;
              final decoration = FormTheme.getBorderlessAmountDecoration(
                hintText: '123.45',
                hintStyle: style,
              );

              expect(decoration.border, equals(InputBorder.none));
              expect(decoration.enabledBorder, equals(InputBorder.none));
              expect(decoration.focusedBorder, equals(InputBorder.none));
              expect(decoration.hintText, equals('123.45'));
              expect(decoration.hintStyle, equals(style));
              expect(decoration.isDense, isFalse);
              expect(
                decoration.contentPadding,
                const EdgeInsets.symmetric(vertical: 4),
              );

              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    test('FormTheme Gmail app bar search background is darker than base', () {
      final lightColor = FormTheme.getGmailAppBarSearchBackground(
        CaravellaThemes.light.colorScheme,
      );
      final darkColor = FormTheme.getGmailAppBarSearchBackground(
        CaravellaThemes.dark.colorScheme,
      );

      expect(
        lightColor.computeLuminance(),
        lessThan(
          CaravellaThemes.light.colorScheme.surfaceContainerHighest
              .computeLuminance(),
        ),
      );
      expect(
        darkColor.computeLuminance(),
        lessThan(
          CaravellaThemes.dark.colorScheme.surfaceContainerHighest
              .computeLuminance(),
        ),
      );
    });
  });
}
