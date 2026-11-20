import 'package:flutter/foundation.dart';

import 'platform_os_io.dart'
    if (dart.library.js_interop) 'platform_os_web.dart';

/// Where the app runs and what it can do there, in one place.
///
/// The rest of the code asks this instead of `dart:io`'s `Platform`, which
/// doesn't exist on the web (any call throws). `dart:io` is only touched in
/// `platform_os_io.dart`, picked by a conditional import. Prefer the
/// capabilities (`supportsLanSync`…) to the OS checks: the app asks what it
/// can do, not which system it is on.
abstract final class PlatformInfo {
  static final String _os = hostOperatingSystem();

  /// Running in a browser.
  static bool get isWeb => kIsWeb;

  static bool get isAndroid => _os == 'android';
  static bool get isIOS => _os == 'ios';
  static bool get isMacOS => _os == 'macos';
  static bool get isWindows => _os == 'windows';
  static bool get isLinux => _os == 'linux';

  /// A phone or tablet OS (not the web, not a desktop).
  static bool get isMobile => isAndroid || isIOS;

  /// Sync over the local network (sockets and mDNS): not in a browser.
  static bool get supportsLanSync => !kIsWeb;

  /// Android-only integrations: home-screen widgets, app shortcuts, App
  /// Functions, Play in-app updates.
  static bool get supportsAndroidIntegrations => isAndroid;

  /// Files on a real file system (`dart:io`); the web keeps its data in the
  /// browser instead.
  static bool get hasFileSystem => !kIsWeb;
}
