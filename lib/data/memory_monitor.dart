import 'dart:io';
import '../services/logger_service.dart';
import 'storage_performance.dart';

/// Memory usage monitoring for storage operations
class MemoryMonitor {
  static bool _enabled = false;
  static final List<MemorySnapshot> _snapshots = [];
  static const int _maxSnapshots = 50;

  /// Enables memory monitoring
  static void enable() {
    _enabled = true;
  }

  /// Disables memory monitoring
  static void disable() {
    _enabled = false;
  }

  /// Checks if monitoring is enabled
  static bool get isEnabled => _enabled;

  /// Takes a memory snapshot
  static void takeSnapshot(String operation, {Map<String, dynamic>? metadata}) {
    if (!_enabled) return;

    try {
      final processInfo = ProcessInfo.currentRss;
      final snapshot = MemorySnapshot(
        operation: operation,
        rssBytes: processInfo,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      _snapshots.add(snapshot);

      // Keep only the last N snapshots
      if (_snapshots.length > _maxSnapshots) {
        _snapshots.removeRange(0, _snapshots.length - _maxSnapshots);
      }

      LoggerService.debug(
        'Memory snapshot for $operation: ${(processInfo / 1024 / 1024).toStringAsFixed(1)}MB',
        name: 'storage.memory',
      );
    } catch (e) {
      LoggerService.warn(
        'Failed to take memory snapshot: $e',
        name: 'storage.memory',
      );
    }
  }

  /// Gets all memory snapshots
  static List<MemorySnapshot> get snapshots => List.unmodifiable(_snapshots);

  /// Gets memory snapshots for a specific operation
  static List<MemorySnapshot> getSnapshotsFor(String operation) {
    return _snapshots.where((s) => s.operation == operation).toList();
  }

  /// Gets memory usage statistics
  static Map<String, dynamic> getMemoryStats() {
    if (_snapshots.isEmpty) return {};

    final operations = _snapshots.map((s) => s.operation).toSet();
    final stats = <String, dynamic>{};

    for (final operation in operations) {
      final opSnapshots = getSnapshotsFor(operation);
      final memoryValues = opSnapshots.map((s) => s.rssBytes).toList();
      
      if (memoryValues.isNotEmpty) {
        memoryValues.sort();
        
        stats[operation] = {
          'count': opSnapshots.length,
          'avgMemoryMB': (memoryValues.map((v) => v / 1024 / 1024).reduce((a, b) => a + b) / memoryValues.length).toStringAsFixed(1),
          'minMemoryMB': (memoryValues.first / 1024 / 1024).toStringAsFixed(1),
          'maxMemoryMB': (memoryValues.last / 1024 / 1024).toStringAsFixed(1),
          'p50MemoryMB': (memoryValues[memoryValues.length ~/ 2] / 1024 / 1024).toStringAsFixed(1),
          'p95MemoryMB': (memoryValues[(memoryValues.length * 0.95).floor()] / 1024 / 1024).toStringAsFixed(1),
        };
      }
    }

    return stats;
  }

  /// Detects potential memory leaks by analyzing trends
  static List<String> detectMemoryLeaks() {
    final issues = <String>[];
    final operations = _snapshots.map((s) => s.operation).toSet();

    for (final operation in operations) {
      final opSnapshots = getSnapshotsFor(operation);
      if (opSnapshots.length < 5) continue; // Need enough data points

      // Sort by timestamp
      opSnapshots.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      // Check for consistently increasing memory usage
      final memoryValues = opSnapshots.map((s) => s.rssBytes).toList();
      int increasingCount = 0;
      
      for (int i = 1; i < memoryValues.length; i++) {
        if (memoryValues[i] > memoryValues[i - 1]) {
          increasingCount++;
        }
      }

      // If more than 70% of measurements show increasing memory, flag as potential leak
      final increasingRatio = increasingCount / (memoryValues.length - 1);
      if (increasingRatio > 0.7) {
        final startMB = (memoryValues.first / 1024 / 1024).toStringAsFixed(1);
        final endMB = (memoryValues.last / 1024 / 1024).toStringAsFixed(1);
        issues.add('Potential memory leak in $operation: ${startMB}MB -> ${endMB}MB');
      }
    }

    return issues;
  }

  /// Clears all memory snapshots
  static void clear() {
    _snapshots.clear();
  }

  /// Prints memory statistics
  static void printStats() {
    final stats = getMemoryStats();
    if (stats.isEmpty) {
      LoggerService.info('No memory snapshots recorded', name: 'storage.memory');
      return;
    }

    LoggerService.info('=== Memory Usage Statistics ===', name: 'storage.memory');
    for (final entry in stats.entries) {
      final operation = entry.key;
      final opStats = entry.value as Map<String, dynamic>;

      LoggerService.info('$operation:', name: 'storage.memory');
      LoggerService.info('  Count: ${opStats['count']}', name: 'storage.memory');
      LoggerService.info('  Avg Memory: ${opStats['avgMemoryMB']}MB', name: 'storage.memory');
      LoggerService.info('  Min Memory: ${opStats['minMemoryMB']}MB', name: 'storage.memory');
      LoggerService.info('  Max Memory: ${opStats['maxMemoryMB']}MB', name: 'storage.memory');
      LoggerService.info('  P50 Memory: ${opStats['p50MemoryMB']}MB', name: 'storage.memory');
      LoggerService.info('  P95 Memory: ${opStats['p95MemoryMB']}MB', name: 'storage.memory');
      LoggerService.info('', name: 'storage.memory');
    }

    // Check for potential memory leaks
    final leaks = detectMemoryLeaks();
    if (leaks.isNotEmpty) {
      LoggerService.warn('=== Potential Memory Issues ===', name: 'storage.memory');
      for (final leak in leaks) {
        LoggerService.warn(leak, name: 'storage.memory');
      }
    }
  }
}

/// Represents a memory usage snapshot at a point in time
class MemorySnapshot {
  final String operation;
  final int rssBytes;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  MemorySnapshot({
    required this.operation,
    required this.rssBytes,
    required this.timestamp,
    required this.metadata,
  });

