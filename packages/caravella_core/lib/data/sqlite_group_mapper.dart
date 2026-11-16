import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import '../model/expense_group.dart';
import '../model/expense_details.dart';
import '../model/expense_participant.dart';
import '../model/expense_category.dart';
import '../model/expense_location.dart';
import '../model/expense_author.dart';
import '../model/expense_group_type.dart';
import '../model/group_budget.dart';
import '../model/second_currency.dart';
import '../model/settle_payment.dart';
import '../services/logging/logger_service.dart';
import '../sync/device_identity.dart';
import '../sync/utils/sync_clock.dart';
import 'sqlite_tables.dart';

/// Converts between [ExpenseGroup]/[ExpenseDetails] and the SQLite row
/// representation used by `SqliteExpenseGroupRepository`.
class SqliteGroupMapper {
  const SqliteGroupMapper();

  /// Load groups from database (excludes soft-deleted groups). [where]
  /// narrows them in SQL (e.g. `archived = 0`), so the groups left out are
  /// not read at all, expenses included.
  Future<List<ExpenseGroup>> loadAllGroups(
    DatabaseExecutor db, {
    String? where,
    List<Object?> whereArgs = const [],
  }) async {
    final groupMaps = await db.query(
      kTableGroups,
      where: where == null ? 'deleted = 0' : 'deleted = 0 AND ($where)',
      whereArgs: whereArgs,
    );
    final groups = <ExpenseGroup>[];

    for (final groupMap in groupMaps) {
      final group = await mapToGroup(db, groupMap);
      groups.add(group);
    }

    return groups;
  }

  /// Load a single group by ID (excludes soft-deleted groups)
  Future<ExpenseGroup?> loadGroupById(
    DatabaseExecutor db,
    String groupId,
  ) async {
    final groupMaps = await db.query(
      kTableGroups,
      where: 'id = ? AND deleted = ?',
      whereArgs: [groupId, 0],
    );

    if (groupMaps.isEmpty) return null;

    return await mapToGroup(db, groupMaps.first);
  }

