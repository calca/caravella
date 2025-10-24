import 'dart:developer' as developer;

/// Service level for logging
enum LogLevel { debug, info, warning, error }

/// Centralized logging service for the Caravella app
/// Replaces print statements with structured logging
class LoggerService {
  /// Base logging method
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final logName = name ?? 'caravella';

    switch (level) {
      case LogLevel.debug:
        developer.log(message, name: '$logName.debug');
        break;
      case LogLevel.info:
        developer.log(message, name: '$logName.info');
        break;
      case LogLevel.warning:
        developer.log(message, name: '$logName.warning');
        break;
      case LogLevel.error:
        developer.log(
          message,
          name: '$logName.error',
          error: error,
          stackTrace: stackTrace,
        );
        break;
    }
  }

  /// Log debug messages (development only)
  static void debug(String message, {String? name}) {
    log(message, level: LogLevel.debug, name: name);
  }

  /// Log informational messages
  static void info(String message, {String? name}) {
    log(message, level: LogLevel.info, name: name);
  }

  /// Log warning messages
  static void warning(String message, {String? name}) {
    log(message, level: LogLevel.warning, name: name);
  }

  /// Log error messages with optional error object and stack trace
  static void error(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      level: LogLevel.error,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