  /// Memory usage in megabytes
  double get memoryMB => rssBytes / 1024 / 1024;

  @override
  String toString() {
    return '$operation: ${memoryMB.toStringAsFixed(1)}MB at ${timestamp.toIso8601String()}';
  }
}

/// Mixin to add memory monitoring to repository operations
mixin MemoryMonitoring {
  /// Measures memory usage of an operation
  Future<T> measureMemoryUsage<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    if (!MemoryMonitor.isEnabled) {
      return await operation();
    }

    // Take snapshot before operation
    MemoryMonitor.takeSnapshot('${operationName}_start', metadata: metadata);

    try {
      final result = await operation();
      
      // Take snapshot after successful operation
      MemoryMonitor.takeSnapshot('${operationName}_end', metadata: metadata);
      
      return result;
    } catch (e) {
      // Take snapshot after failed operation
      MemoryMonitor.takeSnapshot('${operationName}_error', metadata: metadata);
      rethrow;
    }
  }

  /// Synchronous memory measurement
  T measureSyncMemoryUsage<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    if (!MemoryMonitor.isEnabled) {
      return operation();
    }

    // Take snapshot before operation
    MemoryMonitor.takeSnapshot('${operationName}_start', metadata: metadata);

    try {
      final result = operation();
      
      // Take snapshot after successful operation
      MemoryMonitor.takeSnapshot('${operationName}_end', metadata: metadata);
      
      return result;
    } catch (e) {
      // Take snapshot after failed operation
      MemoryMonitor.takeSnapshot('${operationName}_error', metadata: metadata);
      rethrow;
    }
  }
}