import 'package:flutter/widgets.dart';

/// Represents the state of an async operation
enum AsyncState { idle, loading, success, error }

/// A value container that represents the state of an async operation
/// Provides type-safe access to data, loading, and error states
class AsyncValue<T> {
  final AsyncState state;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;
  
  const AsyncValue._({
    required this.state,
    this.data,
    this.error,
    this.stackTrace,
  });
  
  /// Creates an idle state (initial state before any operation)
  const AsyncValue.idle() : this._(state: AsyncState.idle);
  
  /// Creates a loading state
  const AsyncValue.loading() : this._(state: AsyncState.loading);
  
  /// Creates a success state with data
  const AsyncValue.success(T data) : this._(state: AsyncState.success, data: data);
  
  /// Creates an error state with error information
  const AsyncValue.error(Object error, StackTrace stackTrace) 
    : this._(state: AsyncState.error, error: error, stackTrace: stackTrace);
  
  /// Returns true if the operation is currently loading
  bool get isLoading => state == AsyncState.loading;
  
  /// Returns true if there's an error
  bool get hasError => state == AsyncState.error;
  
  /// Returns true if the operation completed successfully and has data
  bool get hasData => state == AsyncState.success && data != null;
  
  /// Returns true if the state is idle (no operation started)
  bool get isIdle => state == AsyncState.idle;
  
  /// Transforms the current AsyncValue to a new type using the provided function
  AsyncValue<R> map<R>(R Function(T data) transform) {
    if (hasData) {
      try {
        return AsyncValue.success(transform(data as T));
      } catch (e, stackTrace) {
        return AsyncValue.error(e, stackTrace);
      }
    }
    
    switch (state) {
      case AsyncState.idle:
        return const AsyncValue.idle();
      case AsyncState.loading:
        return const AsyncValue.loading();
      case AsyncState.error:
        return AsyncValue.error(error!, stackTrace!);
      case AsyncState.success:
        // Should not reach here as we handle hasData above
        return const AsyncValue.idle();
    }
  }
  
  /// Pattern matching method to handle different states
  /// Returns appropriate widgets based on the current state
  Widget when({
    required Widget Function() loading,
    required Widget Function(T data) data,
    required Widget Function(Object error, StackTrace stackTrace) error,
    Widget Function()? idle,
  }) {
    switch (state) {
      case AsyncState.idle:
        return idle?.call() ?? const SizedBox.shrink();
      case AsyncState.loading:
        return loading();
      case AsyncState.success:
        return data(this.data as T);
      case AsyncState.error:
        return error(this.error!, stackTrace!);
    }
  }
  
  /// Alternative pattern matching that allows handling loading and error states together
  Widget maybeWhen({
    Widget Function()? loading,
    Widget Function(T data)? data,
    Widget Function(Object error, StackTrace stackTrace)? error,
    Widget Function()? idle,
    required Widget Function() orElse,
  }) {
    switch (state) {
      case AsyncState.idle:
        return idle?.call() ?? orElse();
      case AsyncState.loading:
        return loading?.call() ?? orElse();
      case AsyncState.success:
        return data?.call(this.data as T) ?? orElse();
      case AsyncState.error:
        return error?.call(this.error!, stackTrace!) ?? orElse();
    }
  }
  
  @override
  String toString() {
    switch (state) {
      case AsyncState.idle:
        return 'AsyncValue.idle()';
      case AsyncState.loading:
        return 'AsyncValue.loading()';
      case AsyncState.success:
        return 'AsyncValue.success($data)';
      case AsyncState.error:
        return 'AsyncValue.error($error, $stackTrace)';
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AsyncValue<T> &&
        other.state == state &&
        other.data == data &&
        other.error == error &&
        other.stackTrace == stackTrace;
  }
  
  @override
  int get hashCode {
    return state.hashCode ^
        data.hashCode ^
        error.hashCode ^
        stackTrace.hashCode;
  }
}