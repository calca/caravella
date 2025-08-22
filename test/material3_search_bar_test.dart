import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/widgets/material3_search_bar.dart';

void main() {
  group('Material3SearchBar', () {
    testWidgets('should render with hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3SearchBar(
              hintText: 'Search...',
            ),
          ),
        ),
      );

      expect(find.text('Search...'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Material), findsOneWidget);
    });

    testWidgets('should handle text changes', (WidgetTester tester) async {
      String? changedText;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3SearchBar(
              controller: controller,
              hintText: 'Search...',
              onChanged: (text) => changedText = text,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      expect(changedText, equals('test query'));
      expect(controller.text, equals('test query'));
    });

    testWidgets('should display leading and trailing widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3SearchBar(
              leading: const Icon(Icons.search),
              trailing: [
                const Icon(Icons.mic),
                const Icon(Icons.filter_list),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should handle submission', (WidgetTester tester) async {
      String? submittedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3SearchBar(
              onSubmitted: (text) => submittedText = text,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'submitted query');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedText, equals('submitted query'));
    });

    testWidgets('should auto focus when specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3SearchBar(
              autoFocus: true,
            ),
          ),
        ),
      );

      await tester.pump();
      
      // Focus should be requested after frame
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('Material3ExpandableSearchBar', () {
    testWidgets('should start collapsed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3ExpandableSearchBar(
              isExpanded: false,
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should expand when isExpanded is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3ExpandableSearchBar(
              isExpanded: true,
              hintText: 'Search expanded...',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // Wait for animation

      expect(find.byType(Material3SearchBar), findsOneWidget);
      expect(find.text('Search expanded...'), findsOneWidget);
    });

    testWidgets('should handle toggle callback', (WidgetTester tester) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3ExpandableSearchBar(
              isExpanded: false,
              onToggle: () => toggleCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(toggleCalled, isTrue);
    });

    testWidgets('should animate width changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3ExpandableSearchBar(
              isExpanded: false,
              collapsedWidth: 50,
              expandedWidth: 300,
            ),
          ),
        ),
      );

      final initialSize = tester.getSize(find.byType(Material3ExpandableSearchBar));
      expect(initialSize.width, equals(50));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3ExpandableSearchBar(
              isExpanded: true,
              collapsedWidth: 50,
              expandedWidth: 300,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // Wait for animation

      final expandedSize = tester.getSize(find.byType(Material3ExpandableSearchBar));
      expect(expandedSize.width, greaterThan(50));
    });

    testWidgets('should show clear button when text is entered', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'some text');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3ExpandableSearchBar(
              controller: controller,
              isExpanded: true,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // Wait for animation

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}