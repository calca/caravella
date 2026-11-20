import 'dart:io';

/// Native: the real operating system (`dart:io`), the same answers the app
/// got before PlatformInfo (also in tests, which run on the host's OS).
String hostOperatingSystem() => Platform.operatingSystem;
