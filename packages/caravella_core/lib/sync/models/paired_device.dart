/// A device this one has paired with via QR code or Bluetooth, trusted for
/// automatic sync of whichever groups have been explicitly granted to it
/// (see `paired_device_groups` / `SyncDao.grantGroupAccess`).
class PairedDevice {
  final String deviceId;
  final String deviceName;
  final String platform;
  final DateTime pairedAt;

  /// The peer's X25519 public key, base64-encoded — `null` for pairings
  /// created before end-to-end encryption was added, which must be redone
  /// to sync again (there's no key to encrypt with otherwise).
  final String? publicKey;

  const PairedDevice({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.pairedAt,
    this.publicKey,
  });

  factory PairedDevice.fromRow(Map<String, dynamic> row) => PairedDevice(
        deviceId: row['device_id'] as String,
        deviceName: row['device_name'] as String? ?? 'Unknown device',
        platform: row['platform'] as String? ?? 'unknown',
        pairedAt: DateTime.fromMillisecondsSinceEpoch(
          row['paired_at'] as int,
          isUtc: true,
        ),
        publicKey: row['public_key'] as String?,
      );
}
