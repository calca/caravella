import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:caravella_core/services/logging/logger_service.dart';

/// Persistent device identity for P2P sync.
///
/// Generates and stores a stable UUID v4 per device using SharedPreferences.
/// Must be initialized with [initialize] before accessing any property.
class DeviceIdentity {
  static const _tag = 'sync.device_identity';
  static const _deviceIdKey = 'sync_device_id';

  static DeviceIdentity? _instance;

  /// The stable UUID v4 for this device, persisted across app restarts.
  final String deviceId;

  /// A human-readable name for this device (e.g. "iPhone di Marco").
  final String deviceName;

  /// The platform this device runs on.
  final DevicePlatform platform;

  DeviceIdentity._({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
  });

  /// Returns the singleton instance.
  ///
  /// Throws [StateError] if [initialize] has not been called.
  static DeviceIdentity get instance {
    if (_instance == null) {
      throw StateError(
        'DeviceIdentity has not been initialized. '
        'Call DeviceIdentity.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Whether the singleton has been initialized.
  static bool get isInitialized => _instance != null;

  /// Initializes the device identity singleton.
  ///
  /// Loads or generates a persistent device ID, and reads device hardware info.
  /// Safe to call multiple times — subsequent calls are no-ops.
  static Future<DeviceIdentity> initialize() async {
    if (_instance != null) return _instance!;

    final prefs = await SharedPreferences.getInstance();

    // Load or generate device ID
    var id = prefs.getString(_deviceIdKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_deviceIdKey, id);
      LoggerService.info('Generated new device ID: $id', name: _tag);
    } else {
      LoggerService.debug('Loaded existing device ID: $id', name: _tag);
    }

    final platform = _detectPlatform();
    final name = await _resolveDeviceName();

    _instance = DeviceIdentity._(
      deviceId: id,
      deviceName: name,
      platform: platform,
    );

    LoggerService.info(
      'DeviceIdentity initialized — name: $name, platform: ${platform.name}',
      name: _tag,
    );

    return _instance!;
  }

  /// Resets the singleton. Intended for testing only.
  @visibleForTesting
  static void reset() => _instance = null;

  static DevicePlatform _detectPlatform() {
    if (kIsWeb) return DevicePlatform.web;
    if (Platform.isIOS) return DevicePlatform.ios;
    if (Platform.isAndroid) return DevicePlatform.android;
    if (Platform.isMacOS) return DevicePlatform.macos;
    if (Platform.isWindows) return DevicePlatform.windows;
    return DevicePlatform.web;
  }

  static Future<String> _resolveDeviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (kIsWeb) {
        final web = await info.webBrowserInfo;
        return web.browserName.name;
      }
      if (Platform.isIOS) {
        final ios = await info.iosInfo;
        return ios.name;
      }
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        return android.model;
      }
      if (Platform.isMacOS) {
        final mac = await info.macOsInfo;
        return mac.computerName;
      }
      if (Platform.isWindows) {
        final win = await info.windowsInfo;
        return win.computerName;
      }
    } catch (e, st) {
      LoggerService.warning(
        'Failed to read device info, using fallback name',
        name: _tag,
      );
      LoggerService.debug('$e\n$st', name: _tag);
    }
    return 'Unknown Device';
  }

  @override
  String toString() =>
      'DeviceIdentity(id: $deviceId, name: $deviceName, platform: ${platform.name})';
}

/// Supported device platforms for sync identification.
enum DevicePlatform { ios, android, macos, windows, web }
