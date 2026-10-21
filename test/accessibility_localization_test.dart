import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:zentoast/zentoast.dart';

void main() {
  group('Accessibility Localization Tests', () {
    testWidgets('AddFab uses localized accessibility labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final gloc = AppLocalizations.of(context);
              return Scaffold(
                body: AddFab(
                  onPressed: () {},
                  semanticLabel: gloc.accessibility_add_expense,
                ),
              );
            },
          ),
        ),
      );

      // Verify the semantic label is present and localized
      final semanticsWithLabel = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Add expense'),
      );

      expect(semanticsWithLabel, findsOneWidget);
    });

    testWidgets('AddFab uses Italian localized accessibility labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Builder(
            builder: (context) {
              final gloc = AppLocalizations.of(context);
              return Scaffold(
                body: AddFab(
                  onPressed: () {},
                  semanticLabel: gloc.accessibility_add_expense,
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the semantic label is in Italian
      final semanticsWithLabel = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Aggiungi spesa'),
      );

      expect(semanticsWithLabel, findsOneWidget);
    });

    testWidgets('AddFab uses Spanish localized accessibility labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Builder(
            builder: (context) {
              final gloc = AppLocalizations.of(context);
              return Scaffold(
                body: AddFab(
                  onPressed: () {},
                  semanticLabel: gloc.accessibility_add_expense,
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the semantic label is present and localized to Spanish
      final semanticsWithLabel = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Añadir gasto'),
      );

      expect(semanticsWithLabel, findsOneWidget);
    });

    testWidgets('BaseCard with semanticLabel announces as a single node', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaseCard(
              onTap: () {},
              semanticLabel: 'Group card label',
              child: const Column(
                children: [Text('Title'), Text('Balance')],
              ),
            ),
          ),
        ),
      );

      final cardSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == 'Group card label',
      );
      expect(cardSemantics, findsOneWidget);

      // The card's own text is excluded in favor of the explicit label —
      // it shouldn't also be exposed as a separate semantics node.
      expect(find.bySemanticsLabel('Title'), findsNothing);
    });

    testWidgets(
      'BaseCard without semanticLabel merges its text into one button node',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BaseCard(
                onTap: () {},
                child: const Column(
                  children: [Text('Title'), Text('Balance')],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(MergeSemantics), findsOneWidget);

        final buttonSemantics = find.byWidgetPredicate(
          (Widget widget) =>
              widget is Semantics && widget.properties.button == true,
        );
        expect(buttonSemantics, findsOneWidget);
      },
    );

    testWidgets('CaravellaAppBar uses localized accessibility labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final gloc = AppLocalizations.of(context);
              return Scaffold(
                appBar: CaravellaAppBar(
                  headerSemanticLabel: gloc.accessibility_groups_list,
                ),
              );
            },
          ),
        ),
      );

      // Verify navigation bar has English localized label
      final navBarSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics && widget.properties.label == 'Groups list',
      );

      expect(navBarSemantics, findsOneWidget);
    });

    testWidgets('CaravellaAppBar uses Italian localized accessibility labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Builder(
            builder: (context) {
              final gloc = AppLocalizations.of(context);
              return Scaffold(
                appBar: CaravellaAppBar(
                  headerSemanticLabel: gloc.accessibility_groups_list,
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify navigation bar has Italian localized label
      final navBarSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label == 'Elenco gruppi',
      );

      expect(navBarSemantics, findsOneWidget);
    });

    testWidgets('AppToast shows localized accessibility descriptions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ToastProvider.create(
          child: MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                final gloc = AppLocalizations.of(context);
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AppToast.show(
                        context,
                        'Test message',
                        type: ToastType.success,
                        semanticLabel:
                            '${gloc.voice_expense_saved}: Test message',
                      );
                    },
                    child: const Text('Show Toast'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show toast - verify no errors thrown
      await tester.tap(find.text('Show Toast'));
      await tester.pump();

      // Verify localization key is accessible
      final context = tester.element(find.byType(Scaffold));
      final gloc = AppLocalizations.of(context);
      expect(gloc.voice_expense_saved, equals('Expense saved'));
    });

    testWidgets('AppToast shows Italian localized accessibility descriptions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ToastProvider.create(
          child: MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('it'),
            home: Builder(
              builder: (context) {
                final gloc = AppLocalizations.of(context);
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      AppToast.show(
                        context,
                        'Messaggio di test',
                        type: ToastType.success,
                        semanticLabel:
                            '${gloc.voice_expense_saved}: Messaggio di test',
                      );
                    },
                    child: const Text('Mostra Toast'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show toast - verify no errors thrown
      await tester.tap(find.text('Mostra Toast'));
      await tester.pump();

      // Verify Italian localization key is accessible
      final context = tester.element(find.byType(Scaffold));
      final gloc = AppLocalizations.of(context);
      expect(gloc.voice_expense_saved, equals('Spesa salvata'));
    });

    group('Localization Key Validation', () {
      test('English localizations contain all accessibility keys', () {
        const locale = Locale('en');
        final localizations = lookupAppLocalizations(locale);
        expect(localizations.accessibility_back_button, isNotEmpty);
        expect(localizations.accessibility_groups_list, isNotEmpty);
        expect(localizations.accessibility_welcome_screen, isNotEmpty);
        expect(localizations.accessibility_add_expense, isNotEmpty);
        expect(localizations.accessibility_previous_month, isNotEmpty);
        expect(localizations.accessibility_next_month, isNotEmpty);
      });

      test('Italian localizations contain all accessibility keys', () {
        const locale = Locale('it');
        final localizations = lookupAppLocalizations(locale);
        expect(localizations.accessibility_back_button, equals('Indietro'));
        expect(
          localizations.accessibility_groups_list,
          equals('Elenco gruppi'),
        );
        expect(
          localizations.accessibility_welcome_screen,
          equals('Schermata di benvenuto'),
        );
        expect(
          localizations.accessibility_add_expense,
          equals('Aggiungi spesa'),
        );
        expect(
          localizations.accessibility_previous_month,
          equals('Mese precedente'),
        );
        expect(
          localizations.accessibility_next_month,
          equals('Mese successivo'),
        );
      });

      test('Spanish localizations contain all accessibility keys', () {
        const locale = Locale('es');
        final localizations = lookupAppLocalizations(locale);
        expect(localizations.accessibility_back_button, equals('Atrás'));
        expect(
          localizations.accessibility_groups_list,
          equals('Lista de grupos'),
        );
        expect(
          localizations.accessibility_welcome_screen,
          equals('Pantalla de bienvenida'),
        );
        expect(
          localizations.accessibility_add_expense,
          equals('Añadir gasto'),
        );
        expect(
          localizations.accessibility_previous_month,
          equals('Mes anterior'),
        );
        expect(
          localizations.accessibility_next_month,
          equals('Mes siguiente'),
        );
      });

      test('Parameterized accessibility methods work correctly', () {
        const enLocale = Locale('en');
        const itLocale = Locale('it');
        const esLocale = Locale('es');
        final enLocalizations = lookupAppLocalizations(enLocale);
        final itLocalizations = lookupAppLocalizations(itLocale);
        final esLocalizations = lookupAppLocalizations(esLocale);

        // Test English parameterized methods
        expect(
          enLocalizations.accessibility_total_expenses('100.50'),
          equals('Total expenses: 100.50'),
        );

        // Test Italian parameterized methods
        expect(
          itLocalizations.accessibility_total_expenses('100.50'),
          equals('Spese totali: 100.50'),
        );

        // Test Spanish parameterized methods
        expect(
          esLocalizations.accessibility_total_expenses('100.50'),
          equals('Gastos totales: 100.50'),
        );
      });
    });
  });
}
