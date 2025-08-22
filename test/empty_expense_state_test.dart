import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:org_app_caravella/manager/details/widgets/empty_expense_state.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart';

void main() {
  group('EmptyExpenseState Widget Tests', () {
    testWidgets('EmptyExpenseState displays correctly in Italian', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: EmptyExpenseState(
              onAddFirstExpense: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check Italian localization strings
      expect(find.text('Pronti per iniziare?'), findsOneWidget);
      expect(find.text('Aggiungi la prima spesa per iniziare con questo gruppo!'), findsOneWidget);
      expect(find.text('Aggiungi Prima Spesa'), findsOneWidget);

      // Check button functionality
      final button = find.text('Aggiungi Prima Spesa');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });

    testWidgets('EmptyExpenseState displays correctly in English', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: EmptyExpenseState(
              onAddFirstExpense: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check English localization strings
      expect(find.text('Ready to start tracking?'), findsOneWidget);
      expect(find.text('Add your first expense to get started with this group!'), findsOneWidget);
      expect(find.text('Add First Expense'), findsOneWidget);

      // Check button functionality
      final button = find.text('Add First Expense');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });

    testWidgets('EmptyExpenseState displays correctly in Spanish', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: EmptyExpenseState(
              onAddFirstExpense: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check Spanish localization strings
      expect(find.text('¿Listo para empezar?'), findsOneWidget);
      expect(find.text('¡Agrega tu primer gasto para comenzar con este grupo!'), findsOneWidget);
      expect(find.text('Agregar Primer Gasto'), findsOneWidget);

      // Check button functionality
      final button = find.text('Agregar Primer Gasto');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });

    testWidgets('EmptyExpenseState shows image or fallback icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: EmptyExpenseState(
              onAddFirstExpense: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that either an image or the fallback icon is present
      final imageWidget = find.byType(Image);
      final iconWidget = find.byIcon(Icons.receipt_long_outlined);
      
      // At least one should be present (image tries to load, icon is fallback)
      expect(imageWidget.evaluate().isNotEmpty || iconWidget.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('EmptyExpenseState has proper Material 3 styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: EmptyExpenseState(
              onAddFirstExpense: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that a FilledButton is used (Material 3 component)
      expect(find.byType(FilledButton), findsOneWidget);
      
      // Check for proper icon in button
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });
}