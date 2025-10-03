import 'dart:convert';

/// Payload structure for QR code key exchange
/// Contains encrypted group key using ECDH
class QrKeyExchangePayload {
  /// Group ID this QR code is for
  final String groupId;

  /// Protocol version for future compatibility
  final int version;

  /// Encryption algorithm identifier
  final String algorithm;

  /// Ephemeral public key (base64 encoded) for ECDH
  final String ephemeralPublicKey;

  /// Nonce for encryption (base64 encoded)
  final String nonce;

  /// Encrypted group key (base64 encoded)
  final String encryptedGroupKey;

  /// Timestamp when QR was generated (for expiration)
  final DateTime timestamp;

  /// Optional expiration time in seconds (default 300 = 5 minutes)
  final int expirationSeconds;

  QrKeyExchangePayload({
    required this.groupId,
    this.version = 1,
    this.algorithm = 'ECDH-X25519-AES256GCM',
    required this.ephemeralPublicKey,
    required this.nonce,
    required this.encryptedGroupKey,
    DateTime? timestamp,
    this.expirationSeconds = 300,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Check if this QR code has expired
  bool get isExpired {
    final now = DateTime.now();
    final expirationTime = timestamp.add(Duration(seconds: expirationSeconds));
    return now.isAfter(expirationTime);
  }

  /// Convert to JSON for QR code encoding
  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'version': version,
        'algorithm': algorithm,
        'ephemeralPublicKey': ephemeralPublicKey,
        'nonce': nonce,
        'encryptedGroupKey': encryptedGroupKey,
        'timestamp': timestamp.toIso8601String(),
        'expirationSeconds': expirationSeconds,
      };

  /// Create from JSON (when scanning QR code)
  factory QrKeyExchangePayload.fromJson(Map<String, dynamic> json) {
    return QrKeyExchangePayload(
      groupId: json['groupId'] as String,
      version: json['version'] as int? ?? 1,
      algorithm: json['algorithm'] as String? ?? 'ECDH-X25519-AES256GCM',
      ephemeralPublicKey: json['ephemeralPublicKey'] as String,
      nonce: json['nonce'] as String,
      encryptedGroupKey: json['encryptedGroupKey'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      expirationSeconds: json['expirationSeconds'] as int? ?? 300,
    );
  }

  /// Encode to JSON string for QR code
  String toJsonString() => jsonEncode(toJson());

  /// Decode from JSON string (from QR scan)
  static QrKeyExchangePayload fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return QrKeyExchangePayload.fromJson(json);
  }

  @override
  String toString() => 'QrKeyExchangePayload('
      'groupId: $groupId, '
      'version: $version, '
      'algorithm: $algorithm, '
      'expired: $isExpired)';
}
