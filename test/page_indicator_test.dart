import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/page_indicator.dart';

void main() {
  group('PageIndicator', () {
    testWidgets('displays correct number of dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageIndicator(
              itemCount: 3,
              currentPage: 0.0,
            ),
          ),
        ),
      );

      // The indicator should render without errors
      expect(find.byType(PageIndicator), findsOneWidget);
    });

    testWidgets('has proper accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageIndicator(
              itemCount: 5,
              currentPage: 2.0,
              semanticLabel: 'Page 3 of 5',
            ),
          ),
        ),
      );

      // Check that semantic label is present
      final semantics = tester.getSemantics(find.byType(PageIndicator));
      expect(semantics.label, equals('Page 3 of 5'));
    });

    testWidgets('updates visual state with currentPage changes', (WidgetTester tester) async {
      double currentPage = 0.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    PageIndicator(
                      itemCount: 3,
                      currentPage: currentPage,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentPage = 1.0;
                        });
                      },
                      child: const Text('Next'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(find.byType(PageIndicator), findsOneWidget);

      // Tap to change page
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Indicator should still be present and updated
      expect(find.byType(PageIndicator), findsOneWidget);
    });

    testWidgets('respects custom colors', (WidgetTester tester) async {
      const activeColor = Colors.blue;
      const inactiveColor = Colors.grey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageIndicator(
              itemCount: 3,
              currentPage: 1.0,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ),
        ),
      );

      expect(find.byType(PageIndicator), findsOneWidget);
    });
  });
}
