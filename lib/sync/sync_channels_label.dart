import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'bluetooth_sync_factory.dart';
import 'sync_bootstrap.dart';

/// The sync entry's subtitle, naming only the channels this build has: the
/// F-Droid build has neither Bluetooth nor Google Drive, so it says just
/// "Wi-Fi".
String syncChannelsLabel(gen.AppLocalizations gloc) {
  const drive =
      SyncBootstrap.driveSyncAvailable &&
      bool.fromEnvironment('ENABLE_GOOGLE_DRIVE_SYNC');
  final bluetooth = BluetoothSyncFactory.isEnabled;
  return switch ((bluetooth, drive)) {
    (true, true) => gloc.sync_settings_desc,
    (true, false) => gloc.sync_settings_desc_wifi_bt,
    (false, true) => gloc.sync_settings_desc_wifi_drive,
    (false, false) => gloc.sync_settings_desc_wifi,
  };
}
