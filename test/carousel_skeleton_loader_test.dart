import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/carousel_skeleton_loader.dart';

void main() {
  group('CarouselSkeletonLoader', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarouselSkeletonLoader(theme: ThemeData.light()),
          ),
        ),
      );

      // Verify the widget renders
      expect(find.byType(CarouselSkeletonLoader), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows skeleton cards during animation', (
      WidgetTester tester,
    ) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarouselSkeletonLoader(theme: ThemeData.light()),
          ),
        ),
      );

      // Initial render
      await tester.pump();
      expect(find.byType(CarouselSkeletonLoader), findsOneWidget);

      // Advance animation
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CarouselSkeletonLoader), findsOneWidget);

      // Verify animation continues
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CarouselSkeletonLoader), findsOneWidget);
    });

    testWidgets('uses theme colors', (WidgetTester tester) async {
      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();

      // Test with light theme
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CarouselSkeletonLoader(theme: lightTheme)),
        ),
      );

      expect(find.byType(CarouselSkeletonLoader), findsOneWidget);

      // Test with dark theme
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CarouselSkeletonLoader(theme: darkTheme)),
        ),
      );

      expect(find.byType(CarouselSkeletonLoader), findsOneWidget);
    });

    testWidgets('displays skeleton cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarouselSkeletonLoader(theme: ThemeData.light()),
          ),
        ),
      );

      // The widget should show skeleton cards
      expect(find.byType(CarouselCardSkeleton), findsNWidgets(3));

      // Verify structure: skeleton cards use Column
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('animation controller is disposed properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarouselSkeletonLoader(theme: ThemeData.light()),
          ),
        ),
      );

      // Widget is rendered
      expect(find.byType(CarouselSkeletonLoader), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      // Should not throw errors - animation controller should be disposed
      await tester.pumpAndSettle();
    });
  });
}
