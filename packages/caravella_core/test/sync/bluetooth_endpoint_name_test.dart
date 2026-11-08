import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('carries the group title after the device name', () {
    final raw = BluetoothEndpointName.encode('Pixel 9', 'Lisbon');
    final d = BluetoothEndpointName.decode(raw);
    expect(d.deviceName, 'Pixel 9');
    expect(d.groupTitle, 'Lisbon');
  });

  test('an older version advertising only its name decodes too', () {
    final d = BluetoothEndpointName.decode('Pixel 9');
    expect(d.deviceName, 'Pixel 9');
    expect(d.groupTitle, isNull);
  });

  test('a long title is cut, and newlines cannot split the name', () {
    final raw = BluetoothEndpointName.encode('My\nPhone', 'x' * 100);
    final d = BluetoothEndpointName.decode(raw);
    expect(d.deviceName, 'My Phone');
    expect(d.groupTitle!.length, BluetoothEndpointName.maxGroupTitleLength);
    expect(d.groupTitle!.endsWith('…'), isTrue);
  });

  test('no title: just the device name', () {
    expect(BluetoothEndpointName.encode('Pixel 9', '  '), 'Pixel 9');
  });

  group('update advertisement', () {
    test('carries the device ID and no group', () {
      final raw = BluetoothEndpointName.encodeUpdate('Pixel 9', 'dev-123');
      final d = BluetoothEndpointName.decode(raw);
      expect(d.deviceName, 'Pixel 9');
      expect(d.updateDeviceId, 'dev-123');
      expect(d.groupTitle, isNull);
    });

    test('a long device name is cut but the ID survives', () {
      final raw = BluetoothEndpointName.encodeUpdate('x' * 100, 'dev-123');
      final d = BluetoothEndpointName.decode(raw);
      expect(d.deviceName.length, BluetoothEndpointName.maxUpdateNameLength);
      expect(d.updateDeviceId, 'dev-123');
    });

    test('an invitation and an older name carry no update ID', () {
      expect(
        BluetoothEndpointName.decode(
          BluetoothEndpointName.encode('Pixel 9', 'Lisbon'),
        ).updateDeviceId,
        isNull,
      );
      expect(BluetoothEndpointName.decode('Pixel 9').updateDeviceId, isNull);
    });

    test('a group title that looks like the marker is not an update', () {
      final d = BluetoothEndpointName.decode('Pixel 9\nupd:abc');
      expect(d.updateDeviceId, isNull);
      expect(d.groupTitle, 'upd:abc');
    });

    test('an empty ID is not an update', () {
      final d = BluetoothEndpointName.decode('Pixel 9\n\nupd:');
      expect(d.updateDeviceId, isNull);
    });
  });

  group('who initiates an update', () {
    test('the smaller device ID requests the connection', () {
      expect(BluetoothUpdate.initiates('a-1', 'b-1'), isTrue);
      expect(BluetoothUpdate.initiates('b-1', 'a-1'), isFalse);
    });

    test('exactly one side initiates, and nobody on equal IDs', () {
      for (final (a, b) in [('x', 'y'), ('abc', 'abd'), ('Z', 'a')]) {
        expect(
          BluetoothUpdate.initiates(a, b) != BluetoothUpdate.initiates(b, a),
          isTrue,
        );
      }
      expect(BluetoothUpdate.initiates('same', 'same'), isFalse);
    });
  });

  test('counts the groups and deletions of a delta', () {
    expect(
      BluetoothUpdate.countChanges({
        'groups': [{}, {}],
        'deleted_groups': [{}],
      }),
      3,
    );
    expect(BluetoothUpdate.countChanges({}), 0);
  });
}
