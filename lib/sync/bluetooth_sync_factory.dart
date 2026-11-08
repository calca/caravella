import 'package:caravella_core/caravella_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _prefKey = 'sync_bluetooth_enabled';

  static bool get isEnabled =>
      const bool.fromEnvironment('ENABLE_BLUETOOTH_SYNC', defaultValue: true) &&
      GmsIntegrations.instance.supportsBluetoothSync;

  /// A new channel for one invite or join session, wired to
  /// [orchestrator]; `null` when Bluetooth sync isn't available in this
  /// build. Creating it turns nothing on: Bluetooth only runs while the
  /// Invite sheet or the Join page is open, and only once the user has
  /// turned it on ([isUserEnabled]).
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

  /// Whether the user allows Bluetooth sync: the privacy switch in
  /// Settings › Synchronization › Sync with others, also offered as "Turn
  /// on" in the Invite sheet and on the Join page. Off by default.
  static Future<bool> isUserEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> setUserEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
    LoggerService.info(
      'Bluetooth sync ${enabled ? 'enabled' : 'disabled'} by user',
      name: 'settings',
    );
  }
}
