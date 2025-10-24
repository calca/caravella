import 'dart:async';
import 'services/logger_service.dart';

/// Performance metrics for storage operations
class StorageMetrics {
  final String operation;
  final Duration duration;
  final bool wasFromCache;
  final int? dataSize;
  final DateTime timestamp;

  StorageMetrics({
    required this.operation,
    required this.duration,
    this.wasFromCache = false,
    this.dataSize,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    final cacheStatus = wasFromCache ? ' (cached)' : '';
    final sizeInfo = dataSize != null ? ' [$dataSize bytes]' : '';
    return '$operation: ${duration.inMilliseconds}ms$cacheStatus$sizeInfo';
  }
}

/// Storage performance monitor
class StoragePerformanceMonitor {
  static final List<StorageMetrics> _metrics = [];
  static bool _isEnabled = false;

  /// Enable performance monitoring
  static void enable() {
    _isEnabled = true;
  }

  /// Disable performance monitoring
  static void disable() {
    _isEnabled = false;
  }

  /// Clear all recorded metrics
  static void clear() {
    _metrics.clear();
  }

  /// Get all recorded metrics
  static List<StorageMetrics> get metrics => List.unmodifiable(_metrics);

  /// Check if monitoring is enabled
  static bool get isEnabled => _isEnabled;

  /// Record a metric
  static void record(StorageMetrics metric) {
    if (_isEnabled) {
      _metrics.add(metric);

      // Keep only last 1000 metrics to prevent memory leaks
      if (_metrics.length > 1000) {
        _metrics.removeRange(0, _metrics.length - 1000);
      }
    }
  }

  /// Get metrics for a specific operation
  static List<StorageMetrics> getMetricsFor(String operation) {
    return _metrics.where((m) => m.operation == operation).toList();
  }

  /// Get average duration for an operation
  static Duration? getAverageDuration(String operation) {
    final operationMetrics = getMetricsFor(operation);
    if (operationMetrics.isEmpty) return null;

    final totalMs = operationMetrics
        .map((m) => m.duration.inMilliseconds)
        .reduce((a, b) => a + b);

    return Duration(milliseconds: totalMs ~/ operationMetrics.length);
  }

  /// Get cache hit rate for an operation
  static double? getCacheHitRate(String operation) {
    final operationMetrics = getMetricsFor(operation);
    if (operationMetrics.isEmpty) return null;

    final cacheHits = operationMetrics.where((m) => m.wasFromCache).length;
    return cacheHits / operationMetrics.length;
  }

  /// Get summary statistics
  static Map<String, dynamic> getSummary() {
    if (_metrics.isEmpty) return {};

    final operations = _metrics.map((m) => m.operation).toSet();
    final summary = <String, dynamic>{};

    for (final operation in operations) {
      final opMetrics = getMetricsFor(operation);
      final durations = opMetrics
          .map((m) => m.duration.inMilliseconds)
          .toList();
      durations.sort();

      summary[operation] = {
        'count': opMetrics.length,
        'avgDuration': getAverageDuration(operation)!.inMilliseconds,
        'minDuration': durations.first,
        'maxDuration': durations.last,
        'p50Duration': durations[durations.length ~/ 2],
        'p95Duration': durations[(durations.length * 0.95).floor()],
        'cacheHitRate': getCacheHitRate(operation),
        'totalDataBytes': opMetrics
            .where((m) => m.dataSize != null)
            .map((m) => m.dataSize!)
            .fold<int>(0, (sum, size) => sum + size),
      };
    }

    return summary;
  }

  /// Print performance summary to console
  static void printSummary() {
    final summary = getSummary();
    if (summary.isEmpty) {
      LoggerService.info(
        'No performance metrics recorded',
        name: 'storage.performance',
      );
      return;
    }

    LoggerService.info(
      '=== Storage Performance Summary ===',
      name: 'storage.performance',
    );
    for (final entry in summary.entries) {
      final operation = entry.key;
      final stats = entry.value as Map<String, dynamic>;

      LoggerService.info('$operation:', name: 'storage.performance');
      LoggerService.info(
        '  Count: ${stats['count']}',
        name: 'storage.performance',
      );
      LoggerService.info(
        '  Avg Duration: ${stats['avgDuration']}ms',
        name: 'storage.performance',
      );
      LoggerService.info(
        '  Min Duration: ${stats['minDuration']}ms',
        name: 'storage.performance',
      );
      LoggerService.info(
        '  Max Duration: ${stats['maxDuration']}ms',
        name: 'storage.performance',
      );
      LoggerService.info(
        '  P50 Duration: ${stats['p50Duration']}ms',
        name: 'storage.performance',
      );
      LoggerService.info(
        '  P95 Duration: ${stats['p95Duration']}ms',
        name: 'storage.performance',
      );

      if (stats['cacheHitRate'] != null) {
        final hitRate = ((stats['cacheHitRate'] as double) * 100)
            .toStringAsFixed(1);
        LoggerService.info(
          '  Cache Hit Rate: $hitRate%',
          name: 'storage.performance',
        );
      }

      if (stats['totalDataBytes'] > 0) {
        final totalKB = (stats['totalDataBytes'] / 1024).toStringAsFixed(1);
        LoggerService.info(
          '  Total Data: ${totalKB}KB',
          name: 'storage.performance',
        );
      }

      LoggerService.info('', name: 'storage.performance');
    }
  }
}

/// Mixin to add performance monitoring to repository operations
mixin PerformanceMonitoring {
  /// Measures the performance of an operation
  Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    bool wasFromCache = false,
    int? dataSize,
  }) async {
    if (!StoragePerformanceMonitor.isEnabled) {
      return await operation();
    }

    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();

      stopwatch.stop();
      StoragePerformanceMonitor.record(
        StorageMetrics(
          operation: operationName,
          duration: stopwatch.elapsed,
          wasFromCache: wasFromCache,
          dataSize: dataSize,
        ),
      );

      return result;
    } catch (e) {
      stopwatch.stop();
      StoragePerformanceMonitor.record(
        StorageMetrics(
          operation: '$operationName (error)',
          duration: stopwatch.elapsed,
          wasFromCache: wasFromCache,
          dataSize: dataSize,
        ),
      );

      rethrow;
    }
  }

  /// Measures the performance of a synchronous operation
  T measureSyncOperation<T>(
    String operationName,
    T Function() operation, {
    bool wasFromCache = false,
    int? dataSize,
  }) {
    if (!StoragePerformanceMonitor.isEnabled) {
      return operation();
    }

    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();

      stopwatch.stop();
      StoragePerformanceMonitor.record(
        StorageMetrics(
          operation: operationName,
          duration: stopwatch.elapsed,
          wasFromCache: wasFromCache,
          dataSize: dataSize,
        ),
      );

      return result;
    } catch (e) {
      stopwatch.stop();
      StoragePerformanceMonitor.record(
        StorageMetrics(
          operation: '$operationName (error)',
          duration: stopwatch.elapsed,
          wasFromCache: wasFromCache,
          dataSize: dataSize,
        ),
      );

      rethrow;
    }
  }
}
