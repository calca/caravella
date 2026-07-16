import 'dart:convert';

import 'utils/sync_clock.dart';

/// Data exchanged via QR code to establish a mutual LAN sync pairing.
///
/// Encodes enough for the scanning device to connect directly to the
/// showing device's HTTP pairing endpoint (`host`/`port`), without
/// depending on mDNS discovery timing.
class PairingPayload {
  static const int _schemaVersion = 1;

  /// How long a generated code stays valid before it must be regenerated —
  /// keeps a QR code shown on screen (e.g. photographed, or left open) from
  /// being usable indefinitely.
  static const int validityMs = 5 * 60 * 1000;

  final String deviceId;
  final String deviceName;
  final String platform;
  final String host;
  final int port;

  /// UTC-epoch ms when this payload was generated, used to enforce
  /// [validityMs].
  final int createdAtMs;

  /// The group this code is sharing — pairing now grants access to this
  /// specific group only, not every synced group (see
  /// `SyncManager.grantGroupAccess`).
  final String groupId;

  /// The shared group's title, for display on the scanning side only
  /// ("Pairing to share «Vacanza a Roma»") — not used for anything
  /// security-relevant.
  final String groupTitle;

  const PairingPayload({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.host,
    required this.port,
    required this.createdAtMs,
    required this.groupId,
    required this.groupTitle,
  });

  /// UTC-epoch ms after which this payload is no longer valid for pairing.
  int get expiresAtMs => createdAtMs + validityMs;

  /// Whether this payload is past its [validityMs] window.
  bool get isExpired => SyncClock.nowMs() >= expiresAtMs;

  /// Whether [host] falls in `10.0.2.0/24` — the private NAT subnet the
  /// Android Emulator assigns to each running instance (`10.0.2.15` for the
  /// device itself, incrementing for additional instances). That address is
  /// only reachable from inside that one emulator's VM, never from another
  /// emulator instance or from the host's real network — pairing across it
  /// always fails, so callers should surface a specific message instead of
  /// a raw connection error.
  bool get isLikelyUnreachableEmulatorHost => host.startsWith('10.0.2.');

  String toQrData() => jsonEncode({
        'v': _schemaVersion,
        'device_id': deviceId,
        'device_name': deviceName,
        'platform': platform,
        'host': host,
        'port': port,
        'created_at_ms': createdAtMs,
        'group_id': groupId,
        'group_title': groupTitle,
      });

  /// Parses QR-scanned data. Returns `null` if [data] isn't a valid pairing
  /// payload — e.g. an unrelated QR code was scanned.
  static PairingPayload? tryParse(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final deviceId = json['device_id'] as String?;
      final host = json['host'] as String?;
      final port = json['port'] as int?;
      final createdAtMs = json['created_at_ms'] as int?;
      final groupId = json['group_id'] as String?;
      if (deviceId == null || host == null || port == null || groupId == null) {
        return null;
      }

      return PairingPayload(
        deviceId: deviceId,
        deviceName: json['device_name'] as String? ?? 'Unknown device',
        platform: json['platform'] as String? ?? 'unknown',
        host: host,
        port: port,
        // Older payloads without a timestamp are treated as already expired
        // rather than trusted indefinitely.
        createdAtMs: createdAtMs ?? 0,
        groupId: groupId,
        groupTitle: json['group_title'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}
