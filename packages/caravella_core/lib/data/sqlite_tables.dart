/// Table names for [SqliteExpenseGroupRepository]'s schema.
const String kTableGroups = 'groups';
const String kTableParticipants = 'participants';
const String kTableCategories = 'categories';
const String kTableExpenses = 'expenses';
const String kTableAttachments = 'attachments';

/// Sync metadata tables (schema v3), used by `SyncDao` and other sync
/// infrastructure.
const String kTableDeviceMeta = 'device_meta';
const String kTableSyncLog = 'sync_log';
