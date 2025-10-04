import 'dart:io';
import 'package:flutter/foundation.dart';

/// Information about a device that has access to a group
class DeviceInfo {
  /// Unique device identifier
  final String deviceId;

  /// Human-readable device name
  final String deviceName;

  /// Platform (iOS, Android, Web, etc.)
  final String platform;

  /// When this device was added to the group
  final DateTime addedAt;

  /// Last time this device was active (synced)
  final DateTime lastActiveAt;

  /// Whether this is the current device
  final bool isCurrentDevice;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.addedAt,
    required this.lastActiveAt,
    this.isCurrentDevice = false,
  });

  /// Create from JSON
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      platform: json['platform'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      isCurrentDevice: json['isCurrentDevice'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'platform': platform,
        'addedAt': addedAt.toIso8601String(),
        'lastActiveAt': lastActiveAt.toIso8601String(),
        'isCurrentDevice': isCurrentDevice,
      };

  /// Create a DeviceInfo for the current device
  static Future<DeviceInfo> createForCurrentDevice(String deviceId) async {
    return DeviceInfo(
      deviceId: deviceId,
      deviceName: await _getDeviceName(),
      platform: _getPlatform(),
      addedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      isCurrentDevice: true,
    );
  }

  /// Get platform string
  static String _getPlatform() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Get device name
  static Future<String> _getDeviceName() async {
    // In a real implementation, you'd use device_info_plus or similar
    // to get the actual device name
    final platform = _getPlatform();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return '$platform Device $timestamp';
  }

  /// Copy with updated fields
  DeviceInfo copyWith({
    String? deviceName,
    DateTime? lastActiveAt,
    bool? isCurrentDevice,
  }) {
    return DeviceInfo(
      deviceId: deviceId,
      deviceName: deviceName ?? this.deviceName,
      platform: platform,
      addedAt: addedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
    );
  }

  @override
  String toString() => 'DeviceInfo('
      'id: $deviceId, '
      'name: $deviceName, '
      'platform: $platform, '
      'current: $isCurrentDevice)';
}
