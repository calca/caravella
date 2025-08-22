import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/storage_performance.dart';

void main() {
  group('StoragePerformanceMonitor', () {
    setUp(() {
      StoragePerformanceMonitor.clear();
      StoragePerformanceMonitor.disable();
    });

    test('should be disabled by default', () {
      expect(StoragePerformanceMonitor.isEnabled, isFalse);
    });

    test('should enable and disable correctly', () {
      StoragePerformanceMonitor.enable();
      expect(StoragePerformanceMonitor.isEnabled, isTrue);
      
      StoragePerformanceMonitor.disable();
      expect(StoragePerformanceMonitor.isEnabled, isFalse);
    });

    test('should not record metrics when disabled', () {
      StoragePerformanceMonitor.disable();
      
      final metric = StorageMetrics(
        operation: 'test',
        duration: const Duration(milliseconds: 100),
      );
      
      StoragePerformanceMonitor.record(metric);
      expect(StoragePerformanceMonitor.metrics, isEmpty);
    });

    test('should record metrics when enabled', () {
      StoragePerformanceMonitor.enable();
      
      final metric = StorageMetrics(
        operation: 'test',
        duration: const Duration(milliseconds: 100),
      );
      
      StoragePerformanceMonitor.record(metric);
      expect(StoragePerformanceMonitor.metrics, hasLength(1));
      expect(StoragePerformanceMonitor.metrics.first.operation, equals('test'));
    });

    test('should clear metrics', () {
      StoragePerformanceMonitor.enable();
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'test',
        duration: const Duration(milliseconds: 100),
      ));
      
      expect(StoragePerformanceMonitor.metrics, hasLength(1));
      
      StoragePerformanceMonitor.clear();
      expect(StoragePerformanceMonitor.metrics, isEmpty);
    });

    test('should filter metrics by operation', () {
      StoragePerformanceMonitor.enable();
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'read',
        duration: const Duration(milliseconds: 50),
      ));
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'write',
        duration: const Duration(milliseconds: 100),
      ));
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'read',
        duration: const Duration(milliseconds: 75),
      ));
      
      final readMetrics = StoragePerformanceMonitor.getMetricsFor('read');
      expect(readMetrics, hasLength(2));
      expect(readMetrics.every((m) => m.operation == 'read'), isTrue);
      
      final writeMetrics = StoragePerformanceMonitor.getMetricsFor('write');
      expect(writeMetrics, hasLength(1));
    });

    test('should calculate average duration', () {
      StoragePerformanceMonitor.enable();
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'test',
        duration: const Duration(milliseconds: 100),
      ));
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'test',
        duration: const Duration(milliseconds: 200),
      ));
      
      final average = StoragePerformanceMonitor.getAverageDuration('test');
      expect(average, isNotNull);
      expect(average!.inMilliseconds, equals(150));
    });

    test('should return null for non-existent operation average', () {
      final average = StoragePerformanceMonitor.getAverageDuration('non-existent');
      expect(average, isNull);
    });

    test('should calculate cache hit rate', () {
      StoragePerformanceMonitor.enable();
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'read',
        duration: const Duration(milliseconds: 100),
        wasFromCache: true,
      ));
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'read',
        duration: const Duration(milliseconds: 50),
        wasFromCache: false,
      ));
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'read',
        duration: const Duration(milliseconds: 25),
        wasFromCache: true,
      ));
      
      final hitRate = StoragePerformanceMonitor.getCacheHitRate('read');
      expect(hitRate, isNotNull);
      expect(hitRate!, closeTo(0.667, 0.001)); // 2/3 ≈ 0.667
    });

    test('should return null for non-existent operation cache hit rate', () {
      final hitRate = StoragePerformanceMonitor.getCacheHitRate('non-existent');
      expect(hitRate, isNull);
    });

    test('should generate summary statistics', () {
      StoragePerformanceMonitor.enable();
      
      // Add some test metrics
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'read',
        duration: const Duration(milliseconds: 50),
        wasFromCache: true,
        dataSize: 1024,
      ));
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'read',
        duration: const Duration(milliseconds: 100),
        wasFromCache: false,
        dataSize: 2048,
      ));
      
      StoragePerformanceMonitor.record(StorageMetrics(
        operation: 'write',
        duration: const Duration(milliseconds: 200),
        wasFromCache: false,
        dataSize: 1500,
      ));
      
      final summary = StoragePerformanceMonitor.getSummary();
      
      expect(summary, containsPair('read', anything));
      expect(summary, containsPair('write', anything));
      
      final readStats = summary['read'] as Map<String, dynamic>;
      expect(readStats['count'], equals(2));
      expect(readStats['avgDuration'], equals(75));
      expect(readStats['minDuration'], equals(50));
      expect(readStats['maxDuration'], equals(100));
      expect(readStats['cacheHitRate'], equals(0.5));
      expect(readStats['totalDataBytes'], equals(3072));
      
      final writeStats = summary['write'] as Map<String, dynamic>;
      expect(writeStats['count'], equals(1));
      expect(writeStats['avgDuration'], equals(200));
    });

    test('should handle empty summary', () {
      final summary = StoragePerformanceMonitor.getSummary();
      expect(summary, isEmpty);
    });

    test('should limit metrics to prevent memory leaks', () {
      StoragePerformanceMonitor.enable();
      
      // Add more than 1000 metrics
      for (int i = 0; i < 1200; i++) {
        StoragePerformanceMonitor.record(StorageMetrics(
          operation: 'test$i',
          duration: Duration(milliseconds: i),
        ));
      }
      
      // Should have been trimmed to 1000
      expect(StoragePerformanceMonitor.metrics.length, equals(1000));
      
      // Should contain the most recent 1000 metrics
      expect(StoragePerformanceMonitor.metrics.first.operation, equals('test200'));
      expect(StoragePerformanceMonitor.metrics.last.operation, equals('test1199'));
    });
  });

  group('StorageMetrics', () {
    test('should format correctly without cache info', () {
      final metric = StorageMetrics(
        operation: 'read',
        duration: const Duration(milliseconds: 100),
      );
      
      final formatted = metric.toString();
      expect(formatted, equals('read: 100ms'));
    });

    test('should format correctly with cache info', () {
      final metric = StorageMetrics(
        operation: 'read',
        duration: const Duration(milliseconds: 50),
        wasFromCache: true,
      );
      
      final formatted = metric.toString();
      expect(formatted, equals('read: 50ms (cached)'));
    });

    test('should format correctly with data size', () {
      final metric = StorageMetrics(
        operation: 'write',
        duration: const Duration(milliseconds: 200),
        dataSize: 1024,
      );
      
      final formatted = metric.toString();
      expect(formatted, equals('write: 200ms [1024 bytes]'));
    });

    test('should format correctly with all info', () {
      final metric = StorageMetrics(
        operation: 'read',
        duration: const Duration(milliseconds: 25),
        wasFromCache: true,
        dataSize: 512,
      );
      
      final formatted = metric.toString();
      expect(formatted, equals('read: 25ms (cached) [512 bytes]'));
    });
  });

  group('PerformanceMonitoring Mixin', () {
    late TestClass testClass;

    setUp(() {
      testClass = TestClass();
      StoragePerformanceMonitor.clear();
    });

    test('should measure async operation when enabled', () async {
      StoragePerformanceMonitor.enable();
      
      final result = await testClass.testAsyncOperation();
      expect(result, equals('success'));
      
      final metrics = StoragePerformanceMonitor.getMetricsFor('testAsync');
      expect(metrics, hasLength(1));
      expect(metrics.first.duration.inMilliseconds, greaterThan(0));
    });

    test('should not measure when disabled', () async {
      StoragePerformanceMonitor.disable();
      
      final result = await testClass.testAsyncOperation();
      expect(result, equals('success'));
      
      expect(StoragePerformanceMonitor.metrics, isEmpty);
    });

    test('should measure sync operation when enabled', () {
      StoragePerformanceMonitor.enable();
      
      final result = testClass.testSyncOperation();
      expect(result, equals(42));
      
      final metrics = StoragePerformanceMonitor.getMetricsFor('testSync');
      expect(metrics, hasLength(1));
    });

    test('should record errors correctly', () async {
      StoragePerformanceMonitor.enable();
      
      try {
        await testClass.testFailingOperation();
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e.toString(), contains('Test error'));
      }
      
      final metrics = StoragePerformanceMonitor.getMetricsFor('testFailing (error)');
      expect(metrics, hasLength(1));
    });

    test('should pass through cache and size info', () async {
      StoragePerformanceMonitor.enable();
      
      await testClass.testOperationWithMetadata();
      
      final metrics = StoragePerformanceMonitor.getMetricsFor('testMetadata');
      expect(metrics, hasLength(1));
      expect(metrics.first.wasFromCache, isTrue);
      expect(metrics.first.dataSize, equals(1024));
    });
  });
}

// Test class that uses the PerformanceMonitoring mixin
class TestClass with PerformanceMonitoring {
  Future<String> testAsyncOperation() async {
    return await measureOperation(
      'testAsync',
      () async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'success';
      },
    );
  }

  int testSyncOperation() {
    return measureSyncOperation(
      'testSync',
      () {
        return 42;
      },
    );
  }

  Future<void> testFailingOperation() async {
    await measureOperation(
      'testFailing',
      () async {
        throw Exception('Test error');
      },
    );
  }

  Future<void> testOperationWithMetadata() async {
    await measureOperation(
      'testMetadata',
      () async {
        await Future.delayed(const Duration(milliseconds: 5));
      },
      wasFromCache: true,
      dataSize: 1024,
    );
  }
}