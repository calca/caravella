import 'package:sqflite/sqflite.dart';

import '../model/expense_group.dart';
import 'sqlite_group_mapper.dart';
import 'sqlite_tables.dart';

/// Writes an [ExpenseGroup] to its tables touching only the rows that
/// changed.
///
/// A save used to delete every participant, category and expense of the
/// group and insert them again. Here the group is compared with what the
/// database holds: new rows are inserted, changed ones updated, missing ones
/// deleted, and the rest is left alone. So adding one expense to a group of a
/// thousand writes one row, and each expense keeps its own `updated_at`: the
/// time *it* last changed, which sync needs to merge two phones' changes
/// expense by expense. A deleted expense leaves a row in
/// [kTableExpenseTombstones] for the same reason.
class SqliteGroupWriter {
  const SqliteGroupWriter._();

  static const _mapper = SqliteGroupMapper();

  /// Writes [group] inside [txn].
  ///
  /// [groupRow] is the `groups` row to store (with its sync columns).
  /// [changedAt] stamps the expenses this write inserts or changes, and the
  /// tombstones of the ones it deletes. [recordDeletions] false deletes
  /// without tombstones: for a copy of the group received from elsewhere,
  /// where a missing expense is not this device's deletion.
  static Future<void> write(
    Transaction txn,
    ExpenseGroup group,
    Map<String, Object?> groupRow, {
    required int changedAt,
    bool recordDeletions = true,
  }) async {
    // The group row: updated in place. `INSERT OR REPLACE` would delete the
    // row first, and with it (foreign keys on) every row of the group.
    final updated = await txn.update(
      kTableGroups,
      groupRow,
      where: 'id = ?',
      whereArgs: [group.id],
    );
    if (updated == 0) await txn.insert(kTableGroups, groupRow);

    // People and categories first: expenses refer to them.
    final removedParticipants = await _writeNamed(
      txn,
      kTableParticipants,
      group.id,
      {for (final p in group.participants) p.id: p.name},
    );
    final removedCategories = await _writeNamed(
      txn,
      kTableCategories,
      group.id,
      {for (final c in group.categories) c.id: c.name},
    );

    await _writeExpenses(
      txn,
      group,
      changedAt: changedAt,
      recordDeletions: recordDeletions,
    );

    // Only now the people and categories no expense refers to any more.
    await _deleteIds(txn, kTableParticipants, removedParticipants);
    await _deleteIds(txn, kTableCategories, removedCategories);
  }

  /// Inserts and renames the rows of [table] (id, group_id, name) to match
  /// [wanted] (id → name); returns the ids to delete.
  static Future<List<String>> _writeNamed(
    Transaction txn,
    String table,
    String groupId,
    Map<String, String> wanted,
  ) async {
    final existing = {
      for (final row in await txn.query(
        table,
        columns: ['id', 'name'],
        where: 'group_id = ?',
        whereArgs: [groupId],
      ))
        row['id'] as String: row['name'] as String?,
    };
    for (final entry in wanted.entries) {
      if (!existing.containsKey(entry.key)) {
        await txn.insert(table, {
          'id': entry.key,
          'group_id': groupId,
          'name': entry.value,
        });
      } else if (existing[entry.key] != entry.value) {
        await txn.update(
          table,
          {'name': entry.value},
          where: 'id = ?',
          whereArgs: [entry.key],
        );
      }
    }
    return [
      for (final id in existing.keys)
        if (!wanted.containsKey(id)) id,
    ];
  }

  static Future<void> _writeExpenses(
    Transaction txn,
    ExpenseGroup group, {
    required int changedAt,
    required bool recordDeletions,
  }) async {
    final existing = {
      for (final row in await txn.query(
        kTableExpenses,
        where: 'group_id = ?',
        whereArgs: [group.id],
      ))
        row['id'] as String: row,
    };
    final existingAttachments = <String, List<String>>{};
    for (final row in await txn.rawQuery(
      'SELECT a.expense_id, a.file_path FROM $kTableAttachments a '
      'JOIN $kTableExpenses e ON e.id = a.expense_id '
      'WHERE e.group_id = ? ORDER BY a.id',
      [group.id],
    )) {
      (existingAttachments[row['expense_id'] as String] ??= []).add(
        row['file_path'] as String,
      );
    }

    final kept = <String>{};
    for (final expense in group.expenses) {
      // The same expense twice in the list: the first one counts.
      if (!kept.add(expense.id)) continue;
      final row = _mapper.expenseToMap(expense, group.id);
      final old = existing[expense.id];
      final attachmentsChanged = !_sameList(
        existingAttachments[expense.id] ?? const [],
        expense.attachments,
      );

      if (old == null) {
        await txn.insert(kTableExpenses, {...row, 'updated_at': changedAt});
        // Back after a deletion (an undo, a restore): not deleted any more.
        await txn.delete(
          kTableExpenseTombstones,
          where: 'expense_id = ?',
          whereArgs: [expense.id],
        );
      } else if (attachmentsChanged ||
          row.entries.any((e) => old[e.key] != e.value)) {
        await txn.update(
          kTableExpenses,
          {...row, 'updated_at': changedAt},
          where: 'id = ?',
          whereArgs: [expense.id],
        );
      }

      if (attachmentsChanged) {
        await txn.delete(
          kTableAttachments,
          where: 'expense_id = ?',
          whereArgs: [expense.id],
        );
        for (final path in expense.attachments) {
          await txn.insert(kTableAttachments, {
            'expense_id': expense.id,
            'file_path': path,
          });
        }
      }
    }

    final removed = [
      for (final id in existing.keys)
        if (!kept.contains(id)) id,
    ];
    await _deleteIds(txn, kTableAttachments, removed, column: 'expense_id');
    await _deleteIds(txn, kTableExpenses, removed);
    if (recordDeletions) {
      for (final id in removed) {
        await txn.insert(kTableExpenseTombstones, {
          'expense_id': id,
          'group_id': group.id,
          'deleted_at': changedAt,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  static bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static Future<void> _deleteIds(
    Transaction txn,
    String table,
    List<String> ids, {
    String column = 'id',
  }) async {
    // In chunks: SQLite limits the variables of one statement.
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
      await txn.delete(
        table,
        where: '$column IN (${List.filled(chunk.length, '?').join(', ')})',
        whereArgs: chunk,
      );
    }
  }
}
