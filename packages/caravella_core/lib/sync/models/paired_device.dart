/// A device this one has paired with via QR code, trusted for automatic
/// LAN sync.
class PairedDevice {
  final String deviceId;
  final String deviceName;
  final String platform;
  final DateTime pairedAt;

  const PairedDevice({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.pairedAt,
  });

  factory PairedDevice.fromRow(Map<String, dynamic> row) => PairedDevice(
        deviceId: row['device_id'] as String,
        deviceName: row['device_name'] as String? ?? 'Unknown device',
        platform: row['platform'] as String? ?? 'unknown',
        pairedAt: DateTime.fromMillisecondsSinceEpoch(
          row['paired_at'] as int,
          isUtc: true,
        ),
      );
}
