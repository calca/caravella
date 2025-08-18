enum Environment { dev, staging, prod }

class AppConfig {
  static Environment? _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment ?? Environment.prod;

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
