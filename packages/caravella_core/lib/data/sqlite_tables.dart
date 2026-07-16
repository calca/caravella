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

/// Paired devices (schema v4) — devices this one has exchanged a QR pairing
/// handshake with over LAN. Only paired devices are eligible for automatic
/// LAN sync; see `LanSyncChannel`'s peer-authorization gating.
const String kTablePairedDevices = 'paired_devices';

/// Per-group pairing grants (schema v5) — which paired device is authorized
/// to sync which specific group. A device being in `paired_devices` only
/// establishes its identity/encryption key; this table is what actually
/// grants it access to a given group's data.
const String kTablePairedDeviceGroups = 'paired_device_groups';
