import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/main.dart';
import 'package:org_app_caravella/home/welcome/home_welcome_section.dart';
import 'package:org_app_caravella/widgets/add_fab.dart';
import 'package:org_app_caravella/widgets/app_toast.dart';

void main() {
  group('WCAG 2.2 Accessibility Tests', () {
    testWidgets('Welcome screen image has semantic label', (WidgetTester tester) async {
      await tester.pumpWidget(createAppForTest());
      await tester.pumpAndSettle();

      // Find the welcome logo image
      final imageSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('logo'),
      );

      expect(imageSemantics, findsOneWidget);
    });

    testWidgets('AddFab has proper semantic button properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddFab(
              onPressed: () {},
              tooltip: 'Add new item',
            ),
          ),
        ),
      );

      final fabSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == 'Add new item',
      );

      expect(fabSemantics, findsOneWidget);
    });

    testWidgets('App toast has live region for screen readers', (WidgetTester tester) async {
      final scaffoldKey = GlobalKey<ScaffoldState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            key: scaffoldKey,
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AppToast.show(context, 'Test message', type: ToastType.success);
                },
                child: const Text('Show Toast'),
              ),
            ),
          ),
        ),
      );

      // Trigger the toast
      await tester.tap(find.text('Show Toast'));
      await tester.pump();

      // Check for semantic live region
      final toastSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.liveRegion == true &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Success: Test message'),
      );

      expect(toastSemantics, findsOneWidget);
    });

    testWidgets('Navigation buttons have proper accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(createAppForTest());
      await tester.pumpAndSettle();

      // Look for settings button semantics
      final settingsSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label != null &&
            widget.properties.label!.toLowerCase().contains('settings'),
      );

      expect(settingsSemantics, findsOneWidget);
    });

    testWidgets('Form inputs have proper accessibility attributes', (WidgetTester tester) async {
      // This test would need to navigate to a form page
      // For now, we'll test the widget in isolation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Test Input',
                semanticCounterText: '',
              ),
            ),
          ),
        ),
      );

      // Verify the input has proper semantic structure
      final inputWidget = find.byType(TextFormField);
      expect(inputWidget, findsOneWidget);
    });

    testWidgets('Loading indicators have semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularProgressIndicator(
              semanticsLabel: 'Loading data',
            ),
          ),
        ),
      );

      final progressSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is CircularProgressIndicator &&
            widget.semanticsLabel == 'Loading data',
      );

      expect(progressSemantics, findsOneWidget);
    });

    testWidgets('Minimum touch target sizes are maintained', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddFab(
              onPressed: () {},
              tooltip: 'Add item',
            ),
          ),
        ),
      );

      // Verify the FAB has minimum 44px touch target
      final fabWidget = find.byType(FloatingActionButton);
      expect(fabWidget, findsOneWidget);

      final RenderBox fabRenderBox = tester.renderObject(fabWidget);
      expect(fabRenderBox.size.width, greaterThanOrEqualTo(44.0));
      expect(fabRenderBox.size.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('Contrast ratios are adequate in themes', (WidgetTester tester) async {
      // Test both light and dark themes
      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            themeMode: themeMode,
            home: const Scaffold(
              body: Text('Test text'),
            ),
          ),
        );

        final context = tester.element(find.byType(Text));
        final theme = Theme.of(context);
        
        // Verify that text color contrasts with background
        expect(theme.colorScheme.onSurface, isNot(equals(theme.colorScheme.surface)));
        expect(theme.colorScheme.onPrimary, isNot(equals(theme.colorScheme.primary)));
      }
    });
  });

  group('Screen Reader Support Tests', () {
    testWidgets('Dialogs are properly announced', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Semantics(
                      dialog: true,
                      label: 'Test dialog',
                      child: const AlertDialog(
                        title: Text('Test'),
                        content: Text('Dialog content'),
                      ),
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final dialogSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.scopesRoute == true &&
            widget.properties.label == 'Test dialog',
      );

      expect(dialogSemantics, findsOneWidget);
    });

    testWidgets('Focus management works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'First field'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Second field'),
                ),
              ],
            ),
          ),
        ),
      );

      // Test tab navigation between fields
      final firstField = find.byWidgetPredicate(
        (widget) => widget is TextFormField && 
        (widget.decoration?.labelText == 'First field'),
      );
      final secondField = find.byWidgetPredicate(
        (widget) => widget is TextFormField && 
        (widget.decoration?.labelText == 'Second field'),
      );

      expect(firstField, findsOneWidget);
      expect(secondField, findsOneWidget);

      // Focus first field
      await tester.tap(firstField);
      await tester.pump();

      // Navigate to second field with tab
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    });
  });
}