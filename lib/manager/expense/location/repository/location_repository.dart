import 'package:caravella_core/caravella_core.dart';
import '../nominatim_place.dart';

/// Repository abstraction for location operations
///
/// Provides a centralized interface for location-related operations,
/// coordinating between LocationServiceAbstraction and NominatimSearchService.
/// This eliminates circular dependencies and improves testability.
abstract class LocationRepository {
  /// Gets the current device location with optional address resolution
  Future<ExpenseLocation?> getCurrentLocation({bool resolveAddress = true});

  /// Performs reverse geocoding to get address from coordinates
  Future<String?> reverseGeocode(double latitude, double longitude);

  /// Searches for places matching the query using Nominatim
  Future<List<NominatimPlace>> searchPlaces(String query);

  /// Checks if location services are enabled
  Future<bool> isLocationServiceEnabled();

  /// Checks current location permission status
  Future<LocationPermissionStatus> checkPermission();

  /// Requests location permission
  Future<LocationPermissionStatus> requestPermission();
}
