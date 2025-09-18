import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/async_state.dart';
import '../state/async_state_notifier.dart';

/// A widget that builds its UI based on an AsyncValue state
/// Provides a declarative way to handle loading, data, error, and idle states
class AsyncValueBuilder<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) data;
  final Widget Function(BuildContext context)? loading;
  final Widget Function(BuildContext context, Object error, StackTrace stackTrace)? error;
  final Widget Function(BuildContext context)? idle;
  final Widget Function(BuildContext context)? orElse;

  const AsyncValueBuilder({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.idle,
    this.orElse,
  });

  @override
  Widget build(BuildContext context) {
    return value.maybeWhen(
      data: (data) => this.data(context, data),
      loading: loading != null ? () => loading!(context) : null,
      error: error != null 
        ? (error, stackTrace) => this.error!(context, error, stackTrace) 
        : null,
      idle: idle != null ? () => idle!(context) : null,
      orElse: orElse != null 
        ? () => orElse!(context)
        : () => const SizedBox.shrink(),
    );
  }
}

/// A consumer widget that listens to an AsyncStateNotifier and rebuilds on changes
/// Provides a convenient way to use AsyncStateNotifier with the widget tree
class AsyncStateConsumer<T extends AsyncStateNotifier<R>, R> extends StatelessWidget {
  final Widget Function(BuildContext context, AsyncValue<R> value, T notifier) builder;
  final Widget Function(BuildContext context)? loading;
  final Widget Function(BuildContext context, Object error, StackTrace stackTrace)? error;
  final Widget Function(BuildContext context)? idle;

  const AsyncStateConsumer({
    super.key,
    required this.builder,
    this.loading,
    this.error,
    this.idle,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, notifier, child) {
        return builder(context, notifier.value, notifier);
      },
    );
  }
}

/// A simplified consumer that automatically handles common states
/// Perfect for most use cases where you just need to display data or common states
class SimpleAsyncConsumer<T extends AsyncStateNotifier<R>, R> extends StatelessWidget {
  final Widget Function(BuildContext context, R data, T notifier) data;
  final Widget Function(BuildContext context)? loading;
  final Widget Function(BuildContext context, Object error)? error;
  final Widget Function(BuildContext context)? idle;

  const SimpleAsyncConsumer({
    super.key,
    required this.data,
    this.loading,
    this.error,
    this.idle,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncStateConsumer<T, R>(
      builder: (context, value, notifier) {
        return AsyncValueBuilder<R>(
          value: value,
          data: (context, data) => this.data(context, data, notifier),
          loading: loading,
          error: error != null 
            ? (context, error, _) => this.error!(context, error)
            : null,
          idle: idle,
          orElse: () => _buildDefaultStates(context, value),
        );
      },
    );
  }

  Widget _buildDefaultStates(BuildContext context, AsyncValue<R> value) {
    if (value.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (value.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${value.error}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

/// Extension methods for AsyncValue to provide common UI patterns
extension AsyncValueUIExtensions<T> on AsyncValue<T> {
  /// Returns a widget that shows loading indicator when loading
  Widget showLoadingWhen({
    required Widget child,
    Widget? loadingWidget,
  }) {
    if (isLoading) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }
    return child;
  }
  
  /// Returns a widget that shows error when there's an error
  Widget showErrorWhen({
    required Widget child,
    Widget Function(Object error)? errorBuilder,
  }) {
    if (hasError) {
      return errorBuilder?.call(error!) ?? 
        Center(child: Text('Error: $error'));
    }
    return child;
  }
}