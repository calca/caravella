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
  static bool get isEnabled =>
      const bool.fromEnvironment('ENABLE_BLUETOOTH_SYNC', defaultValue: true);
}
