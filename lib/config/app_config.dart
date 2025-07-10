enum Environment { dev, staging, prod }

class AppConfig {
  static Environment _environment = Environment.prod;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  static String get appName {
    switch (_environment) {
      case Environment.dev:
        return 'Caravella Dev';
      case Environment.staging:
        return 'Caravella Staging';
      case Environment.prod:
        return 'Caravella';
    }
  }

  static String get packageSuffix {
    switch (_environment) {
      case Environment.dev:
        return '.dev';
      case Environment.staging:
        return '.staging';
      case Environment.prod:
        return '';
    }
  }

  static bool get isDebug => _environment != Environment.prod;

  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://api-dev.caravella.app';
      case Environment.staging:
        return 'https://api-staging.caravella.app';
      case Environment.prod:
        return 'https://api.caravella.app';
    }
  }
}
