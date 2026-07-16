import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/sync/bluetooth_sync_factory.dart';

/// `ENABLE_BLUETOOTH_SYNC` is a compile-time `--dart-define`, so it can't be
/// flipped at test runtime — this only covers the default (unset) state.
/// Unlike `GoogleDriveSyncFactory`/`UpdateServiceFactory`, the default here
/// is `true` (see the class doc comment for why) — F-Droid-style builds
/// that want it off must pass the flag explicitly.
void main() {
  test('BluetoothSyncFactory.isEnabled defaults to true', () {
    expect(BluetoothSyncFactory.isEnabled, isTrue);
  });
}
