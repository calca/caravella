import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// [PositionProvider] backed by the platform `LocationManager` (no Google
/// Play Services), through the app's `io.caravella.egm/location` channel
/// (`LocationChannel.kt`). Used when the build has no Google integrations
/// (F-Droid); Play builds get Google's fused provider from `caravella_gms`.
class LocationManagerPositionProvider implements PositionProvider {
  static const MethodChannel _channel = MethodChannel(
    'io.caravella.egm/location',
  );

  @override
  Future<bool> isLocationServiceEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isLocationEnabled') ?? false;
    } on PlatformException catch (e) {
      LoggerService.warning('LocationManager unavailable: $e', name: 'location');
      return false;
    }
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      _toStatus(await Permission.locationWhenInUse.status);

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      _toStatus(await Permission.locationWhenInUse.request());

  @override
  Future<LocationPosition?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    if (!Platform.isAndroid) return null;
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'getCurrentPosition',
        {
          'fine': accuracy.index >= LocationAccuracy.medium.index,
          'timeoutMs': timeLimit.inMilliseconds,
        },
      );
      if (result == null) return null;
      return LocationPosition(
        latitude: (result['latitude'] as num).toDouble(),
        longitude: (result['longitude'] as num).toDouble(),
        altitude: (result['altitude'] as num?)?.toDouble(),
        accuracy: (result['accuracy'] as num?)?.toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          (result['timestamp'] as num).toInt(),
        ),
      );
    } on PlatformException catch (e) {
      LoggerService.warning(
        'LocationManager position failed: $e',
        name: 'location',
      );
      return null;
    }
  }

  LocationPermissionStatus _toStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return LocationPermissionStatus.whileInUse;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return LocationPermissionStatus.deniedForever;
    }
    return LocationPermissionStatus.denied;
  }
}
