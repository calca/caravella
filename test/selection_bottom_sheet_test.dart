import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/widgets/selection_bottom_sheet.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

void main() {
  group('SelectionBottomSheet Tests', () {
    testWidgets('Modal sheet builds correctly with items', (tester) async {
      final testItems = ['Category 1', 'Category 2', 'Category 3'];
      
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: gen.AppLocalizations.localizationsDelegates,
          supportedLocales: gen.AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showSelectionBottomSheet<String>(
                    context: context,
                    items: testItems,
                    selected: null,
                    itemLabel: (item) => item,
                    onAddItemInline: (name) async {
                      // Mock add functionality
                    },
                    addItemHint: 'Add new category',
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to open the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify that the modal opened and contains expected elements
      expect(find.text('Category 1'), findsOneWidget);
      expect(find.text('Category 2'), findsOneWidget);
      expect(find.text('Category 3'), findsOneWidget);
      
      // Verify the add button is present (not the legacy one)
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Modal sheet shows inline add functionality', (tester) async {
      final testItems = ['Category 1'];
      
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: gen.AppLocalizations.localizationsDelegates,
          supportedLocales: gen.AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showSelectionBottomSheet<String>(
                    context: context,
                    items: testItems,
                    selected: null,
                    itemLabel: (item) => item,
                    onAddItemInline: (name) async {
                      // Mock add functionality
                    },
                    addItemHint: 'Add new category',
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to open the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Tap the add button to activate inline adding
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify that the input field appears
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget); // Confirm button
      expect(find.byIcon(Icons.close_outlined), findsOneWidget); // Cancel button
    });

    testWidgets('Modal sheet handles empty items list', (tester) async {
      final testItems = <String>[];
      
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: gen.AppLocalizations.localizationsDelegates,
          supportedLocales: gen.AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await showSelectionBottomSheet<String>(
                    context: context,
                    items: testItems,
                    selected: null,
                    itemLabel: (item) => item,
                    onAddItemInline: (name) async {
                      // Mock add functionality
                    },
                    addItemHint: 'Add new category',
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to open the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify that the modal opened and shows the add button even with no items
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}