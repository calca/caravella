import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core/data/sqlite_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// v8 adds `groups.payments` (Settle up, as JSON). A v7 database upgrades
/// with no payments and stores them from then on.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late String dbPath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqlite_v8_payments_');
    dbPath = '${tempDir.path}/expense_groups.db';
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Today's schema without the v8 column, at version 7, with one group.
  Future<void> createV7Database() async {
    final db = await databaseFactoryFfi.openDatabase(dbPath);
    await createSqliteSchema(db);
    await db.execute('ALTER TABLE groups DROP COLUMN payments');
    await db.execute('ALTER TABLE groups DROP COLUMN budget_amount');
    await db.execute('ALTER TABLE groups DROP COLUMN budget_period');
    // v10's columns too: the upgrade adds them again.
    await db.execute('ALTER TABLE groups DROP COLUMN second_currency');
    await db.execute('ALTER TABLE expenses DROP COLUMN original');
    await db.insert('groups', {
      'id': 'g',
      'title': 'Norway',
      'currency': '€',
      'timestamp': DateTime(2026, 11, 1).millisecondsSinceEpoch,
    });
    await db.insert('participants', {
      'id': 'anna',
      'group_id': 'g',
      'name': 'Anna',
    });
    await db.insert('participants', {
      'id': 'luca',
      'group_id': 'g',
      'name': 'Luca',
    });
    await db.setVersion(7);
    await db.close();
  }

  test(
    'a v7 database upgrades with no payments, then keeps new ones',
    () async {
      await createV7Database();
      final repository = SqliteExpenseGroupRepository(databasePath: dbPath);
      addTearDown(repository.close);

      final group = (await repository.getGroupById('g')).unwrap()!;
      expect(group.title, 'Norway');
      expect(group.payments, isEmpty);

      final payment = SettlePayment(
        fromId: 'luca',
        toId: 'anna',
        amount: 42.5,
        date: DateTime(2026, 11, 10),
      );
      final saved = await repository.saveGroup(
        group.copyWith(payments: [payment]),
      );
      expect(saved.isSuccess, isTrue, reason: '${saved.error}');
      expect((await repository.getGroupById('g')).unwrap()!.payments, [
        payment,
      ]);
    },
  );
}
