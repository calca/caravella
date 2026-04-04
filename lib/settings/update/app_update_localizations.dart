import 'package:play_store_updates/play_store_updates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Adapter that implements UpdateLocalizations using the app's localizations.
class AppUpdateLocalizations implements UpdateLocalizations {
  final gen.AppLocalizations _loc;

  AppUpdateLocalizations(this._loc);

  @override
  String get updateAvailable => _loc.update_available;

  @override
  String get updateAvailableDesc => _loc.update_available_desc;

  @override
  String get updateLater => _loc.update_later;

  @override
  String get updateNow => _loc.update_now;

  @override
  String get updateDownloading => _loc.update_downloading;

  @override
  String get updateInstalling => _loc.update_installing;

  @override
  String get updateError => _loc.update_error;

  @override
  String get checkForUpdates => _loc.check_for_updates;

  @override
  String get checkForUpdatesDesc => _loc.check_for_updates_desc;

  @override
  String get checkingForUpdates => _loc.checking_for_updates;

  @override
  String get noUpdateAvailable => _loc.no_update_available;
}
