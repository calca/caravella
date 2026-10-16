import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/sync/bluetooth_sync_factory.dart';

/// Integrations that claim Bluetooth support (the Play build), without
/// touching any platform transport.
class _BluetoothCapableIntegrations extends NoGmsIntegrations {
  const _BluetoothCapableIntegrations();

  @override
  bool get isAvailable => true;

  @override
  bool get supportsBluetoothSync => true;
}

/// `ENABLE_BLUETOOTH_SYNC` is a compile-time `--dart-define`, so it can't be
/// flipped at test runtime — this only covers the default (unset) state.
/// Unlike `ENABLE_GOOGLE_DRIVE_SYNC`/`ENABLE_PLAY_UPDATES`, the default here
/// is `true` (see the class doc comment for why); the F-Droid build has no
/// Bluetooth transport at all, so it is off there regardless of the flag.
void main() {
  tearDown(() => GmsIntegrations.instance = const NoGmsIntegrations());

  test('isEnabled defaults to true when the build has Bluetooth support', () {
    GmsIntegrations.instance = const _BluetoothCapableIntegrations();
    expect(BluetoothSyncFactory.isEnabled, isTrue);
  });

  test('isEnabled is false without Google integrations (F-Droid build)', () {
    GmsIntegrations.instance = const NoGmsIntegrations();
    expect(BluetoothSyncFactory.isEnabled, isFalse);
  });
}
