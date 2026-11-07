import 'package:caravella_core/caravella_core.dart';

/// Gates Bluetooth (Nearby Connections) sync on the `ENABLE_BLUETOOTH_SYNC`
/// build flag.
///
/// Unlike `ENABLE_GOOGLE_DRIVE_SYNC`/`ENABLE_PLAY_UPDATES`, this defaults to
/// **`true`** — Bluetooth sync already ships and is reachable in normal
/// (Play Store) builds, so flipping the default to `false` would silently
/// remove a working feature from every build that doesn't explicitly pass
/// the flag. F-Droid-style builds that want to exclude the Google Play
/// Services dependency `nearby_connections` pulls in (Nearby Connections
/// API) should pass `--dart-define=ENABLE_BLUETOOTH_SYNC=false` explicitly
/// — see docs/FDROID_SUBMISSION.md.
///
/// The transport itself (Google Nearby Connections) comes from
/// `caravella_gms` ([GmsIntegrations.createBluetoothChannel]); the F-Droid
/// build doesn't include it at all, so [isEnabled] is also false there
/// regardless of the flag.
class BluetoothSyncFactory {
  static bool get isEnabled =>
      const bool.fromEnvironment('ENABLE_BLUETOOTH_SYNC', defaultValue: true) &&
      GmsIntegrations.instance.supportsBluetoothSync;

  /// A new channel for one invite or join session, wired to
  /// [orchestrator]; `null` when Bluetooth sync isn't available in this
  /// build. There is no on/off preference: Bluetooth only runs while the
  /// Invite sheet or the Join page is open.
  static BluetoothSyncChannel? createChannel(SyncOrchestrator orchestrator) {
    if (!isEnabled) return null;
    return GmsIntegrations.instance.createBluetoothChannel()
      ?..onDelta = orchestrator.handleIncomingDelta
      ..onPairingRequest = (deviceId, deviceName, platform, groupId) =>
          orchestrator.handlePairingCompleted(
            deviceId,
            deviceName,
            platform,
            groupId,
            channel: 'bluetooth',
          );
  }
}
