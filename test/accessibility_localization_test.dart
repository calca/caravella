import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart';
import 'package:org_app_caravella/widgets/add_fab.dart';
import 'package:org_app_caravella/widgets/caravella_app_bar.dart';
import 'package:org_app_caravella/widgets/app_toast.dart';

void main() {
  group('Accessibility Localization Tests', () {
    testWidgets('AddFab uses localized accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: AddFab(
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify the semantic label is present and localized
      final semanticsWithLabel = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Add new item'),
      );

      expect(semanticsWithLabel, findsOneWidget);
    });

    testWidgets('AddFab uses Italian localized accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Scaffold(
            body: AddFab(
              onPressed: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the semantic label is in Italian
      final semanticsWithLabel = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Aggiungi nuovo elemento'),
      );

      expect(semanticsWithLabel, findsOneWidget);
    });

    testWidgets('CaravellaAppBar uses localized accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            appBar: CaravellaAppBar(),
          ),
        ),
      );

      // Verify navigation bar has English localized label
      final navBarSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label == 'Navigation bar',
      );

      expect(navBarSemantics, findsOneWidget);
    });

    testWidgets('CaravellaAppBar uses Italian localized accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: const Scaffold(
            appBar: CaravellaAppBar(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify navigation bar has Italian localized label
      final navBarSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label == 'Barra di navigazione',
      );

      expect(navBarSemantics, findsOneWidget);
    });

    testWidgets('AppToast shows localized accessibility descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppToast.show(context, 'Test message', type: ToastType.success);
                },
                child: const Text('Show Toast'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pumpAndSettle();

      // Verify toast has English success label
      final toastSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Success: Test message'),
      );

      expect(toastSemantics, findsOneWidget);
    });

    testWidgets('AppToast shows Italian localized accessibility descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  AppToast.show(context, 'Messaggio di test', type: ToastType.success);
                },
                child: const Text('Mostra Toast'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mostra Toast'));
      await tester.pumpAndSettle();

      // Verify toast has Italian success label
      final toastSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Successo: Messaggio di test'),
      );

      expect(toastSemantics, findsOneWidget);
    });

    group('Localization Key Validation', () {
      test('English localizations contain all accessibility keys', () {
        const locale = Locale('en');
        final localizations = lookupAppLocalizations(locale);

        // Verify all accessibility keys are present
        expect(localizations.accessibility_add_new_item, isNotEmpty);
        expect(localizations.accessibility_navigation_bar, isNotEmpty);
        expect(localizations.accessibility_back_button, isNotEmpty);
        expect(localizations.accessibility_loading_groups, isNotEmpty);
        expect(localizations.accessibility_loading_your_groups, isNotEmpty);
        expect(localizations.accessibility_groups_list, isNotEmpty);
        expect(localizations.accessibility_welcome_screen, isNotEmpty);
        expect(localizations.accessibility_add_expense, isNotEmpty);
        expect(localizations.accessibility_switch_on, isNotEmpty);
        expect(localizations.accessibility_switch_off, isNotEmpty);
        expect(localizations.accessibility_toast_success, isNotEmpty);
        expect(localizations.accessibility_toast_error, isNotEmpty);
        expect(localizations.accessibility_toast_info, isNotEmpty);
      });

      test('Italian localizations contain all accessibility keys', () {
        const locale = Locale('it');
        final localizations = lookupAppLocalizations(locale);

        // Verify all accessibility keys are present and different from English
        expect(localizations.accessibility_add_new_item, equals('Aggiungi nuovo elemento'));
        expect(localizations.accessibility_navigation_bar, equals('Barra di navigazione'));
        expect(localizations.accessibility_back_button, equals('Indietro'));
        expect(localizations.accessibility_loading_groups, equals('Caricamento gruppi'));
        expect(localizations.accessibility_loading_your_groups, equals('Caricamento dei tuoi gruppi'));
        expect(localizations.accessibility_groups_list, equals('Elenco gruppi'));
        expect(localizations.accessibility_welcome_screen, equals('Schermata di benvenuto'));
        expect(localizations.accessibility_add_expense, equals('Aggiungi spesa'));
        expect(localizations.accessibility_switch_on, equals('Attivo'));
        expect(localizations.accessibility_switch_off, equals('Inattivo'));
        expect(localizations.accessibility_toast_success, equals('Successo'));
        expect(localizations.accessibility_toast_error, equals('Errore'));
        expect(localizations.accessibility_toast_info, equals('Informazione'));
      });

      test('Parameterized accessibility methods work correctly', () {
        const enLocale = Locale('en');
        const itLocale = Locale('it');
        final enLocalizations = lookupAppLocalizations(enLocale);
        final itLocalizations = lookupAppLocalizations(itLocale);

        // Test English parameterized methods
        expect(enLocalizations.accessibility_total_expenses('100.50'), 
               equals('Total expenses: 100.50€'));
        expect(enLocalizations.accessibility_security_switch('On'), 
               equals('Security switch - On'));

        // Test Italian parameterized methods
        expect(itLocalizations.accessibility_total_expenses('100.50'), 
               equals('Spese totali: 100.50€'));
        expect(itLocalizations.accessibility_security_switch('Attivo'), 
               equals('Interruttore sicurezza - Attivo'));
      });
    });
  });
}