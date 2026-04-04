import 'dart:developer' as developer;
import 'package:talker_flutter/talker_flutter.dart';

/// Service level for logging
enum LogLevel { debug, info, warning, error }

/// Centralized logging service for the Caravella app
/// Replaces print statements with structured logging
/// Backend powered by Talker for history and UI support
class LoggerService {
  static Talker? _talker;

  /// Initialize LoggerService with Talker backend
  /// Should be called once in main.dart before app initialization
  static void initialize({
    bool useHistory = true,
    int maxHistoryItems = 1000,
    LogLevel minLevel = LogLevel.debug,
  }) {
    _talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: true,
        useHistory: useHistory,
        maxHistoryItems: maxHistoryItems,
      ),
      logger: TalkerLogger(
        settings: TalkerLoggerSettings(
          enableColors: false, // Disable for production
        ),
      ),
    );
  }

  /// Get the Talker instance for direct access (e.g., TalkerScreen)
  static Talker get instance {
    if (_talker == null) {
      // Lazy initialization with defaults if not explicitly initialized
      initialize();
    }
    return _talker!;
  }

  /// Base logging method
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final logName = name ?? 'caravella';

    // Use Talker if initialized, fallback to dart:developer
    if (_talker != null) {
      final fullMessage = name != null ? '[$name] $message' : message;

      switch (level) {
        case LogLevel.debug:
          _talker!.debug(fullMessage);
          break;
        case LogLevel.info:
          _talker!.info(fullMessage);
          break;
        case LogLevel.warning:
          _talker!.warning(fullMessage);
          break;
        case LogLevel.error:
          if (error != null) {
            _talker!.error(fullMessage, error, stackTrace);
          } else {
            _talker!.error(fullMessage);
          }
          break;
      }
    } else {
      // Fallback to dart:developer if not initialized
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
