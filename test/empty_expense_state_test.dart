import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/manager/details/widgets/empty_expense_state.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';

void main() {
  group('EmptyExpenseState Widget Tests', () {
    testWidgets('EmptyExpenseState displays correctly in Italian', (
      tester,
    ) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
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

      // Check that add button is present with Italian text
      expect(find.text('Aggiungi spesa'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // A short title and line instead of the old random emoji.
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);

      // Check button functionality
      final button = find.text('Aggiungi spesa');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });

    testWidgets('EmptyExpenseState displays correctly in English', (
      tester,
    ) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
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

      // Check that add button is present with English text
      expect(find.text('Add expense'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // A short title and line instead of the old random emoji.
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);

      // Check button functionality
      final button = find.text('Add expense');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });

    testWidgets('EmptyExpenseState displays correctly in Spanish', (
      tester,
    ) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
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

      // Check that add button is present with Spanish text
      expect(find.text('Añadir gasto'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // A short title and line instead of the old random emoji.
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);

      // Check button functionality
      final button = find.text('Añadir gasto');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });

    testWidgets('EmptyExpenseState shows image or fallback icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(body: EmptyExpenseState(onAddFirstExpense: () {})),
        ),
      );

      await tester.pumpAndSettle();

      // Title and line from the localizations, no emoji.
      expect(find.text('No expenses yet'), findsOneWidget);

      // Also verify button is present
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('EmptyExpenseState has proper Material 3 styling', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(body: EmptyExpenseState(onAddFirstExpense: () {})),
        ),
      );

      await tester.pumpAndSettle();

      // Check for button label and icon
      expect(find.text('Add expense'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });
}
