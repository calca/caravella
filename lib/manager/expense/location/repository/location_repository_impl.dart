import 'package:caravella_core/caravella_core.dart';
import 'location_repository.dart';
import '../../services/location_service_impl.dart';
import '../nominatim_search_service.dart';
import '../nominatim_place.dart';

/// Default implementation of LocationRepository
///
/// Coordinates between platform location services and Nominatim search.
class LocationRepositoryImpl implements LocationRepository {
  final LocationServiceAbstraction _locationService;

  LocationRepositoryImpl({LocationServiceAbstraction? locationService})
    : _locationService = locationService ?? LocationServiceImpl();

  @override
  Future<ExpenseLocation?> getCurrentLocation({
    bool resolveAddress = true,
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check and request permission
      LocationPermissionStatus permission = await _locationService
          .checkPermission();
      if (permission == LocationPermissionStatus.denied) {
        permission = await _locationService.requestPermission();
        if (permission == LocationPermissionStatus.denied) {
          return null;
        }
      }

      if (permission == LocationPermissionStatus.deniedForever) {
        return null;
      }

      // Get current position
      final position = await _locationService.getCurrentPosition(
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (position == null) {
        return null;
      }

      String? address;
      String? street;
      String? streetNumber;
      String? locality;
      String? subLocality;
      String? administrativeArea;
      String? subAdministrativeArea;
      String? postalCode;
      String? country;
      String? isoCountryCode;

      // Reverse geocode if requested
      if (resolveAddress) {
        final placemark = await _locationService.reverseGeocode(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        if (placemark != null) {
          street = placemark.street;
          streetNumber = placemark.streetNumber;
          locality = placemark.locality;
          subLocality = placemark.subLocality;
          administrativeArea = placemark.administrativeArea;
          subAdministrativeArea = placemark.subAdministrativeArea;
          postalCode = placemark.postalCode;
          country = placemark.country;
          isoCountryCode = placemark.isoCountryCode;
          address = placemark.formattedAddress;
        }
      }

      return ExpenseLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        street: street,
        streetNumber: streetNumber,
        locality: locality,
        subLocality: subLocality,
        administrativeArea: administrativeArea,
        subAdministrativeArea: subAdministrativeArea,
        postalCode: postalCode,
        country: country,
        isoCountryCode: isoCountryCode,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final placemark = await _locationService.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );
      return placemark?.formattedAddress;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<NominatimPlace>> searchPlaces(String query) async {
    try {
      return await NominatimSearchService.searchPlaces(query);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await _locationService.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    return await _locationService.checkPermission();
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    return await _locationService.requestPermission();
  }
}
