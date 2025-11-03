import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

void main() {
  group('Material3Dialog', () {
    testWidgets('renders with basic properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CaravellaThemes.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const Material3Dialog(
                      title: Text('Test Title'),
                      content: Text('Test Content'),
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown with correct content
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Material3DialogActions creates proper buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CaravellaThemes.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  Material3DialogActions.cancel(context, 'Cancel'),
                  Material3DialogActions.primary(context, 'OK'),
                  Material3DialogActions.destructive(context, 'Delete'),
                  Material3DialogActions.secondary(context, 'Maybe'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify button types and text
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Maybe'), findsOneWidget);

      // Verify button types
      expect(find.byType(TextButton), findsNWidgets(2)); // Cancel and Delete
      expect(find.byType(FilledButton), findsOneWidget); // Primary OK
      expect(find.byType(OutlinedButton), findsOneWidget); // Secondary Maybe
    });
  });

  group('Material3Dialogs helper functions', () {
    testWidgets('showConfirmation creates proper dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: CaravellaThemes.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Material3Dialogs.showConfirmation(
                    context,
                    title: 'Confirm Action',
                    content: 'Do you want to continue?',
                    confirmText: 'Yes',
                    cancelText: 'No',
                  );
                },
                child: const Text('Show Confirmation'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show confirmation dialog
      await tester.tap(find.text('Show Confirmation'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog elements
      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Do you want to continue?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });
  });
}
