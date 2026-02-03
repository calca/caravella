import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/details/widgets/expense_amount_card.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';

/// Tests that ExpenseAmountCard correctly displays decimal places in amounts
void main() {
  Widget _app(Widget child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  testWidgets('ExpenseAmountCard displays decimal places for amounts',
      (tester) async {
    final participant = ExpenseParticipant(name: 'John', id: 'p1');

    await tester.pumpWidget(
      _app(
        ExpenseAmountCard(
          title: 'Test Expense',
          amount: 12.50,
          checked: true,
          paidBy: participant,
          category: 'Food',
          date: DateTime(2024, 1, 1),
          currency: '€',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The CurrencyDisplay should show both integer and decimal parts
    // When showDecimals is true, it splits the number into integer and decimal
    // with the decimal part in smaller font
    // Look for "12" and the decimal separator (. or ,) and "50"
    expect(find.textContaining('12'), findsOneWidget);
    expect(find.text('€'), findsOneWidget);
    
    // The amount should be visible in the widget tree
    // Note: The decimal separator may be locale-dependent (. or ,)
    // but the digits should always be present
    final amountText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(ExpenseAmountCard),
        matching: find.byType(RichText),
      ).first,
    );
    
    final textSpan = amountText.text as TextSpan;
    final fullText = textSpan.toPlainText();
    
    // Should contain decimal digits
    expect(fullText.contains('50'), isTrue,
        reason: 'Amount should display decimal places (50)');
  });

  testWidgets('ExpenseAmountCard displays whole number with decimals',
      (tester) async {
    final participant = ExpenseParticipant(name: 'Jane', id: 'p2');

    await tester.pumpWidget(
      _app(
        ExpenseAmountCard(
          title: 'Round Amount',
          amount: 25.00,
          checked: true,
          paidBy: participant,
          category: 'Transport',
          date: DateTime(2024, 1, 1),
          currency: '€',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should show decimal places even for whole numbers (25.00)
    expect(find.textContaining('25'), findsOneWidget);
    
    final amountText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(ExpenseAmountCard),
        matching: find.byType(RichText),
      ).first,
    );
    
    final textSpan = amountText.text as TextSpan;
    final fullText = textSpan.toPlainText();
    
    // Should contain decimal separator and .00
    expect(fullText.contains('00'), isTrue,
        reason: 'Amount should display .00 for whole numbers');
  });

  testWidgets('ExpenseAmountCard displays complex decimal amounts',
      (tester) async {
    final participant = ExpenseParticipant(name: 'Bob', id: 'p3');

    await tester.pumpWidget(
      _app(
        ExpenseAmountCard(
          title: 'Complex Amount',
          amount: 123.45,
          checked: true,
          paidBy: participant,
          category: 'Other',
          date: DateTime(2024, 1, 1),
          currency: '€',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should display both the integer and decimal parts
    expect(find.textContaining('123'), findsOneWidget);
    
    final amountText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(ExpenseAmountCard),
        matching: find.byType(RichText),
      ).first,
    );
    
    final textSpan = amountText.text as TextSpan;
    final fullText = textSpan.toPlainText();
    
    // Should contain the decimal part
    expect(fullText.contains('45'), isTrue,
        reason: 'Amount should display decimal places (45)');
  });
}
