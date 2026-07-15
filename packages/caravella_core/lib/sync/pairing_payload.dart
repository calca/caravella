import 'dart:convert';

/// Data exchanged via QR code to establish a mutual LAN sync pairing.
///
/// Encodes enough for the scanning device to connect directly to the
/// showing device's HTTP pairing endpoint (`host`/`port`), without
/// depending on mDNS discovery timing.
class PairingPayload {
  static const int _schemaVersion = 1;

  final String deviceId;
  final String deviceName;
  final String platform;
  final String host;
  final int port;

  const PairingPayload({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.host,
    required this.port,
  });

  String toQrData() => jsonEncode({
        'v': _schemaVersion,
        'device_id': deviceId,
        'device_name': deviceName,
        'platform': platform,
        'host': host,
        'port': port,
      });

  /// Parses QR-scanned data. Returns `null` if [data] isn't a valid pairing
  /// payload — e.g. an unrelated QR code was scanned.
  static PairingPayload? tryParse(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final deviceId = json['device_id'] as String?;
      final host = json['host'] as String?;
      final port = json['port'] as int?;
      if (deviceId == null || host == null || port == null) return null;

      return PairingPayload(
        deviceId: deviceId,
        deviceName: json['device_name'] as String? ?? 'Unknown device',
        platform: json['platform'] as String? ?? 'unknown',
        host: host,
        port: port,
      );
    } catch (_) {
      return null;
    }
  }
}
