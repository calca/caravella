/// How sync with one paired device is doing, for the paired devices list
/// and its detail sheet.
class DeviceSyncInfo {
  /// The last exchange with the device: this session's history first, else
  /// the sync log (so it survives a restart). Null when it never synced.
  final DateTime? lastSyncAt;

  /// Whether that last exchange, in this session, failed or had errors. An
  /// exchange from an earlier session only tells the time.
  final bool lastFailed;

  /// The groups this device is granted.
  final List<String> groupIds;

  const DeviceSyncInfo({
    required this.lastSyncAt,
    required this.lastFailed,
    required this.groupIds,
  });
}
