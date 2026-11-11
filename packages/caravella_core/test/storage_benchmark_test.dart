import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/data/sqlite_expense_group_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:caravella_core/data/storage_performance.dart';
import 'storage_benchmark.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  group('StorageBenchmark', () {
    late SqliteExpenseGroupRepository repository;
    late StorageBenchmark benchmark;

    setUp(() async {
      final dir = Directory.systemTemp.createTempSync('bench_test');
      repository = SqliteExpenseGroupRepository(
        databasePath: '${dir.path}/bench.db',
      );
      benchmark = StorageBenchmark(repository);
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
      final loadResult = results.firstWhere(
        (r) => r.operation == 'loadAllGroups',
      );

      expect(loadResult.operation, equals('loadAllGroups'));
      expect(loadResult.durations.length, equals(config.iterations));
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
      expect(
        json['averageDuration'],
        equals(result.averageDuration.inMicroseconds),
      );
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
      expect(operations, contains('saveGroup'));
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
      final modified = original.copyWith(groupCount: 20, iterations: 10);

      expect(modified.groupCount, equals(20));
      expect(modified.iterations, equals(10));
      expect(
        modified.participantsPerGroup,
        equals(original.participantsPerGroup),
      );
      expect(modified.enableCaching, equals(original.enableCaching));
    });
  });
}
