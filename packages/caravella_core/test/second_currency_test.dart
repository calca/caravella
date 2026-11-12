import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A group's second currency and its expenses' original amounts: the model,
/// SQLite, and sync with a 2.4 peer (schema 1), which doesn't know them.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const nok = SecondCurrency(code: 'NOK', symbol: 'kr', rate: 11.63);
  const ferry = OriginalAmount(
    amount: 450,
    code: 'NOK',
    symbol: 'kr',
    rate: 11.63,
  );

  group('model', () {
    test('converts to the group currency, to the cent', () {
      expect(nok.toGroup(450), 38.69);
      expect(ferry.groupAmount, 38.69);
      expect(ferry.currency, nok);
    });

    test('survives JSON, and drops what it cannot read', () {
      expect(SecondCurrency.fromJson(nok.toJson()), nok);
      expect(OriginalAmount.fromJson(ferry.toJson()), ferry);
      expect(SecondCurrency.fromJson(null), isNull);
      expect(SecondCurrency.fromJson({'code': 'NOK', 'symbol': 'kr'}), isNull);
      expect(
        SecondCurrency.fromJson({'code': 'NOK', 'symbol': 'kr', 'rate': 0}),
        isNull,
      );
      expect(
        OriginalAmount.fromJson({...ferry.toJson(), 'amount': -1}),
        isNull,
      );
    });

    test('groups and expenses carry them, and copyWith can clear them', () {
      final e = ExpenseDetails(
        name: 'Ferry',
        amount: 38.69,
        paidBy: ExpenseParticipant(name: 'Anna'),
        category: ExpenseCategory(name: 'Transport'),
        date: DateTime(2026, 11, 11),
        original: ferry,
      );
      final g = ExpenseGroup(
        title: 'Norway',
        currency: '€',
        participants: const [],
        expenses: [e],
        secondCurrency: nok,
      );
      final back = ExpenseGroup.fromJson(g.toJson());
      expect(back.secondCurrency, nok);
      expect(back.expenses.single.original, ferry);
      expect(g.copyWith(secondCurrency: null).secondCurrency, isNull);
      expect(g.copyWith(title: 'x').secondCurrency, nok);
      expect(e.copyWith(original: null).original, isNull);
      expect(e.copyWith(name: 'x').original, ferry);
      expect(e.toJson().containsKey('original'), isTrue);
      expect(
        e.copyWith(original: null).toJson().containsKey('original'),
        isFalse,
      );
    });
  });

  group('storage and sync', () {
    late SqliteExpenseGroupRepository repository;
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('second_currency_');
      repository = SqliteExpenseGroupRepository(
        databasePath: '${tempDir.path}/test.db',
      );
      await repository.getAllGroups();
    });

    tearDown(() async {
      await repository.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    final anna = ExpenseParticipant(id: 'anna', name: 'Anna');
    final transport = ExpenseCategory(id: 'transport', name: 'Transport');

    ExpenseDetails expense(
      String id,
      double amount, {
      OriginalAmount? original,
    }) => ExpenseDetails(
      id: id,
      name: id,
      amount: amount,
      paidBy: anna,
      category: transport,
      date: DateTime(2026, 11, 11),
      original: original,
    );

    ExpenseGroup trip({
      String title = 'Norway',
      SecondCurrency? second,
      List<ExpenseDetails>? expenses,
    }) => ExpenseGroup(
      id: 'g',
      title: title,
      currency: '€',
      participants: [anna],
      categories: [transport],
      expenses: expenses ?? [expense('ferry', 38.69, original: ferry)],
      secondCurrency: second,
    );

    Future<ExpenseGroup> stored() async =>
        (await repository.getGroupById('g')).unwrap()!;

    Future<void> save(ExpenseGroup g) async {
      final r = await repository.saveGroup(g);
      expect(r.isSuccess, isTrue, reason: '${r.error}');
    }

    Map<String, dynamic> delta(
      ExpenseGroup g, {
      int? schema,
      bool strip = false,
    }) {
      final json = g.toJson();
      if (strip) {
        json.remove('secondCurrency');
        for (final e in json['expenses'] as List) {
          (e as Map).remove('original');
        }
      }
      json['_sync'] = {
        'device_id': 'peer',
        'updated_at': SyncClock.nowMs() + 1000,
        'sync_version': 1,
      };
      return {
        'schema': ?schema,
        'device_id': 'peer',
        'device_name': 'Pixel 9',
        'timestamp': SyncClock.nowMs(),
        'groups': [json],
        'deleted_groups': <Map<String, dynamic>>[],
      };
    }

    Future<void> apply(Map<String, dynamic> d) async {
      final db = await repository.database;
      final dao = SyncDao(db);
      await dao.grantGroupAccess('peer', 'g');
      final result = await ConflictResolver(
        syncDao: dao,
      ).applyDelta(db, d, 'lan');
      expect(result.applied, 1);
    }

    test('SQLite keeps the second currency and original amounts', () async {
      await save(trip(second: nok));
      final g = await stored();
      expect(g.secondCurrency, nok);
      expect(g.expenses.single.original, ferry);
      expect(g.expenses.single.amount, 38.69);
    });

    test('a schema 2 delta brings them, and can remove them', () async {
      await save(trip(expenses: [expense('ferry', 38.69)]));
      await apply(delta(trip(second: nok), schema: 2));
      expect((await stored()).secondCurrency, nok);
      expect((await stored()).expenses.single.original, ferry);

      await apply(delta(trip(expenses: [expense('ferry', 38.69)]), schema: 2));
      expect((await stored()).secondCurrency, isNull);
      expect((await stored()).expenses.single.original, isNull);
    });

    test(
      'a group from 2.4 keeps them here, unless it changed the amount',
      () async {
        await save(
          trip(
            second: nok,
            expenses: [
              expense('ferry', 38.69, original: ferry),
              expense('parking', 86, original: ferry),
            ],
          ),
        );
        // The 2.4 peer renamed the group and typed 90 € on the parking.
        await apply(
          delta(
            trip(
              title: 'Norway 2026',
              expenses: [expense('ferry', 38.69), expense('parking', 90)],
            ),
            strip: true,
          ),
        );
        final g = await stored();
        expect(g.title, 'Norway 2026');
        expect(g.secondCurrency, nok);
        final byId = {for (final e in g.expenses) e.id: e};
        expect(byId['ferry']!.original, ferry);
        expect(byId['parking']!.amount, 90);
        expect(byId['parking']!.original, isNull);
      },
    );
  });
}
