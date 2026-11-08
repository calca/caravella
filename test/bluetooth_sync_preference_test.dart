import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/sync/bluetooth_sync_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Bluetooth sync is off until the user turns it on', () async {
    expect(await BluetoothSyncFactory.isUserEnabled(), isFalse);

    await BluetoothSyncFactory.setUserEnabled(true);
    expect(await BluetoothSyncFactory.isUserEnabled(), isTrue);

    await BluetoothSyncFactory.setUserEnabled(false);
    expect(await BluetoothSyncFactory.isUserEnabled(), isFalse);
  });

  test('keeps the choice made before 2.4 (same preference key)', () async {
    SharedPreferences.setMockInitialValues({'sync_bluetooth_enabled': true});
    expect(await BluetoothSyncFactory.isUserEnabled(), isTrue);
  });
}
