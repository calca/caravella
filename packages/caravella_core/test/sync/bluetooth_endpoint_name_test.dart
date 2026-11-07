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
}
