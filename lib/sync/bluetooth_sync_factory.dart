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
/// As with the other conditional packages, this only gates *reachability*
/// (the Bluetooth section is hidden from Settings → Sync when disabled) —
/// `nearby_connections` remains a normal, always-present pubspec
/// dependency; see docs/BUILD_VARIANTS.md for why that's an accepted
/// pattern in this codebase already.
class BluetoothSyncFactory {
  static const _prefKey = 'sync_bluetooth_enabled';

  static bool get isEnabled =>
      const bool.fromEnvironment('ENABLE_BLUETOOTH_SYNC', defaultValue: true);

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
