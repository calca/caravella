/// Adapter for logging functionality.
/// 
/// This allows the package to be independent from the main app's logger.
/// The main app can configure this adapter to use its own logging system.
class LoggerAdapter {
  static void Function(String message)? _infoCallback;
  static void Function(String message)? _warningCallback;
  
  /// Configure the logger callbacks.
  static void configure({
    void Function(String message)? onInfo,
    void Function(String message)? onWarning,
  }) {
    _infoCallback = onInfo;
    _warningCallback = onWarning;
  }
  
  /// Log an info message.
  static void info(String message) {
    _infoCallback?.call(message);
  }
  
  /// Log a warning message.
  static void warning(String message) {
    _warningCallback?.call(message);
  }
}
