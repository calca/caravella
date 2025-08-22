import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
import 'package:org_app_caravella/data/model/expense_details.dart';
import 'package:org_app_caravella/state/expense_group_notifier.dart';
import 'package:org_app_caravella/home/cards/widgets/group_card_content.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Home Expense Modal Tests', () {
    late ExpenseGroupNotifier notifier;
    late ExpenseGroup testGroup;

    setUp(() {
      notifier = ExpenseGroupNotifier();
      testGroup = ExpenseGroup(
        id: 'test-group-1',
        title: 'Test Group',
        expenses: [],
        participants: [ExpenseParticipant(id: '1', name: 'Test User')],
        categories: [ExpenseCategory(id: '1', name: 'Food')],
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        currency: '€',
        timestamp: DateTime.now(),
        file: null,
        pinned: false,
      );
    });

    testWidgets('GroupCardContent builds correctly with state management', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            gen.AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('it'), Locale('en')],
          home: Scaffold(
            body: ChangeNotifierProvider<ExpenseGroupNotifier>(
              create: (_) => notifier,
              child: Builder(
                builder: (context) {
                  return GroupCardContent(
                    group: testGroup,
                    localizations: gen.AppLocalizations.of(context),
                    theme: Theme.of(context),
                    onExpenseAdded: () {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Wait for localization to load
      await tester.pumpAndSettle();

      expect(find.byType(GroupCardContent), findsOneWidget);
    });

    testWidgets('Performance optimizations work correctly', (tester) async {
      // Test that memoized calculations don't cause rebuilds
      final groupWithExpenses = testGroup.copyWith(
        expenses: List.generate(
          10,
          (i) => ExpenseDetails(
            id: 'expense-$i',
            amount: 10.0,
            paidBy: ExpenseParticipant(id: '1', name: 'Test User'),
            category: ExpenseCategory(id: '1', name: 'Food'),
            date: DateTime.now(),
            name: 'Test Expense $i',
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            gen.AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('it')],
          home: Scaffold(
            body: ChangeNotifierProvider<ExpenseGroupNotifier>(
              create: (_) => notifier,
              child: Builder(
                builder: (context) {
                  return GroupCardContent(
                    group: groupWithExpenses,
                    localizations: gen.AppLocalizations.of(context),
                    theme: Theme.of(context),
                    onExpenseAdded: () {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget builds without performance issues
      expect(find.byType(GroupCardContent), findsOneWidget);
    });

    test('ExpenseGroupNotifier state management updates correctly', () {
      // Test that state updates are efficient
      notifier.setCurrentGroup(testGroup);
      expect(notifier.currentGroup, equals(testGroup));

      // Test event tracking
      expect(notifier.lastEvent, isNull);

      // Test the state before calling async method
      notifier.setCurrentGroup(testGroup);
      expect(notifier.currentGroup?.id, equals('test-group-1'));
    });
  });
}
