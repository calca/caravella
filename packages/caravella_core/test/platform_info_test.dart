import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// PlatformInfo answers like dart:io's Platform on native builds (tests run
/// on the host's OS, not on Flutter's default "android" target), and never
/// touches dart:io on the web.
void main() {
  test('matches the real operating system on native', () {
    expect(PlatformInfo.isWeb, isFalse);
    expect(PlatformInfo.isAndroid, Platform.isAndroid);
    expect(PlatformInfo.isMacOS, Platform.isMacOS);
    expect(PlatformInfo.isLinux, Platform.isLinux);
    expect(PlatformInfo.isWindows, Platform.isWindows);
    expect(PlatformInfo.isIOS, Platform.isIOS);
  });

  test('capabilities off the web', () {
    expect(PlatformInfo.supportsLanSync, isTrue);
    expect(PlatformInfo.hasFileSystem, isTrue);
    expect(PlatformInfo.supportsAndroidIntegrations, Platform.isAndroid);
  });
}
