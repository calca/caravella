import 'package:caravella_core/caravella_core.dart';
import 'package:geolocator/geolocator.dart' as geo;

/// [PositionProvider] backed by `geolocator` (Google's fused location
/// provider on Android).
class GeolocatorPositionProvider implements PositionProvider {
  @override
  Future<bool> isLocationServiceEnabled() =>
      geo.Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      _toLocationPermissionStatus(await geo.Geolocator.checkPermission());

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      _toLocationPermissionStatus(await geo.Geolocator.requestPermission());

  @override
  Future<LocationPosition?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: geo.LocationSettings(
          accuracy: _toGeolocatorAccuracy(accuracy),
          timeLimit: timeLimit,
        ),
      );

      return LocationPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e) {
      return null;
    }
  }

  LocationPermissionStatus _toLocationPermissionStatus(
    geo.LocationPermission permission,
  ) {
    switch (permission) {
      case geo.LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case geo.LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case geo.LocationPermission.whileInUse:
        return LocationPermissionStatus.whileInUse;
      case geo.LocationPermission.always:
        return LocationPermissionStatus.always;
      case geo.LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }

  geo.LocationAccuracy _toGeolocatorAccuracy(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return geo.LocationAccuracy.lowest;
      case LocationAccuracy.low:
        return geo.LocationAccuracy.low;
      case LocationAccuracy.medium:
        return geo.LocationAccuracy.medium;
      case LocationAccuracy.high:
        return geo.LocationAccuracy.high;
      case LocationAccuracy.best:
        return geo.LocationAccuracy.best;
    }
  }
}
