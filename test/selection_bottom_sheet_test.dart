import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

void main() {
  group('SelectionBottomSheet Tests', () {
    testWidgets(
      'should update participants list in real-time when new participant is added',
      (tester) async {
        List<String> participants = ['Alice', 'Bob'];
        String? selectedParticipant;
        String? addedParticipant;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: gen.AppLocalizations.localizationsDelegates,
            supportedLocales: gen.AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    final result = await showSelectionBottomSheet<String>(
                      context: context,
                      items: participants,
                      selected: selectedParticipant,
                      itemLabel: (p) => p,
                      sheetTitle: 'Select Participant',
                      onAddItemInline: (name) async {
                        // Simulate adding participant to the list
                        participants = [...participants, name];
                        addedParticipant = name;
                      },
                      addItemHint: 'Participant name',
                      addLabel: 'Add',
                      cancelLabel: 'Cancel',
                      addCategoryLabel: 'Add participant',
                      alreadyExistsMessage: 'Participant already exists',
                    );
                    if (result != null) {
                      selectedParticipant = result;
                    }
                  },
                  child: const Text('Open Bottom Sheet'),
                ),
              ),
            ),
          ),
        );

        // Open the bottom sheet
        await tester.tap(find.text('Open Bottom Sheet'));
        await tester.pumpAndSettle();

        // Verify initial participants are shown
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('Charlie'), findsNothing);

        // Tap the add participant button
        await tester.tap(find.text('Add participant'));
        await tester.pumpAndSettle();

        // Enter new participant name
        await tester.enterText(find.byType(TextField), 'Charlie');
        await tester.pumpAndSettle();

        // Commit the addition
        await tester.tap(find.byIcon(Icons.check_rounded));
        await tester.pumpAndSettle();

        // Verify that:
        // 1. The callback was called
        expect(addedParticipant, equals('Charlie'));

        // 2. The modal automatically closed and selected the new participant
        expect(find.text('Select Participant'), findsNothing);
        expect(selectedParticipant, equals('Charlie'));
      },
    );

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
      expect(
        find.byIcon(Icons.check_rounded),
        findsOneWidget,
      ); // Confirm button
      expect(
        find.byIcon(Icons.close_outlined),
        findsOneWidget,
      ); // Cancel button
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
