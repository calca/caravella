import 'package:sqflite/sqflite.dart';
import '../model/expense_group.dart';
import '../model/expense_details.dart';
import '../model/expense_participant.dart';
import '../model/expense_category.dart';
import '../model/expense_location.dart';
import '../model/expense_group_type.dart';
import '../services/logging/logger_service.dart';
import '../sync/device_identity.dart';
import '../sync/utils/sync_clock.dart';
import 'sqlite_tables.dart';

/// Converts between [ExpenseGroup]/[ExpenseDetails] and the SQLite row
/// representation used by `SqliteExpenseGroupRepository`.
class SqliteGroupMapper {
  const SqliteGroupMapper();

  /// Load all groups from database (excludes soft-deleted groups)
  Future<List<ExpenseGroup>> loadAllGroups(Database db) async {
    final groupMaps = await db.query(
      kTableGroups,
      where: 'deleted = ?',
      whereArgs: [0],
    );
    final groups = <ExpenseGroup>[];

    for (final groupMap in groupMaps) {
      final group = await mapToGroup(db, groupMap);
      groups.add(group);
    }

    return groups;
  }

  /// Load a single group by ID
  Future<ExpenseGroup?> loadGroupById(Database db, String groupId) async {
    final groupMaps = await db.query(
      kTableGroups,
      where: 'id = ?',
      whereArgs: [groupId],
    );

    if (groupMaps.isEmpty) return null;

    return await mapToGroup(db, groupMaps.first);
  }

  /// Convert database map to ExpenseGroup
  Future<ExpenseGroup> mapToGroup(
    Database db,
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

    final expenses = <ExpenseDetails>[];
    for (final expenseMap in expenseMaps) {
      final expense = await mapToExpense(
        db,
        expenseMap,
        participants,
        categories,
      );
      expenses.add(expense);
    }

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
    );
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
      'device_id': deviceId,
      'updated_at': nowMs,
      'deleted': 0,
      'sync_version': 0,
    };
  }

  /// Convert database map to ExpenseDetails
  Future<ExpenseDetails> mapToExpense(
    Database db,
    Map<String, dynamic> map,
    List<ExpenseParticipant> participants,
    List<ExpenseCategory> categories,
  ) async {
    final paidById = map['paid_by_id'] as String;
    final categoryId = map['category_id'] as String;
    final expenseId = map['id'] as String;

    final paidBy = participants.firstWhere(
      (p) => p.id == paidById,
      orElse: () => ExpenseParticipant(id: paidById, name: 'Unknown'),
    );
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => ExpenseCategory(id: categoryId, name: 'Unknown'),
    );

    // Load attachments
    final attachmentMaps = await db.query(
      kTableAttachments,
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
    final attachments = attachmentMaps
        .map((m) => m['file_path'] as String)
        .toList();

    return ExpenseDetails(
      id: expenseId,
      name: map['name'] as String,
      amount: map['amount'] as double?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      category: category,
      paidBy: paidBy,
      note: map['note'] as String?,
      location:
          (map['location_latitude'] != null &&
              map['location_longitude'] != null)
          ? ExpenseLocation(
              latitude: map['location_latitude'] as double,
              longitude: map['location_longitude'] as double,
              name: map['location_name'] as String?,
            )
          : null,
      attachments: attachments,
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
    };
  }
}
