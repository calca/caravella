import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:caravella_core/caravella_core.dart';

/// Platform implementation of LocationServiceAbstraction using geolocator and geocoding packages
class LocationServiceImpl implements LocationServiceAbstraction {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await geo.Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final permission = await geo.Geolocator.checkPermission();
    return _toLocationPermissionStatus(permission);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final permission = await geo.Geolocator.requestPermission();
    return _toLocationPermissionStatus(permission);
  }

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

  @override
  Future<GeocodedPlacemark?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      final p = placemarks.first;

      return GeocodedPlacemark(
        street: p.thoroughfare,
        streetNumber: p.subThoroughfare,
        locality: p.locality,
        subLocality: p.subLocality,
        administrativeArea: p.administrativeArea,
        subAdministrativeArea: p.subAdministrativeArea,
        postalCode: p.postalCode,
        country: p.country,
        isoCountryCode: p.isoCountryCode,
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
