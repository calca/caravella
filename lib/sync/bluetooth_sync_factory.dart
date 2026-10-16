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

  /// A new channel for one pairing session, wired to [orchestrator]; `null`
  /// when Bluetooth sync isn't available in this build.
  static BluetoothSyncChannel? createChannel(SyncOrchestrator orchestrator) {
    if (!isEnabled) return null;
    return GmsIntegrations.instance.createBluetoothChannel()
      ?..onDelta = orchestrator.handleIncomingDelta
      ..onPairingRequest = orchestrator.handlePairingCompleted;
  }

  /// Whether the user has enabled Bluetooth sync (opt-in preference,
  /// separate from the [isEnabled] build-time flag). Defaults to `false` —
  /// Bluetooth pairing stays hidden in Settings → Sync until turned on.
  static Future<bool> isUserEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Persists the user's Bluetooth sync opt-in/opt-out choice.
  static Future<void> setUserEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
  }
}
