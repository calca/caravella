import 'dart:async';

/// A utility class to debounce function calls.
///
/// Delays execution of [callback] until after [duration] has elapsed
/// since the last call to [call]. Useful for rate-limiting expensive
/// operations like search queries.
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(duration: Duration(milliseconds: 300));
/// textField.onChanged = (text) => debouncer.call(() => search(text));
/// ```
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({required this.duration});

  /// Cancels any pending execution and schedules [callback] to run after [duration].
  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  /// Cancels any pending execution.
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes of the debouncer and cancels any pending execution.
  void dispose() {
    cancel();
  }
}
