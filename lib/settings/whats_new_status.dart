import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Whether there's news the user hasn't opened, after an update to a new
/// release (2.5, 2.6: patches bring nothing to announce).
///
/// Home calls [check] once its data is in: the first time on a new release
/// it answers the release to announce (Home shows a toast with "What's
/// new"), and [unread] stays true, a dot on the settings button and on
/// Settings › Info › What's new, until [markSeen] (opening What's new).
/// A fresh install has nothing new: its first release counts as seen.
abstract final class WhatsNewStatus {
  /// News not opened yet.
  static final ValueNotifier<bool> unread = ValueNotifier(false);

  /// "2.5.1" → "2.5".
  static String releaseOf(String version) {
    final parts = version.split('+').first.split('.');
    return parts.length >= 2 ? '${parts[0]}.${parts[1]}' : version;
  }

  static Future<String> _currentRelease() async =>
      releaseOf((await PackageInfo.fromPlatform()).version);

  /// The release to announce now, or null. [hasData]: the user already has
  /// groups (an update), not a fresh install. [version] is for tests.
  static Future<String?> check({required bool hasData, String? version}) async {
    final String release;
    try {
      release = version != null ? releaseOf(version) : await _currentRelease();
    } catch (e) {
      LoggerService.warning('No app version: $e', name: 'settings');
      return null;
    }
    if (release.isEmpty) return null;
    final prefs = PreferencesService.instance.whatsNew;
    if (prefs.seen() == null && prefs.announced() == null && !hasData) {
      // A fresh install: this release's news is the app itself.
      await prefs.setSeen(release);
      await prefs.setAnnounced(release);
      unread.value = false;
      return null;
    }
    unread.value = prefs.seen() != release;
    if (!unread.value || prefs.announced() == release) return null;
    await prefs.setAnnounced(release);
    LoggerService.info('Announcing what\'s new in $release', name: 'settings');
    return release;
  }

  /// What's new was opened: no more dot until the next release.
  static Future<void> markSeen({String? version}) async {
    unread.value = false;
    try {
      final release = version != null
          ? releaseOf(version)
          : await _currentRelease();
      if (release.isEmpty) return;
      final prefs = PreferencesService.instance.whatsNew;
      await prefs.setSeen(release);
      await prefs.setAnnounced(release);
    } catch (e) {
      LoggerService.warning('No app version: $e', name: 'settings');
    }
  }
}
