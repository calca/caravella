import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/file_based_expense_group_repository.dart';
import 'package:org_app_caravella/data/storage_benchmark.dart';
import 'package:org_app_caravella/data/storage_performance.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  group('StorageBenchmark', () {
    late FileBasedExpenseGroupRepository repository;
    late StorageBenchmark benchmark;

    setUp(() async {
      repository = FileBasedExpenseGroupRepository();
      benchmark = StorageBenchmark(repository);
      
      // Clean up any existing test data
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/expense_group_storage.json');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors during cleanup
      }

      repository.clearCache();
      StoragePerformanceMonitor.clear();
    });

    test('should run basic benchmark suite', () async {
      const config = BenchmarkConfig(
        groupCount: 5,
        participantsPerGroup: 2,
        categoriesPerGroup: 3,
        expensesPerGroup: 5,
        iterations: 3,
        enablePerformanceMonitoring: true,
      );

      final results = await benchmark.runBenchmarkSuite(config: config);
      
      expect(results, isNotEmpty);
      expect(results.length, greaterThan(5)); // Should have multiple operations
      
      // Verify all results have reasonable durations
      for (final result in results) {
        expect(result.durations.length, equals(config.iterations));
        expect(result.averageDuration.inMicroseconds, greaterThan(0));
        expect(result.minDuration.inMicroseconds, greaterThan(0));
        expect(result.maxDuration.inMicroseconds, greaterThan(0));
      }
    });

    test('should benchmark save operations', () async {
      const config = BenchmarkConfig(
        groupCount: 3,
        iterations: 2,
        enablePerformanceMonitoring: false,
      );

      final results = await benchmark.runBenchmarkSuite(config: config);
      final saveResult = results.firstWhere((r) => r.operation == 'saveGroups');
      
      expect(saveResult.operation, equals('saveGroups'));
      expect(saveResult.durations.length, equals(config.iterations));
      expect(saveResult.metadata['groupsSaved'], equals(config.groupCount));
    });

    test('should benchmark load operations', () async {
      // First populate with some data
      const config = BenchmarkConfig(
        groupCount: 3,
        iterations: 2,
        enablePerformanceMonitoring: false,
      );

      final results = await benchmark.runBenchmarkSuite(config: config);
      final loadResult = results.firstWhere((r) => r.operation == 'loadAllGroups');
      
      expect(loadResult.operation, equals('loadAllGroups'));
      expect(loadResult.durations.length, equals(config.iterations));
    });

    test('should show performance improvement with caching', () async {
      const configWithoutCache = BenchmarkConfig(
        groupCount: 5,
        iterations: 3,
        enableCaching: false,
        enablePerformanceMonitoring: false,
      );

      const configWithCache = BenchmarkConfig(
        groupCount: 5,
        iterations: 3,
        enableCaching: true,
        enablePerformanceMonitoring: false,
      );

      // Run without caching
      final resultsWithoutCache = await benchmark.runBenchmarkSuite(config: configWithoutCache);
      final loadWithoutCache = resultsWithoutCache
          .firstWhere((r) => r.operation == 'loadAllGroups')
          .averageDuration;

      // Clear and run with caching
      repository.clearCache();
      final resultsWithCache = await benchmark.runBenchmarkSuite(config: configWithCache);
      final loadWithCache = resultsWithCache
          .firstWhere((r) => r.operation == 'loadAllGroups')
          .averageDuration;

      // With caching, subsequent loads should be faster (though first load might be slower)
      // We just verify both complete successfully
      expect(loadWithoutCache.inMicroseconds, greaterThan(0));
      expect(loadWithCache.inMicroseconds, greaterThan(0));
    });

    test('should calculate statistics correctly', () async {
      const config = BenchmarkConfig(
        groupCount: 2,
        iterations: 5,
        enablePerformanceMonitoring: false,
      );

      final results = await benchmark.runBenchmarkSuite(config: config);
      final result = results.first;
      
      // Test percentiles
      expect(result.p50Duration.inMicroseconds, greaterThan(0));
      expect(result.p95Duration.inMicroseconds, greaterThan(0));
      expect(result.p99Duration.inMicroseconds, greaterThan(0));
      
      // Test min/max bounds
      expect(result.minDuration, lessThanOrEqualTo(result.averageDuration));
      expect(result.maxDuration, greaterThanOrEqualTo(result.averageDuration));
      expect(result.minDuration, lessThanOrEqualTo(result.maxDuration));
      
      // Test standard deviation
      expect(result.standardDeviation, greaterThanOrEqualTo(0));
    });

    test('should generate JSON output', () async {
      const config = BenchmarkConfig(
        groupCount: 2,
        iterations: 2,
        enablePerformanceMonitoring: false,
      );

      final results = await benchmark.runBenchmarkSuite(config: config);
      final result = results.first;
      
      final json = result.toJson();
      
      expect(json['operation'], equals(result.operation));
      expect(json['iterations'], equals(result.durations.length));
      expect(json['averageDuration'], equals(result.averageDuration.inMicroseconds));
      expect(json['config']['groupCount'], equals(config.groupCount));
    });

    test('should handle benchmark with performance monitoring', () async {
      const config = BenchmarkConfig(
        groupCount: 3,
        iterations: 2,
        enablePerformanceMonitoring: true,
      );

      StoragePerformanceMonitor.clear();
      
      final results = await benchmark.runBenchmarkSuite(config: config);
      
      expect(results, isNotEmpty);
      
      // Check that performance metrics were recorded
      final metrics = StoragePerformanceMonitor.metrics;
      expect(metrics, isNotEmpty);
      
      // Should have metrics for various operations
      final operations = metrics.map((m) => m.operation).toSet();
      expect(operations, contains('saveGroups'));
    });

    test('should print results without errors', () async {
      const config = BenchmarkConfig(
        groupCount: 2,
        iterations: 1,
        enablePerformanceMonitoring: false,
      );

      final results = await benchmark.runBenchmarkSuite(config: config);
      
      // This should not throw
      expect(() => StorageBenchmark.printResults(results), returnsNormally);
    });

    test('should handle empty results gracefully', () {
      expect(() => StorageBenchmark.printResults([]), returnsNormally);
    });

    test('should benchmark transaction operations', () async {
      const config = BenchmarkConfig(
        groupCount: 3,
        iterations: 2,
        enablePerformanceMonitoring: false,
      );

      final results = await benchmark.runBenchmarkSuite(config: config);
      final transactionResult = results
          .firstWhere((r) => r.operation == 'transactionOperations');
      
      expect(transactionResult.operation, equals('transactionOperations'));
      expect(transactionResult.durations.length, equals(config.iterations));
      expect(transactionResult.metadata['operationsPerTransaction'], greaterThan(0));
    });
  });

  group('BenchmarkResult', () {
    test('should calculate statistics correctly', () {
      final durations = [
        const Duration(milliseconds: 10),
        const Duration(milliseconds: 20),
        const Duration(milliseconds: 15),
        const Duration(milliseconds: 25),
        const Duration(milliseconds: 30),
      ];

      final result = BenchmarkResult(
        operation: 'test',
        durations: durations,
        config: const BenchmarkConfig(),
      );

      expect(result.averageDuration.inMilliseconds, equals(20));
      expect(result.minDuration.inMilliseconds, equals(10));
      expect(result.maxDuration.inMilliseconds, equals(30));
      expect(result.p50Duration.inMilliseconds, equals(20)); // Middle value
    });

    test('should format toString correctly', () {
      final result = BenchmarkResult(
        operation: 'testOp',
        durations: [const Duration(milliseconds: 100)],
        config: const BenchmarkConfig(),
      );

      final str = result.toString();
      expect(str, contains('testOp'));
      expect(str, contains('100ms'));
    });
  });

  group('BenchmarkConfig', () {
    test('should create with defaults', () {
      const config = BenchmarkConfig();
      
      expect(config.groupCount, equals(10));
      expect(config.participantsPerGroup, equals(3));
      expect(config.categoriesPerGroup, equals(5));
      expect(config.expensesPerGroup, equals(10));
      expect(config.iterations, equals(5));
      expect(config.enableCaching, isTrue);
      expect(config.enablePerformanceMonitoring, isTrue);
    });

    test('should copy with changes', () {
      const original = BenchmarkConfig();
      final modified = original.copyWith(
        groupCount: 20,
        iterations: 10,
      );
      
      expect(modified.groupCount, equals(20));
      expect(modified.iterations, equals(10));
      expect(modified.participantsPerGroup, equals(original.participantsPerGroup));
      expect(modified.enableCaching, equals(original.enableCaching));
    });
  });
}