/// The single source of truth for timestamps in the sync subsystem.
///
/// All sync-related code must use [SyncClock] rather than calling
/// `DateTime.now()` directly, so that every timestamp is consistently UTC.
class SyncClock {
  SyncClock._();

  /// Returns the current UTC time as milliseconds since Unix epoch.
  static int nowMs() => DateTime.now().toUtc().millisecondsSinceEpoch;

  /// Parses an ISO 8601 string and returns milliseconds since Unix epoch.
  static int fromIso(String iso) =>
      DateTime.parse(iso).toUtc().millisecondsSinceEpoch;

  /// Converts milliseconds since Unix epoch to an ISO 8601 UTC string.
  static String toIso(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();
}
