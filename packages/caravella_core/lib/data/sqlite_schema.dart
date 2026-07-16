import 'package:sqflite/sqflite.dart';
import 'sqlite_tables.dart';

/// Creates the SQLite schema (tables + indexes) used by
/// [SqliteExpenseGroupRepository].
Future<void> createSqliteSchema(Database db) async {
  // Groups table (includes sync columns from schema v3)
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
      auto_location_enabled INTEGER NOT NULL DEFAULT 0,
      device_id TEXT NOT NULL DEFAULT '',
      updated_at INTEGER NOT NULL DEFAULT 0,
      deleted INTEGER NOT NULL DEFAULT 0,
      sync_version INTEGER NOT NULL DEFAULT 0,
      sync_enabled INTEGER NOT NULL DEFAULT 0
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
      created_by_device_id TEXT,
      created_by_device_name TEXT,
      created_by_user_name TEXT,
      updated_by_device_id TEXT,
      updated_by_device_name TEXT,
      updated_by_user_name TEXT,
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

  // Sync metadata tables
  await db.execute('''
    CREATE TABLE $kTableDeviceMeta (
      device_id TEXT PRIMARY KEY,
      device_name TEXT,
      last_seen INTEGER,
      vector_clock TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE $kTableSyncLog (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      peer_id TEXT NOT NULL,
      channel TEXT NOT NULL,
      synced_at INTEGER NOT NULL,
      delta_sent INTEGER NOT NULL DEFAULT 0,
      delta_recv INTEGER NOT NULL DEFAULT 0
    )
  ''');

  // Sync indexes
  await db.execute(
    'CREATE INDEX idx_groups_updated_at ON $kTableGroups(updated_at)',
  );
  await db.execute(
    'CREATE INDEX idx_groups_deleted ON $kTableGroups(deleted)',
  );

  // Paired devices (schema v4; public_key added in v5)
  await db.execute('''
    CREATE TABLE $kTablePairedDevices (
      device_id TEXT PRIMARY KEY,
      device_name TEXT NOT NULL,
      platform TEXT,
      paired_at INTEGER NOT NULL,
      public_key TEXT
    )
  ''');

  // Per-group pairing grants (schema v5)
  await db.execute('''
    CREATE TABLE $kTablePairedDeviceGroups (
      device_id TEXT NOT NULL,
      group_id TEXT NOT NULL,
      granted_at INTEGER NOT NULL,
      PRIMARY KEY (device_id, group_id)
    )
  ''');
}
