import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/expense/widgets/expense_authorship_info.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

ExpenseDetails _buildExpense({
  ExpenseAuthor? createdBy,
  ExpenseAuthor? updatedBy,
}) {
  return ExpenseDetails(
    id: 'e1',
    name: 'Test Expense',
    amount: 10.0,
    paidBy: ExpenseParticipant(name: 'Alice', id: 'p1'),
    category: ExpenseCategory(name: 'Food', id: 'c1'),
    date: DateTime(2026, 1, 1),
    createdBy: createdBy,
    updatedBy: updatedBy,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildAuthorshipLines', () {
    const creator = ExpenseAuthor(deviceId: 'device-1', userName: 'Mario');
    const editor = ExpenseAuthor(deviceId: 'device-2', userName: 'Luigi');

    test('shows only "added by" when never edited by someone else', () {
      final expense = _buildExpense(createdBy: creator, updatedBy: creator);

      final lines = buildAuthorshipLines(
        expense: expense,
        addedByLabel: 'Added by',
        editedByLabel: 'Edited by',
      );

      expect(lines, hasLength(1));
      expect(lines.single.label, equals('Added by'));
      expect(lines.single.name, equals('Mario'));
    });

    test('shows both lines when creator and editor differ', () {
      final expense = _buildExpense(createdBy: creator, updatedBy: editor);

      final lines = buildAuthorshipLines(
        expense: expense,
        addedByLabel: 'Added by',
        editedByLabel: 'Edited by',
      );

      expect(lines, hasLength(2));
      expect(lines[0].label, equals('Added by'));
      expect(lines[0].name, equals('Mario'));
      expect(lines[1].label, equals('Edited by'));
      expect(lines[1].name, equals('Luigi'));
    });

    test(
      'shows only "edited by" when createdBy has no display name (legacy row)',
      () {
        final expense = _buildExpense(createdBy: null, updatedBy: editor);

        final lines = buildAuthorshipLines(
          expense: expense,
          addedByLabel: 'Added by',
          editedByLabel: 'Edited by',
        );

        expect(lines, hasLength(1));
        expect(lines.single.label, equals('Edited by'));
        expect(lines.single.name, equals('Luigi'));
      },
    );

    test('shows nothing when both are null', () {
      final expense = _buildExpense();

      final lines = buildAuthorshipLines(
        expense: expense,
        addedByLabel: 'Added by',
        editedByLabel: 'Edited by',
      );

      expect(lines, isEmpty);
    });
  });

  group('ExpenseAuthorshipInfo widget', () {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    late Directory tempDir;
    late SqliteExpenseGroupRepository repository;
    late SyncOrchestrator orchestrator;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync(
        'expense_authorship_widget_${DateTime.now().millisecondsSinceEpoch}',
      );
      repository = SqliteExpenseGroupRepository(
        databasePath: '${tempDir.path}/repo.db',
      );
      await repository.getAllGroups(); // trigger DB creation
      orchestrator = SyncOrchestrator(
        lanChannel: LanSyncChannel(),
        syncManager: SyncManager(repository: repository),
      );
      // Starts the sync manager (DB-only) and checks the LAN-enabled pref,
      // which defaults to false in tests — no platform channel is touched.
      await orchestrator.initialize();
    });

    tearDown(() async {
      await repository.close();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    Widget app(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

    final group = ExpenseGroup(
      id: 'g1',
      title: 'Group',
      currency: 'EUR',
      participants: [ExpenseParticipant(name: 'Alice', id: 'p1')],
      categories: [ExpenseCategory(name: 'Food', id: 'c1')],
      expenses: const [],
    );

    testWidgets('renders nothing when the group has no paired devices', (
      tester,
    ) async {
      final expense = _buildExpense(
        createdBy: const ExpenseAuthor(deviceId: 'device-1', userName: 'Mario'),
        updatedBy: const ExpenseAuthor(deviceId: 'device-1', userName: 'Mario'),
      );

      await tester.pumpWidget(
        app(
          ExpenseAuthorshipInfo(
            orchestrator: orchestrator,
            group: group,
            expense: expense,
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(find.textContaining('Mario'), findsNothing);
    });

    testWidgets('renders attribution once the group has a paired device', (
      tester,
    ) async {
      // sqflite_common_ffi does real (non-fake-clock) async I/O — it must
      // run inside `runAsync`, never while pumping frames. `pumpWidget`/
      // `pumpAndSettle` themselves must stay outside `runAsync` (mixing the
      // two hangs), so: do the real writes, pump normally to trigger
      // `ExpenseAuthorshipInfo`'s own real query, give that query a moment
      // to complete via a second `runAsync`, then settle normally.
      await tester.runAsync(() async {
        final db = await repository.database;
        final syncDao = SyncDao(db);
        await syncDao.addPairedDevice(
          deviceId: 'device-2',
          deviceName: 'Other Phone',
          platform: 'android',
        );
        await syncDao.grantGroupAccess('device-2', group.id);
      });

      const creator = ExpenseAuthor(deviceId: 'device-1', userName: 'Mario');
      const editor = ExpenseAuthor(deviceId: 'device-2', userName: 'Luigi');
      final expense = _buildExpense(createdBy: creator, updatedBy: editor);

      await tester.pumpWidget(
        app(
          ExpenseAuthorshipInfo(
            orchestrator: orchestrator,
            group: group,
            expense: expense,
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();

      expect(find.textContaining('Mario'), findsOneWidget);
      expect(find.textContaining('Luigi'), findsOneWidget);
    });
  });
}
