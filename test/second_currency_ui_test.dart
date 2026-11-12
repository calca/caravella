import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core/data/sqlite_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/export/csv_exporter.dart';
import 'package:io_caravella_egm/manager/expense/components/expense_form_component.dart';
import 'package:io_caravella_egm/manager/expense/components/expense_form_config.dart';
import 'package:io_caravella_egm/manager/group/widgets/currency_selector_sheet.dart';
import 'package:io_caravella_egm/manager/group/widgets/group_currency_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A group's second currency: "in kr" under the amount, the currency sheet
/// in General, the CSV columns and the v10 migration.
void main() {
  const nok = SecondCurrency(code: 'NOK', symbol: 'kr', rate: 11.63);
  final anna = ExpenseParticipant(id: 'p1', name: 'Anna');
  final transport = ExpenseCategory(id: 'c1', name: 'Transport');

  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );

  group('expense form', () {
    late List<ExpenseDetails> saved;
    VoidCallback? save;

    Future<AppLocalizations> pumpForm(
      WidgetTester tester, {
      SecondCurrency? second,
      bool startInSecond = false,
      ExpenseDetails? initialExpense,
    }) async {
      saved = [];
      await tester.pumpWidget(
        wrap(
          ExpenseFormComponent(
            config: ExpenseFormConfig(
              initialExpense: initialExpense,
              participants: [anna],
              categories: [transport],
              onExpenseAdded: saved.add,
              onCategoryAdded: (_) {},
              onSaveCallbackChanged: (cb) => save = cb,
              groupId: 'g',
              currency: '€',
              secondCurrency: second,
              startInSecondCurrency: startInSecond,
              autoLocationEnabled: false,
              shouldAutoClose: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return AppLocalizations.of(
        tester.element(find.byType(ExpenseFormComponent)),
      );
    }

    Future<void> type(WidgetTester tester, String amount, String name) async {
      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), amount);
      await tester.enterText(fields.at(1), name);
      await tester.pump();
    }

    testWidgets('a group with one currency has no link under the amount', (
      tester,
    ) async {
      final loc = await pumpForm(tester);
      expect(find.text(loc.entry_in_currency('kr')), findsNothing);
    });

    testWidgets('"in kr" types the receipt; the group counts euros', (
      tester,
    ) async {
      final loc = await pumpForm(tester, second: nok);
      expect(find.text(loc.entry_in_currency('kr')), findsOneWidget);

      await tester.tap(find.text(loc.entry_in_currency('kr')));
      await tester.pump();
      expect(find.text(loc.entry_in_currency('€')), findsOneWidget);

      await type(tester, '450', 'Ferry');
      expect(find.text('= 38.69 €'), findsOneWidget);

      save!();
      await tester.pump();
      final e = saved.single;
      expect(e.amount, 38.69);
      expect(
        e.original,
        const OriginalAmount(
          amount: 450,
          code: 'NOK',
          symbol: 'kr',
          rate: 11.63,
        ),
      );
    });

    testWidgets('back to € the amount is in euros, with no original', (
      tester,
    ) async {
      final loc = await pumpForm(tester, second: nok, startInSecond: true);
      expect(find.text(loc.entry_in_currency('€')), findsOneWidget);
      await tester.tap(find.text(loc.entry_in_currency('€')));
      await tester.pump();
      await type(tester, '20', 'Coffee');
      expect(find.textContaining('= '), findsNothing);
      save!();
      await tester.pump();
      expect(saved.single.amount, 20);
      expect(saved.single.original, isNull);
    });

    testWidgets('an expense entered in kr opens in kr, at its own rate', (
      tester,
    ) async {
      // Entered at 10 kr per euro; the group's rate is 11.63 now.
      await pumpForm(
        tester,
        second: nok,
        initialExpense: ExpenseDetails(
          id: 'e',
          name: 'Ferry',
          amount: 45,
          paidBy: anna,
          category: transport,
          date: DateTime(2026, 11, 11),
          original: const OriginalAmount(
            amount: 450,
            code: 'NOK',
            symbol: 'kr',
            rate: 10,
          ),
        ),
      );
      expect(find.text('= 45.00 €'), findsOneWidget);
      save!();
      await tester.pump();
      expect(saved.single.amount, 45);
      expect(saved.single.original?.rate, 10);
    });
  });

  group('currency sheet', () {
    GroupCurrencyChoice? result;

    Future<AppLocalizations> pumpSheet(
      WidgetTester tester, {
      SecondCurrency? second,
    }) async {
      result = null;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => result = await showGroupCurrencySheet(
                  context,
                  currency: const {
                    'symbol': '€',
                    'code': 'EUR',
                    'name': 'Euro',
                  },
                  second: second,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return AppLocalizations.of(
        tester.element(find.byType(GroupCurrencySheet)),
      );
    }

    testWidgets('without a second currency it offers to add one', (
      tester,
    ) async {
      final loc = await pumpSheet(tester);
      expect(find.text(loc.currency_section_group), findsOneWidget);
      expect(find.text(loc.currency_group_hint), findsOneWidget);
      expect(find.text(loc.second_currency_add), findsOneWidget);
      expect(find.text(loc.second_currency_empty_hint('€')), findsOneWidget);

      await tester.tap(find.text(loc.done));
      await tester.pumpAndSettle();
      expect(result?.currency['code'], 'EUR');
      expect(result?.second, isNull);
    });

    testWidgets('adds a currency: Done waits for its rate', (tester) async {
      final loc = await pumpSheet(tester);
      await tester.tap(find.text(loc.second_currency_add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'NOK');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.tap(find.text('Norwegian Krone'));
      await tester.pumpAndSettle();

      expect(find.text('1 € ='), findsOneWidget);
      final done = find.widgetWithText(FilledButton, loc.done);
      expect(tester.widget<FilledButton>(done).onPressed, isNull);

      await tester.enterText(find.byType(TextField).last, '11.63');
      await tester.pump();
      await tester.tap(done);
      await tester.pumpAndSettle();
      expect(result?.second, nok);
    });

    testWidgets('changes the rate, or removes the currency', (tester) async {
      var loc = await pumpSheet(tester, second: nok);
      expect(find.text('11.63'), findsOneWidget);
      expect(find.text(loc.second_currency_rate_hint), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '11.2');
      await tester.tap(find.text(loc.done));
      await tester.pumpAndSettle();
      expect(result?.second, nok.copyWith(rate: 11.2));

      loc = await pumpSheet(tester, second: nok);
      await tester.tap(
        find.byTooltip(loc.second_currency_remove('Norwegian Krone')),
      );
      await tester.pump();
      expect(find.text(loc.second_currency_add), findsOneWidget);
      await tester.tap(find.text(loc.done));
      await tester.pumpAndSettle();
      expect(result?.second, isNull);
    });
  });

  group('changing the group currency', () {
    Future<void> pick(WidgetTester tester, String search, String name) async {
      await tester.enterText(
        find.descendant(
          of: find.byType(CurrencySelectorSheet),
          matching: find.byType(TextField),
        ),
        search,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.tap(
        find.descendant(
          of: find.byType(CurrencySelectorSheet),
          matching: find.text(name),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<AppLocalizations> open(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: GroupCurrencySheet(
              currency: {'symbol': '€', 'code': 'EUR', 'name': 'Euro'},
              second: nok,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return AppLocalizations.of(
        tester.element(find.byType(GroupCurrencySheet)),
      );
    }

    testWidgets('to the second one drops the second', (tester) async {
      final loc = await open(tester);
      await tester.tap(find.text(loc.currency_change));
      await tester.pumpAndSettle();
      await pick(tester, 'NOK', 'Norwegian Krone');
      expect(find.text(loc.second_currency_add), findsOneWidget);
    });

    testWidgets('to another asks the rate again', (tester) async {
      final loc = await open(tester);
      await tester.tap(find.text(loc.currency_change));
      await tester.pumpAndSettle();
      await pick(tester, 'USD', 'United States Dollar');
      expect(find.text(r'1 $ ='), findsOneWidget);
      expect(find.text('11.63'), findsNothing);
      final done = find.widgetWithText(FilledButton, loc.done);
      expect(tester.widget<FilledButton>(done).onPressed, isNull);
    });
  });

  test('CSV adds the receipt columns only when needed', () async {
    final loc = await AppLocalizations.delegate.load(const Locale('en'));
    ExpenseDetails e(String name, double amount, {OriginalAmount? original}) =>
        ExpenseDetails(
          name: name,
          amount: amount,
          paidBy: anna,
          category: transport,
          date: DateTime(2026, 11, 11),
          original: original,
        );
    ExpenseGroup g(List<ExpenseDetails> expenses) => ExpenseGroup(
      title: 'Norway',
      currency: '€',
      participants: [anna],
      expenses: expenses,
    );

    final plain = CsvExporter.generate(g([e('Coffee', 3)]), loc);
    expect(plain.split('\n').first, isNot(contains(loc.csv_original_amount)));

    final mixed = CsvExporter.generate(
      g([
        e(
          'Ferry',
          38.69,
          original: const OriginalAmount(
            amount: 450,
            code: 'NOK',
            symbol: 'kr',
            rate: 11.63,
          ),
        ),
        e('Coffee', 3),
      ]),
      loc,
    ).split('\n');
    expect(
      mixed.first,
      endsWith('${loc.csv_original_amount},${loc.csv_original_currency}'),
    );
    expect(mixed[1], endsWith(',450.00,NOK'));
    expect(mixed[2], endsWith(',,'));
  });

  test('a v9 database upgrades to v10 and keeps a second currency', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('sqlite_v10_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final path = '${dir.path}/expense_groups.db';

    final db = await databaseFactoryFfi.openDatabase(path);
    await createSqliteSchema(db);
    await db.execute('ALTER TABLE groups DROP COLUMN second_currency');
    await db.execute('ALTER TABLE expenses DROP COLUMN original');
    await db.insert('groups', {
      'id': 'g',
      'title': 'Norway',
      'currency': '€',
      'timestamp': DateTime(2026, 11, 1).millisecondsSinceEpoch,
    });
    await db.setVersion(9);
    await db.close();

    final repository = SqliteExpenseGroupRepository(databasePath: path);
    addTearDown(repository.close);
    final group = (await repository.getGroupById('g')).unwrap()!;
    expect(group.secondCurrency, isNull);

    final r = await repository.saveGroup(group.copyWith(secondCurrency: nok));
    expect(r.isSuccess, isTrue, reason: '${r.error}');
    expect((await repository.getGroupById('g')).unwrap()!.secondCurrency, nok);
  });
}
