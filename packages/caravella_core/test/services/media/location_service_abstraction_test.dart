import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

/// Mock implementation for testing
class MockLocationServiceAbstraction implements LocationServiceAbstraction {
  bool serviceEnabled = true;
  LocationPermissionStatus permissionStatus =
      LocationPermissionStatus.whileInUse;
  LocationPosition? mockPosition;
  GeocodedPlacemark? mockPlacemark;
  bool shouldFailGetPosition = false;
  bool shouldFailGeocode = false;

  @override
  Future<bool> isLocationServiceEnabled() async {
    return serviceEnabled;
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    return permissionStatus;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    if (permissionStatus == LocationPermissionStatus.denied) {
      permissionStatus = LocationPermissionStatus.whileInUse;
    }
    return permissionStatus;
  }

  @override
  Future<LocationPosition?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    if (shouldFailGetPosition) return null;
    return mockPosition;
  }

  @override
  Future<GeocodedPlacemark?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (shouldFailGeocode) return null;
    return mockPlacemark;
  }
}

void main() {
  group('LocationServiceAbstraction', () {
    late MockLocationServiceAbstraction service;

    setUp(() {
      service = MockLocationServiceAbstraction();
      service.mockPosition = LocationPosition(
        latitude: 45.4642,
        longitude: 9.1900,
        altitude: 120.0,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );
      service.mockPlacemark = const GeocodedPlacemark(
        street: 'Via Test',
        streetNumber: '1',
        locality: 'Milano',
        country: 'Italy',
        isoCountryCode: 'IT',
      );
    });

    test('isLocationServiceEnabled returns true when enabled', () async {
      service.serviceEnabled = true;

      final result = await service.isLocationServiceEnabled();

      expect(result, isTrue);
    });

    test('isLocationServiceEnabled returns false when disabled', () async {
      service.serviceEnabled = false;

      final result = await service.isLocationServiceEnabled();

      expect(result, isFalse);
    });

    test('checkPermission returns current status', () async {
      service.permissionStatus = LocationPermissionStatus.denied;

      final result = await service.checkPermission();

      expect(result, LocationPermissionStatus.denied);
    });

    test('requestPermission changes status from denied to granted', () async {
      service.permissionStatus = LocationPermissionStatus.denied;

      final result = await service.requestPermission();

      expect(result, LocationPermissionStatus.whileInUse);
    });

    test('getCurrentPosition returns position when successful', () async {
      final result = await service.getCurrentPosition();

      expect(result, isNotNull);
      expect(result!.latitude, 45.4642);
      expect(result.longitude, 9.1900);
    });

    test('getCurrentPosition returns null when failed', () async {
      service.shouldFailGetPosition = true;

      final result = await service.getCurrentPosition();

      expect(result, isNull);
    });

    test('reverseGeocode returns placemark when successful', () async {
      final result = await service.reverseGeocode(
        latitude: 45.4642,
        longitude: 9.1900,
      );

      expect(result, isNotNull);
      expect(result!.locality, 'Milano');
      expect(result.country, 'Italy');
    });

    test('reverseGeocode returns null when failed', () async {
      service.shouldFailGeocode = true;

      final result = await service.reverseGeocode(
        latitude: 45.4642,
        longitude: 9.1900,
      );

      expect(result, isNull);
    });

    test('GeocodedPlacemark formattedAddress builds correct string', () {
      final placemark = GeocodedPlacemark(
        street: 'Via Roma',
        streetNumber: '10',
        locality: 'Milano',
        administrativeArea: 'MI',
        country: 'Italy',
      );

      final address = placemark.formattedAddress;

      expect(address, isNotNull);
      expect(address, contains('Via Roma'));
      expect(address, contains('10'));
      expect(address, contains('Milano'));
    });

    test('GeocodedPlacemark formattedAddress returns null when empty', () {
      const placemark = GeocodedPlacemark();

      final address = placemark.formattedAddress;

      expect(address, isNull);
    });

    test('LocationPosition contains all required fields', () {
      final position = LocationPosition(
        latitude: 45.4642,
        longitude: 9.1900,
        altitude: 120.0,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );

      expect(position.latitude, 45.4642);
      expect(position.longitude, 9.1900);
      expect(position.altitude, 120.0);
      expect(position.accuracy, 10.0);
      expect(position.timestamp, isNotNull);
    });

    test('LocationPermissionStatus enum has all expected values', () {
      expect(
        LocationPermissionStatus.values,
        contains(LocationPermissionStatus.denied),
      );
      expect(
        LocationPermissionStatus.values,
        contains(LocationPermissionStatus.deniedForever),
      );
      expect(
        LocationPermissionStatus.values,
        contains(LocationPermissionStatus.whileInUse),
      );
      expect(
        LocationPermissionStatus.values,
        contains(LocationPermissionStatus.always),
      );
    });

    test('LocationAccuracy enum has all expected values', () {
      expect(LocationAccuracy.values, contains(LocationAccuracy.lowest));
      expect(LocationAccuracy.values, contains(LocationAccuracy.low));
      expect(LocationAccuracy.values, contains(LocationAccuracy.medium));
      expect(LocationAccuracy.values, contains(LocationAccuracy.high));
      expect(LocationAccuracy.values, contains(LocationAccuracy.best));
    });
  });
}
