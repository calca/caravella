enum Environment { dev, staging, prod }

class AppConfig {
  static Environment? _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment ?? Environment.prod;

  /// Enable TalkerScreen UI in settings via build flag
  /// Usage: --dart-define=ENABLE_TALKER_SCREEN=true
  static const bool enableTalkerScreen = bool.fromEnvironment(
    'ENABLE_TALKER_SCREEN',
    defaultValue: false,
  );

  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'prod',
  );

  /// Enable Android home widget via build flag
  /// Usage: --dart-define=ENABLE_ANDROID_WIDGET=false (to disable)
  /// Default mirrors the native per-flavor Gradle default in
  /// android/app/build.gradle.kts: enabled for dev/staging, disabled for prod,
  /// so a build without an explicit override stays consistent on both sides.
  static const bool enableAndroidWidget = bool.fromEnvironment(
    'ENABLE_ANDROID_WIDGET',
    defaultValue: _flavor != 'prod',
  );

  static String get appName {
    switch (environment) {
      case Environment.dev:
        return 'Caravella - Dev';
      case Environment.staging:
        return 'Caravella - Staging';
      case Environment.prod:
        return 'Caravella';
    }
  }

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'https://api.dev.caravella.app';
      case Environment.staging:
        return 'https://api.staging.caravella.app';
      case Environment.prod:
        return 'https://api.caravella.app';
    }
  }

  static bool get showDebugBanner => environment != Environment.prod;
}