  /// Convert database map to ExpenseGroup
  Future<ExpenseGroup> mapToGroup(
    DatabaseExecutor db,
    Map<String, dynamic> map,
  ) async {
    final groupId = map['id'] as String;

    // Load participants
    final participantMaps = await db.query(
      kTableParticipants,
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    final participants = participantMaps
        .map(
          (m) => ExpenseParticipant(
            id: m['id'] as String,
            name: m['name'] as String,
          ),
        )
        .toList();

    // Load categories
    final categoryMaps = await db.query(
      kTableCategories,
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    final categories = categoryMaps
        .map(
          (m) =>
              ExpenseCategory(id: m['id'] as String, name: m['name'] as String),
        )
        .toList();

    // Load expenses
    final expenseMaps = await db.query(
      kTableExpenses,
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'date DESC',
    );

    // The group's attachments in one query, not one per expense.
    final attachments = <String, List<String>>{};
    for (final row in await db.rawQuery(
      'SELECT a.expense_id, a.file_path FROM $kTableAttachments a '
      'JOIN $kTableExpenses e ON e.id = a.expense_id '
      'WHERE e.group_id = ? ORDER BY a.id',
      [groupId],
    )) {
      (attachments[row['expense_id'] as String] ??= []).add(
        row['file_path'] as String,
      );
    }
    final participantsById = {for (final p in participants) p.id: p};
    final categoriesById = {for (final c in categories) c.id: c};
    final expenses = [
      for (final expenseMap in expenseMaps)
        expenseFromMap(
          expenseMap,
          participantsById,
          categoriesById,
          attachments[expenseMap['id']] ?? const [],
        ),
    ];

    return ExpenseGroup(
      id: groupId,
      title: map['title'] as String,
      currency: map['currency'] as String,
      participants: participants,
      categories: categories,
      expenses: expenses,
      startDate: map['start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int)
          : null,
      endDate: map['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      pinned: (map['pinned'] as int) == 1,
      archived: (map['archived'] as int) == 1,
      file: map['file'] as String?,
      color: map['color'] as int?,
      notificationEnabled: (map['notification_enabled'] as int) == 1,
      groupType: map['group_type'] != null
          ? ExpenseGroupType.fromJson(map['group_type'])
          : null,
      autoLocationEnabled: (map['auto_location_enabled'] as int) == 1,
      syncEnabled: (map['sync_enabled'] as int?) == 1,
      payments: paymentsFromColumn(map['payments']),
      budget: budgetFromColumns(map),
      secondCurrency: jsonColumn(
        map['second_currency'],
        SecondCurrency.fromJson,
      ),
    );
  }

  /// The `payments` column: a JSON list, or null when there are none.
  static String? paymentsToColumn(List<SettlePayment> payments) =>
      payments.isEmpty
      ? null
      : jsonEncode(payments.map((p) => p.toJson()).toList());

  /// Reads the `payments` column back; an unreadable one counts as none.
  static List<SettlePayment> paymentsFromColumn(Object? value) {
    if (value is! String || value.isEmpty) return const [];
    try {
      return (jsonDecode(value) as List<dynamic>)
          .map((p) => SettlePayment.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.warning(
        'Unreadable payments column, ignored: $e',
        name: 'storage.sqlite',
      );
      return const [];
    }
  }

  /// The `budget_amount` and `budget_period` columns of [budget].
  static Map<String, Object?> budgetToColumns(GroupBudget? budget) => {
    'budget_amount': budget?.amount,
    'budget_period': budget?.period.toJson(),
  };

  /// Reads the budget columns of a group row back; null when unset.
  static GroupBudget? budgetFromColumns(Map<String, Object?> row) =>
      GroupBudget.fromJson({
        'amount': row['budget_amount'],
        'period': row['budget_period'],
      });

  /// A JSON object column ([SecondCurrency], [OriginalAmount]): null for
  /// none.
  static String? toJsonColumn(Map<String, dynamic>? json) =>
      json == null ? null : jsonEncode(json);

  /// Reads a JSON object column back with [parse]; an unreadable one counts
  /// as none.
  static T? jsonColumn<T>(Object? value, T? Function(Object?) parse) {
    if (value is! String || value.isEmpty) return null;
    try {
      return parse(jsonDecode(value));
    } catch (e) {
      LoggerService.warning(
        'Unreadable JSON column, ignored: $e',
        name: 'storage.sqlite',
      );
      return null;
    }
  }

  /// Convert ExpenseGroup to database map
  Map<String, dynamic> groupToMap(ExpenseGroup group) {
    final nowMs = SyncClock.nowMs();
    String deviceId = '';
    if (DeviceIdentity.isInitialized) {
      deviceId = DeviceIdentity.instance.deviceId;
    } else {
      LoggerService.debug(
        'DeviceIdentity not initialized — saving group with empty device_id',
        name: 'storage.sqlite',
      );
    }

    return {
      'id': group.id,
      'title': group.title,
      'currency': group.currency,
      'start_date': group.startDate?.millisecondsSinceEpoch,
      'end_date': group.endDate?.millisecondsSinceEpoch,
      'timestamp': group.timestamp.millisecondsSinceEpoch,
      'pinned': group.pinned ? 1 : 0,
      'archived': group.archived ? 1 : 0,
      'file': group.file,
      'color': group.color,
      'notification_enabled': group.notificationEnabled ? 1 : 0,
      'group_type': group.groupType?.toJson(),
      'auto_location_enabled': group.autoLocationEnabled ? 1 : 0,
      'sync_enabled': group.syncEnabled ? 1 : 0,
      'payments': paymentsToColumn(group.payments),
      ...budgetToColumns(group.budget),
      'second_currency': toJsonColumn(group.secondCurrency?.toJson()),
      'device_id': deviceId,
      'updated_at': nowMs,
      'deleted': 0,
      'sync_version': 0,
    };
  }

  /// Convert database map to ExpenseDetails, reading its attachments.
  /// For many expenses use [expenseFromMap] with the attachments read in
  /// one query.
  Future<ExpenseDetails> mapToExpense(
    DatabaseExecutor db,
    Map<String, dynamic> map,
    List<ExpenseParticipant> participants,
    List<ExpenseCategory> categories,
  ) async {
    final attachmentMaps = await db.query(
      kTableAttachments,
      where: 'expense_id = ?',
      whereArgs: [map['id']],
      orderBy: 'id',
    );
    return expenseFromMap(
      map,
      {for (final p in participants) p.id: p},
      {for (final c in categories) c.id: c},
      [for (final m in attachmentMaps) m['file_path'] as String],
    );
  }

  /// Convert database map to ExpenseDetails with these [attachments].
  ExpenseDetails expenseFromMap(
    Map<String, dynamic> map,
    Map<String, ExpenseParticipant> participants,
    Map<String, ExpenseCategory> categories,
    List<String> attachments,
  ) {
    final paidById = map['paid_by_id'] as String;
    final categoryId = map['category_id'] as String;
    final expenseId = map['id'] as String;

    final paidBy =
        participants[paidById] ??
        ExpenseParticipant(id: paidById, name: 'Unknown');
    final category =
        categories[categoryId] ??
        ExpenseCategory(id: categoryId, name: 'Unknown');

    return ExpenseDetails(
      id: expenseId,
      name: map['name'] as String,
      amount: map['amount'] as double?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      category: category,
      paidBy: paidBy,
      note: map['note'] as String?,
      location: _locationFromMap(map),
      attachments: attachments,
      createdBy: map['created_by_device_id'] != null
          ? ExpenseAuthor(
              deviceId: map['created_by_device_id'] as String,
              deviceName: map['created_by_device_name'] as String?,
              userName: map['created_by_user_name'] as String?,
            )
          : null,
      updatedBy: map['updated_by_device_id'] != null
          ? ExpenseAuthor(
              deviceId: map['updated_by_device_id'] as String,
              deviceName: map['updated_by_device_name'] as String?,
              userName: map['updated_by_user_name'] as String?,
            )
          : null,
      original: jsonColumn(map['original'], OriginalAmount.fromJson),
    );
  }

  /// The expense's place: the full one from `location_details` when saved
  /// (v7+), else just the coordinates and name of older rows.
  ExpenseLocation? _locationFromMap(Map<String, dynamic> map) {
    if (map['location_details'] case final String details) {
      try {
        return ExpenseLocation.fromJson(
          jsonDecode(details) as Map<String, dynamic>,
        );
      } catch (e) {
        LoggerService.warning(
          'Unreadable location details, using the coordinates: $e',
          name: 'storage.sqlite',
        );
      }
    }
    if (map['location_latitude'] == null || map['location_longitude'] == null) {
      return null;
    }
    return ExpenseLocation(
      latitude: map['location_latitude'] as double,
      longitude: map['location_longitude'] as double,
      name: map['location_name'] as String?,
    );
  }

  /// Convert ExpenseDetails to database map
  Map<String, dynamic> expenseToMap(ExpenseDetails expense, String groupId) {
    return {
      'id': expense.id,
      'group_id': groupId,
      'name': expense.name,
      'amount': expense.amount,
      'date': expense.date.millisecondsSinceEpoch,
      'category_id': expense.category.id,
      'paid_by_id': expense.paidBy.id,
      'note': expense.note,
      'location_latitude': expense.location?.latitude,
      'location_longitude': expense.location?.longitude,
      'location_name': expense.location?.name,
      'location_details': switch (expense.location) {
        final location? => jsonEncode(location.toJson()),
        null => null,
      },
      'created_by_device_id': expense.createdBy?.deviceId,
      'created_by_device_name': expense.createdBy?.deviceName,
      'created_by_user_name': expense.createdBy?.userName,
      'updated_by_device_id': expense.updatedBy?.deviceId,
      'updated_by_device_name': expense.updatedBy?.deviceName,
      'updated_by_user_name': expense.updatedBy?.userName,
      'original': toJsonColumn(expense.original?.toJson()),
    };
  }
}
