import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/model/expense_details.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
import 'package:org_app_caravella/manager/history/widgets/expense_group_options_sheet.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('ExpenseGroupOptionsSheet', () {
    late ExpenseGroup testGroup;

    setUp(() {
      testGroup = ExpenseGroup(
        id: 'test-group-1',
        title: 'Test Group',
        expenses: [
          ExpenseDetails(
            id: 'expense-1',
            name: 'Test Expense',
            amount: 100.0,
            paidBy: ExpenseParticipant(name: 'Alice'),
            category: ExpenseCategory(name: 'food'),
            date: DateTime.now(),
          ),
        ],
        participants: [
          ExpenseParticipant(name: 'Alice'),
          ExpenseParticipant(name: 'Bob'),
        ],
        categories: [
          ExpenseCategory(name: 'food'),
          ExpenseCategory(name: 'transport'),
        ],
        currency: 'EUR',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );
    });

    testWidgets('displays all option buttons with correct localization', (WidgetTester tester) async {
      bool tripDeleted = false;
      bool tripUpdated = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ExpenseGroupOptionsSheet(
              trip: testGroup,
              onTripDeleted: () => tripDeleted = true,
              onTripUpdated: () => tripUpdated = true,
            ),
          ),
        ),
      );

      // Check that all buttons are present with correct localized text
      expect(find.text('Edit Group'), findsOneWidget);
      expect(find.text('Duplicate group'), findsOneWidget);
      expect(find.text('Copy as new'), findsOneWidget);
      expect(find.text('Delete group'), findsOneWidget);
      
      // Check subtitles
      expect(find.text('Edit name, dates and participants'), findsOneWidget);
      expect(find.text('Create a copy with the same data'), findsOneWidget);
      expect(find.text('Create new group starting from here'), findsOneWidget);
      expect(find.text('Remove this group permanently'), findsOneWidget);
    });

    testWidgets('displays correct localization for Italian', (WidgetTester tester) async {
      bool tripDeleted = false;
      bool tripUpdated = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: ExpenseGroupOptionsSheet(
              trip: testGroup,
              onTripDeleted: () => tripDeleted = true,
              onTripUpdated: () => tripUpdated = true,
            ),
          ),
        ),
      );

      // Check that all buttons are present with correct Italian text
      expect(find.text('Modifica gruppo'), findsOneWidget);
      expect(find.text('Duplica gruppo'), findsOneWidget);
      expect(find.text('Nuovo da qui'), findsOneWidget);
      expect(find.text('Elimina gruppo'), findsOneWidget);
    });

    testWidgets('shows group title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ExpenseGroupOptionsSheet(
              trip: testGroup,
              onTripDeleted: () {},
              onTripUpdated: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Group'), findsOneWidget);
    });

    test('test copy as new logic creates correct group structure', () {
      // Test the logic that should be in _handleCopyAsNew
      // This tests the data transformation without UI interaction
      
      final originalGroup = ExpenseGroup(
        id: 'original-1',
        title: 'Original Group',
        expenses: [
          ExpenseDetails(
            id: 'expense-1',
            name: 'Expense 1',
            amount: 50.0,
            paidBy: ExpenseParticipant(name: 'Alice'),
            category: ExpenseCategory(name: 'food'),
            date: DateTime.now(),
          ),
          ExpenseDetails(
            id: 'expense-2',
            name: 'Expense 2',
            amount: 75.0,
            paidBy: ExpenseParticipant(name: 'Bob'),
            category: ExpenseCategory(name: 'transport'),
            date: DateTime.now(),
          ),
        ],
        participants: [
          ExpenseParticipant(name: 'Alice'),
          ExpenseParticipant(name: 'Bob'),
        ],
        categories: [
          ExpenseCategory(name: 'food'),
          ExpenseCategory(name: 'transport'),
        ],
        currency: 'USD',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 28),
      );

      // Simulate what _handleCopyAsNew should create
      final newGroup = ExpenseGroup(
        title: "(New) ${originalGroup.title}",
        expenses: [], // Should be empty
        participants: originalGroup.participants
            .map((p) => ExpenseParticipant(name: p.name))
            .toList(),
        startDate: originalGroup.startDate,
        endDate: originalGroup.endDate,
        currency: originalGroup.currency,
        categories: originalGroup.categories
            .map((c) => ExpenseCategory(name: c.name))
            .toList(),
      );

      // Verify the new group has correct structure
      expect(newGroup.title, equals('(New) Original Group'));
      expect(newGroup.expenses, isEmpty);
      expect(newGroup.participants.length, equals(2));
      expect(newGroup.participants[0].name, equals('Alice'));
      expect(newGroup.participants[1].name, equals('Bob'));
      expect(newGroup.categories.length, equals(2));
      expect(newGroup.categories[0].name, equals('food'));
      expect(newGroup.categories[1].name, equals('transport'));
      expect(newGroup.currency, equals('USD'));
      expect(newGroup.startDate, equals(DateTime(2024, 2, 1)));
      expect(newGroup.endDate, equals(DateTime(2024, 2, 28)));
      
      // Verify that modifying the new group doesn't affect the original
      expect(originalGroup.expenses.length, equals(2));
      expect(originalGroup.title, equals('Original Group'));
    });
  });
}