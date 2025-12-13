import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/group/pages/expenses_group_edit_page.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Group creation default participant', () {
    testWidgets(
        'adds localized "Me" as first participant when user has no name',
        (WidgetTester tester) async {
      // Create a UserNameNotifier without a name
      final userNameNotifier = UserNameNotifier();

      // Build the widget tree with necessary providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserNameNotifier>.value(
              value: userNameNotifier,
            ),
            ChangeNotifierProvider<ExpenseGroupNotifier>(
              create: (_) => ExpenseGroupNotifier(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              gen.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('it'),
              Locale('es'),
              Locale('pt'),
              Locale('zh'),
            ],
            locale: const Locale('en'),
            home: const ExpensesGroupEditPage(
              mode: GroupEditMode.create,
            ),
          ),
        ),
      );

      // Wait for the widget to build and initialize
      await tester.pumpAndSettle();

      // Verify that the first participant is "Me"
      expect(find.text('Me'), findsOneWidget);
    });

    testWidgets(
        'adds user name as first participant when user has name set',
        (WidgetTester tester) async {
      // Create a UserNameNotifier with a name
      final userNameNotifier = UserNameNotifier();
      await userNameNotifier.setName('John Doe');

      // Build the widget tree with necessary providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserNameNotifier>.value(
              value: userNameNotifier,
            ),
            ChangeNotifierProvider<ExpenseGroupNotifier>(
              create: (_) => ExpenseGroupNotifier(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              gen.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('it'),
              Locale('es'),
              Locale('pt'),
              Locale('zh'),
            ],
            locale: const Locale('en'),
            home: const ExpensesGroupEditPage(
              mode: GroupEditMode.create,
            ),
          ),
        ),
      );

      // Wait for the widget to build and initialize
      await tester.pumpAndSettle();

      // Verify that the first participant is the user's name
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets(
        'adds localized "Io" in Italian when user has no name',
        (WidgetTester tester) async {
      // Create a UserNameNotifier without a name
      final userNameNotifier = UserNameNotifier();

      // Build the widget tree with Italian locale
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserNameNotifier>.value(
              value: userNameNotifier,
            ),
            ChangeNotifierProvider<ExpenseGroupNotifier>(
              create: (_) => ExpenseGroupNotifier(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              gen.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('it'),
              Locale('es'),
              Locale('pt'),
              Locale('zh'),
            ],
            locale: const Locale('it'),
            home: const ExpensesGroupEditPage(
              mode: GroupEditMode.create,
            ),
          ),
        ),
      );

      // Wait for the widget to build and initialize
      await tester.pumpAndSettle();

      // Verify that the first participant is "Io" (Italian for "Me")
      expect(find.text('Io'), findsOneWidget);
    });
  });
}
