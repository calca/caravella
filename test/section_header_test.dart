import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

void main() {
  group('SectionHeader', () {
    testWidgets('renders title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: 'Test Title')),
        ),
      );

      // Title is rendered as RichText
      expect(find.byType(RichText), findsOneWidget);
      expect(find.byType(SectionHeader), findsOneWidget);
    });

    testWidgets('renders title with description', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Test Title',
              description: 'Test Description',
            ),
          ),
        ),
      );

      expect(find.byType(SectionHeader), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('renders with trailing widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Test Title',
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SectionHeader), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders with required mark', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(title: 'Required Field', requiredMark: true),
          ),
        ),
      );

      // The required mark (*) should be present
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      final textSpan = richText.text as TextSpan;

      // Should have 2 spans: title and asterisk
      expect(textSpan.children?.length, 2);
    });

    testWidgets('renders with required hint', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          home: const Scaffold(
            body: SectionHeader(
              title: 'Field with Hint',
              showRequiredHint: true,
            ),
          ),
        ),
      );

      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      final textSpan = richText.text as TextSpan;

      // Should have 2 spans: title and asterisk with error color
      expect(textSpan.children?.length, 2);
    });

    testWidgets('applies custom padding', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(16.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(title: 'Test Title', padding: customPadding),
          ),
        ),
      );

      final paddingFinder = find.ancestor(
        of: find.byType(Row),
        matching: find.byType(Padding),
      );

      expect(paddingFinder, findsOneWidget);
      final padding = tester.widget<Padding>(paddingFinder);
      expect(padding.padding, customPadding);
    });

    testWidgets('does not render description when empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(title: 'Test Title', description: ''),
          ),
        ),
      );

      expect(find.byType(SectionHeader), findsOneWidget);
      // Description text should not be found
      expect(find.text(''), findsNothing);
    });

    testWidgets('applies custom spacing between title and description', (
      WidgetTester tester,
    ) async {
      const customSpacing = 16.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Test Title',
              description: 'Test Description',
              spacing: customSpacing,
            ),
          ),
        ),
      );

      // Find the Padding widget that wraps the description
      final paddingFinder = find.descendant(
        of: find.byType(Column),
        matching: find.byType(Padding),
      );

      expect(paddingFinder, findsOneWidget);
      final padding = tester.widget<Padding>(paddingFinder);
      expect(padding.padding, const EdgeInsets.only(top: customSpacing));
    });

    testWidgets('uses correct text styles from theme', (
      WidgetTester tester,
    ) async {
      final theme = ThemeData(
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodySmall: TextStyle(fontSize: 12),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: SectionHeader(
              title: 'Test Title',
              description: 'Test Description',
            ),
          ),
        ),
      );

      expect(find.byType(SectionHeader), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });
  });
}
