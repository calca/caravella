import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/widgets/material3_badge.dart';

void main() {
  group('Material3Badge', () {
    testWidgets('should render badge with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3Badge(
              label: Text('5'),
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.byType(Badge), findsOneWidget);
    });

    testWidgets('should not show badge when showBadge is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3Badge(
              label: Text('5'),
              showBadge: false,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('should create dot badge without label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3Badge.dot(
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byType(Badge), findsOneWidget);
      
      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.label, isNull);
    });

    testWidgets('should create count badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3Badge.count(
              count: 10,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byType(Badge), findsOneWidget);
    });
  });

  group('Material3NotificationBadge', () {
    testWidgets('should display count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3NotificationBadge(
              count: 5,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('should display 99+ for large counts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3NotificationBadge(
              count: 150,
              maxCount: 99,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('should not show for zero count by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3NotificationBadge(
              count: 0,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byType(Material3Badge), findsOneWidget);
      
      // Badge should be configured to not show
      final badge = tester.widget<Material3Badge>(find.byType(Material3Badge));
      expect(badge.showBadge, isFalse);
    });

    testWidgets('should show zero when showZero is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3NotificationBadge(
              count: 0,
              showZero: true,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });
  });

  group('Material3StatusBadge', () {
    testWidgets('should display error status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3StatusBadge(
              status: BadgeStatus.error,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('!'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('should display success status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3StatusBadge(
              status: BadgeStatus.success,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('✓'), findsOneWidget);
    });

    testWidgets('should display custom text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3StatusBadge(
              status: BadgeStatus.info,
              customText: 'CUSTOM',
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('CUSTOM'), findsOneWidget);
    });

    testWidgets('should display new status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3StatusBadge(
              status: BadgeStatus.new_,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
    });
  });

  group('Material3AnimatedBadge', () {
    testWidgets('should animate badge appearance', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3AnimatedBadge(
              label: Text('5'),
              showBadge: false,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      
      // Badge should not be visible initially
      final initialBadge = tester.widget<Material3Badge>(find.byType(Material3Badge));
      expect(initialBadge.showBadge, isFalse);

      // Update to show badge
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3AnimatedBadge(
              label: Text('5'),
              showBadge: true,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250)); // Wait for animation

      // Badge should become visible
      expect(find.byType(Transform), findsOneWidget);
    });

    testWidgets('should handle animation duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3AnimatedBadge(
              label: Text('5'),
              showBadge: true,
              duration: Duration(milliseconds: 500),
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Animation should still be in progress
      expect(find.byType(Transform), findsOneWidget);
    });
  });

  group('BadgeStatus enum', () {
    test('should have all expected values', () {
      expect(BadgeStatus.values, contains(BadgeStatus.error));
      expect(BadgeStatus.values, contains(BadgeStatus.warning));
      expect(BadgeStatus.values, contains(BadgeStatus.success));
      expect(BadgeStatus.values, contains(BadgeStatus.info));
      expect(BadgeStatus.values, contains(BadgeStatus.new_));
      expect(BadgeStatus.values.length, equals(5));
    });
  });
}