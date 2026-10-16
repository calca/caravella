import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:caravella_core/caravella_core.dart';

import 'location_manager_position_provider.dart';

/// Platform implementation of LocationServiceAbstraction: the position comes
/// from Google's fused provider when the build has it
/// ([GmsIntegrations.createPositionProvider]), otherwise from the platform
/// `LocationManager`; reverse geocoding uses the `geocoding` package.
class LocationServiceImpl implements LocationServiceAbstraction {
  final geocoding.Geocoding _geocoding = geocoding.Geocoding();
  final PositionProvider _positionProvider;

  LocationServiceImpl({PositionProvider? positionProvider})
    : _positionProvider =
          positionProvider ??
          GmsIntegrations.instance.createPositionProvider() ??
          LocationManagerPositionProvider();

  @override
  Future<bool> isLocationServiceEnabled() =>
      _positionProvider.isLocationServiceEnabled();

  @override
  Future<LocationPermissionStatus> checkPermission() =>
      _positionProvider.checkPermission();

  @override
  Future<LocationPermissionStatus> requestPermission() =>
      _positionProvider.requestPermission();

  @override
  Future<LocationPosition?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
  }) => _positionProvider.getCurrentPosition(
    accuracy: accuracy,
    timeLimit: timeLimit,
  );

  @override
  Future<GeocodedPlacemark?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
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
}
