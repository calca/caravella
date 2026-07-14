import 'package:sqflite/sqflite.dart';
import 'sqlite_tables.dart';

/// Creates the SQLite schema (tables + indexes) used by
/// [SqliteExpenseGroupRepository].
Future<void> createSqliteSchema(Database db) async {
  // Groups table
  await db.execute('''
    CREATE TABLE $kTableGroups (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      currency TEXT NOT NULL,
      start_date INTEGER,
      end_date INTEGER,
      timestamp INTEGER NOT NULL,
      pinned INTEGER NOT NULL DEFAULT 0,
      archived INTEGER NOT NULL DEFAULT 0,
      file TEXT,
      color INTEGER,
      notification_enabled INTEGER NOT NULL DEFAULT 0,
      group_type TEXT,
      auto_location_enabled INTEGER NOT NULL DEFAULT 0
    )
  ''');

  // Participants table
  await db.execute('''
    CREATE TABLE $kTableParticipants (
      id TEXT PRIMARY KEY,
      group_id TEXT NOT NULL,
      name TEXT NOT NULL,
      FOREIGN KEY (group_id) REFERENCES $kTableGroups (id) ON DELETE CASCADE
    )
  ''');

  // Categories table
  await db.execute('''
    CREATE TABLE $kTableCategories (
      id TEXT PRIMARY KEY,
      group_id TEXT NOT NULL,
      name TEXT NOT NULL,
      FOREIGN KEY (group_id) REFERENCES $kTableGroups (id) ON DELETE CASCADE
    )
  ''');

  // Expenses table
  await db.execute('''
    CREATE TABLE $kTableExpenses (
      id TEXT PRIMARY KEY,
      group_id TEXT NOT NULL,
      name TEXT NOT NULL,
      amount REAL,
      date INTEGER NOT NULL,
      category_id TEXT NOT NULL,
      paid_by_id TEXT NOT NULL,
      location_latitude REAL,
      location_longitude REAL,
      location_name TEXT,
      note TEXT,
      FOREIGN KEY (group_id) REFERENCES $kTableGroups (id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES $kTableCategories (id),
      FOREIGN KEY (paid_by_id) REFERENCES $kTableParticipants (id)
    )
  ''');

  // Attachments table
  await db.execute('''
    CREATE TABLE $kTableAttachments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      expense_id TEXT NOT NULL,
      file_path TEXT NOT NULL,
      FOREIGN KEY (expense_id) REFERENCES $kTableExpenses (id) ON DELETE CASCADE
    )
  ''');

  // Indexes for performance
  await db.execute(
    'CREATE INDEX idx_groups_timestamp ON $kTableGroups(timestamp DESC)',
  );
  await db.execute(
    'CREATE INDEX idx_groups_pinned ON $kTableGroups(pinned, archived)',
  );
  await db.execute(
    'CREATE INDEX idx_participants_group ON $kTableParticipants(group_id)',
  );
  await db.execute(
    'CREATE INDEX idx_categories_group ON $kTableCategories(group_id)',
  );
  await db.execute(
    'CREATE INDEX idx_expenses_group ON $kTableExpenses(group_id)',
  );
  await db.execute(
    'CREATE INDEX idx_expenses_date ON $kTableExpenses(date DESC)',
  );
}
