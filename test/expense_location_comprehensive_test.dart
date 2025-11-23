import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  group('ExpenseLocation comprehensive fields test', () {
    test('All Placemark fields are serialized and deserialized correctly', () {
      final location = ExpenseLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        address: '123 Main St, New York, NY 10001, USA',
        name: 'Empire State Building',
        street: 'Main St',
        streetNumber: '123',
        locality: 'New York',
        subLocality: 'Manhattan',
        administrativeArea: 'NY',
        subAdministrativeArea: 'New York County',
        postalCode: '10001',
        country: 'United States',
        isoCountryCode: 'US',
      );

      // Test toJson
      final json = location.toJson();
      expect(json['latitude'], 40.7128);
      expect(json['longitude'], -74.0060);
      expect(json['address'], '123 Main St, New York, NY 10001, USA');
      expect(json['name'], 'Empire State Building');
      expect(json['street'], 'Main St');
      expect(json['streetNumber'], '123');
      expect(json['locality'], 'New York');
      expect(json['subLocality'], 'Manhattan');
      expect(json['administrativeArea'], 'NY');
      expect(json['subAdministrativeArea'], 'New York County');
      expect(json['postalCode'], '10001');
      expect(json['country'], 'United States');
      expect(json['isoCountryCode'], 'US');

      // Test fromJson
      final deserialized = ExpenseLocation.fromJson(json);
      expect(deserialized.latitude, 40.7128);
      expect(deserialized.longitude, -74.0060);
      expect(deserialized.address, '123 Main St, New York, NY 10001, USA');
      expect(deserialized.name, 'Empire State Building');
      expect(deserialized.street, 'Main St');
      expect(deserialized.streetNumber, '123');
      expect(deserialized.locality, 'New York');
      expect(deserialized.subLocality, 'Manhattan');
      expect(deserialized.administrativeArea, 'NY');
      expect(deserialized.subAdministrativeArea, 'New York County');
      expect(deserialized.postalCode, '10001');
      expect(deserialized.country, 'United States');
      expect(deserialized.isoCountryCode, 'US');
    });

    test('Optional fields are handled correctly', () {
      final location = ExpenseLocation(latitude: 40.7128, longitude: -74.0060);

      final json = location.toJson();
      expect(json.containsKey('address'), false);
      expect(json.containsKey('name'), false);
      expect(json.containsKey('street'), false);
      expect(json.containsKey('streetNumber'), false);
      expect(json.containsKey('locality'), false);
      expect(json.containsKey('subLocality'), false);
      expect(json.containsKey('administrativeArea'), false);
      expect(json.containsKey('subAdministrativeArea'), false);
      expect(json.containsKey('postalCode'), false);
      expect(json.containsKey('country'), false);
      expect(json.containsKey('isoCountryCode'), false);

      final deserialized = ExpenseLocation.fromJson(json);
      expect(deserialized.latitude, 40.7128);
      expect(deserialized.longitude, -74.0060);
      expect(deserialized.address, null);
      expect(deserialized.name, null);
      expect(deserialized.street, null);
      expect(deserialized.streetNumber, null);
      expect(deserialized.locality, null);
      expect(deserialized.subLocality, null);
      expect(deserialized.administrativeArea, null);
      expect(deserialized.subAdministrativeArea, null);
      expect(deserialized.postalCode, null);
      expect(deserialized.country, null);
      expect(deserialized.isoCountryCode, null);
    });

    test('copyWith preserves all fields correctly', () {
      final original = ExpenseLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        address: '123 Main St, New York, NY 10001, USA',
        name: 'Empire State Building',
        street: 'Main St',
        streetNumber: '123',
        locality: 'New York',
        subLocality: 'Manhattan',
        administrativeArea: 'NY',
        subAdministrativeArea: 'New York County',
        postalCode: '10001',
        country: 'United States',
        isoCountryCode: 'US',
      );

      final copy = original.copyWith(locality: 'Brooklyn');
      expect(copy.latitude, 40.7128);
      expect(copy.longitude, -74.0060);
      expect(copy.address, '123 Main St, New York, NY 10001, USA');
      expect(copy.name, 'Empire State Building');
      expect(copy.street, 'Main St');
      expect(copy.streetNumber, '123');
      expect(copy.locality, 'Brooklyn'); // Changed
      expect(copy.subLocality, 'Manhattan');
      expect(copy.administrativeArea, 'NY');
      expect(copy.subAdministrativeArea, 'New York County');
      expect(copy.postalCode, '10001');
      expect(copy.country, 'United States');
      expect(copy.isoCountryCode, 'US');
    });

    test('equality operator includes all fields', () {
      final location1 = ExpenseLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        address: '123 Main St, New York, NY 10001, USA',
        street: 'Main St',
        streetNumber: '123',
        locality: 'New York',
        country: 'United States',
      );

      final location2 = ExpenseLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        address: '123 Main St, New York, NY 10001, USA',
        street: 'Main St',
        streetNumber: '123',
        locality: 'New York',
        country: 'United States',
      );

      final location3 = ExpenseLocation(
        latitude: 40.7128,
        longitude: -74.0060,
        address: '123 Main St, New York, NY 10001, USA',
        street: 'Main St',
        streetNumber: '123',
        locality: 'Brooklyn', // Different
        country: 'United States',
      );

      expect(location1, location2);
      expect(location1 == location3, false);
      expect(location1.hashCode, location2.hashCode);
    });
  });
}
