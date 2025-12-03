/// Service abstraction for location retrieval operations
/// Isolates platform dependencies (geolocator) for better testability
abstract class LocationServiceAbstraction {
  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled();

  /// Check current location permission status
  Future<LocationPermissionStatus> checkPermission();

  /// Request location permission from the user
  Future<LocationPermissionStatus> requestPermission();

  /// Get the current device location
  ///
  /// [accuracy] - Desired accuracy level
  /// [timeLimit] - Maximum time to wait for location (default 10 seconds)
  ///
  /// Returns the current position or null if unavailable
  Future<LocationPosition?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
  });

  /// Reverse geocode coordinates to get address information
  ///
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  ///
  /// Returns geocoded placemark or null if geocoding fails
  Future<GeocodedPlacemark?> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}

/// Permission status for location access
enum LocationPermissionStatus { denied, deniedForever, whileInUse, always }

/// Accuracy level for location requests
enum LocationAccuracy { lowest, low, medium, high, best }

/// Represents a geographic position
class LocationPosition {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final DateTime timestamp;

  const LocationPosition({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    required this.timestamp,
  });
}

/// Represents geocoded address information from coordinates
class GeocodedPlacemark {
  final String? street;
  final String? streetNumber;
  final String? locality;
  final String? subLocality;
  final String? administrativeArea;
  final String? subAdministrativeArea;
  final String? postalCode;
  final String? country;
  final String? isoCountryCode;

  const GeocodedPlacemark({
    this.street,
    this.streetNumber,
    this.locality,
    this.subLocality,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.postalCode,
    this.country,
    this.isoCountryCode,
  });

  /// Build a formatted address from available fields
  String? get formattedAddress {
    final parts = [
      if ((street ?? '').isNotEmpty) street,
      if ((streetNumber ?? '').isNotEmpty) streetNumber,
      if ((locality ?? '').isNotEmpty) locality,
      if ((administrativeArea ?? '').isNotEmpty) administrativeArea,
      if ((country ?? '').isNotEmpty) country,
    ].whereType<String>().where((e) => e.trim().isNotEmpty).toList();

    return parts.isNotEmpty ? parts.join(', ') : null;
  }
}
