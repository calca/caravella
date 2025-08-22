import 'dart:math';
import 'expense_group.dart';
import 'expense_participant.dart';
import 'expense_category.dart';
import 'expense_details.dart';
import 'expense_group_repository.dart';
import 'storage_performance.dart';

/// Benchmark configuration
class BenchmarkConfig {
  final int groupCount;
  final int participantsPerGroup;
  final int categoriesPerGroup;
  final int expensesPerGroup;
  final int iterations;
  final bool enableCaching;
  final bool enablePerformanceMonitoring;

  const BenchmarkConfig({
    this.groupCount = 10,
    this.participantsPerGroup = 3,
    this.categoriesPerGroup = 5,
    this.expensesPerGroup = 10,
    this.iterations = 5,
    this.enableCaching = true,
    this.enablePerformanceMonitoring = true,
  });

  BenchmarkConfig copyWith({
    int? groupCount,
    int? participantsPerGroup,
    int? categoriesPerGroup,
    int? expensesPerGroup,
    int? iterations,
    bool? enableCaching,
    bool? enablePerformanceMonitoring,
  }) {
    return BenchmarkConfig(
      groupCount: groupCount ?? this.groupCount,
      participantsPerGroup: participantsPerGroup ?? this.participantsPerGroup,
      categoriesPerGroup: categoriesPerGroup ?? this.categoriesPerGroup,
      expensesPerGroup: expensesPerGroup ?? this.expensesPerGroup,
      iterations: iterations ?? this.iterations,
      enableCaching: enableCaching ?? this.enableCaching,
      enablePerformanceMonitoring: enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
    );
  }
}

/// Benchmark result
class BenchmarkResult {
  final String operation;
  final List<Duration> durations;
  final BenchmarkConfig config;
  final Map<String, dynamic> metadata;

  BenchmarkResult({
    required this.operation,
    required this.durations,
    required this.config,
    this.metadata = const {},
  });

  Duration get averageDuration {
    final totalMs = durations.map((d) => d.inMicroseconds).reduce((a, b) => a + b);
    return Duration(microseconds: totalMs ~/ durations.length);
  }

  Duration get minDuration => durations.reduce((a, b) => a < b ? a : b);
  Duration get maxDuration => durations.reduce((a, b) => a > b ? a : b);

  Duration get p50Duration {
    final sorted = List<Duration>.from(durations)..sort((a, b) => a.compareTo(b));
    return sorted[sorted.length ~/ 2];
  }

  Duration get p95Duration {
    final sorted = List<Duration>.from(durations)..sort((a, b) => a.compareTo(b));
    return sorted[(sorted.length * 0.95).floor()];
  }

  Duration get p99Duration {
    final sorted = List<Duration>.from(durations)..sort((a, b) => a.compareTo(b));
    return sorted[(sorted.length * 0.99).floor()];
  }

  double get standardDeviation {
    final avg = averageDuration.inMicroseconds.toDouble();
    final variance = durations
        .map((d) => pow(d.inMicroseconds - avg, 2))
        .reduce((a, b) => a + b) / durations.length;
    return sqrt(variance);
  }

  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'iterations': durations.length,
      'averageDuration': averageDuration.inMicroseconds,
      'minDuration': minDuration.inMicroseconds,
      'maxDuration': maxDuration.inMicroseconds,
      'p50Duration': p50Duration.inMicroseconds,
      'p95Duration': p95Duration.inMicroseconds,
      'p99Duration': p99Duration.inMicroseconds,
      'standardDeviation': standardDeviation,
      'config': {
        'groupCount': config.groupCount,
        'participantsPerGroup': config.participantsPerGroup,
        'categoriesPerGroup': config.categoriesPerGroup,
        'expensesPerGroup': config.expensesPerGroup,
        'enableCaching': config.enableCaching,
      },
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return '$operation: avg=${averageDuration.inMilliseconds}ms, '
           'min=${minDuration.inMilliseconds}ms, '
           'max=${maxDuration.inMilliseconds}ms, '
           'p95=${p95Duration.inMilliseconds}ms, '
           'stddev=${standardDeviation.toStringAsFixed(1)}μs';
  }
}

/// Storage benchmark suite
class StorageBenchmark {
  final IExpenseGroupRepository repository;
  final Random _random = Random();

  StorageBenchmark(this.repository);

  /// Runs a complete benchmark suite
  Future<List<BenchmarkResult>> runBenchmarkSuite({
    BenchmarkConfig config = const BenchmarkConfig(),
  }) async {
    final results = <BenchmarkResult>[];

    if (config.enablePerformanceMonitoring) {
      StoragePerformanceMonitor.enable();
    } else {
      StoragePerformanceMonitor.disable();
    }

    print('Running storage benchmarks with config: ${config.groupCount} groups, '
          '${config.participantsPerGroup} participants, ${config.categoriesPerGroup} categories, '
          '${config.expensesPerGroup} expenses per group');

    // Generate test data
    final testGroups = _generateTestGroups(config);
    print('Generated ${testGroups.length} test groups');

    // Benchmark: Save groups
    results.add(await _benchmarkSaveGroups(testGroups, config));

    // Benchmark: Load all groups
    results.add(await _benchmarkLoadAllGroups(config));

    // Benchmark: Load groups by ID
    results.add(await _benchmarkLoadGroupsById(testGroups, config));

    // Benchmark: Filter operations
    results.add(await _benchmarkFilterOperations(config));

    // Benchmark: Pin operations
    results.add(await _benchmarkPinOperations(testGroups, config));

    // Benchmark: Search operations
    results.add(await _benchmarkSearchOperations(config));

    // Benchmark: Transaction operations
    results.add(await _benchmarkTransactionOperations(testGroups, config));

    return results;
  }

  /// Generates test data
  List<ExpenseGroup> _generateTestGroups(BenchmarkConfig config) {
    final groups = <ExpenseGroup>[];

    for (int i = 0; i < config.groupCount; i++) {
      final participants = List.generate(config.participantsPerGroup,
          (j) => ExpenseParticipant(name: 'Participant ${i}_$j'));

      final categories = List.generate(config.categoriesPerGroup,
          (j) => ExpenseCategory(name: 'Category ${i}_$j'));

      final expenses = List.generate(config.expensesPerGroup, (j) {
        return ExpenseDetails(
          category: categories[_random.nextInt(categories.length)],
          amount: (_random.nextDouble() * 100) + 10,
          paidBy: participants[_random.nextInt(participants.length)],
          date: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
          name: 'Expense ${i}_$j',
        );
      });

      groups.add(ExpenseGroup(
        id: 'test-group-$i',
        title: 'Test Group $i',
        currency: ['USD', 'EUR', 'GBP'][_random.nextInt(3)],
        participants: participants,
        categories: categories,
        expenses: expenses,
        timestamp: DateTime.now().subtract(Duration(hours: i)),
        pinned: i == 0, // Pin first group
        archived: i > config.groupCount * 0.8, // Archive last 20%
      ));
    }

    return groups;
  }

  /// Benchmarks saving groups
  Future<BenchmarkResult> _benchmarkSaveGroups(
      List<ExpenseGroup> groups, BenchmarkConfig config) async {
    final durations = <Duration>[];

    for (int i = 0; i < config.iterations; i++) {
      // Clear data between iterations
      for (final group in groups) {
        await repository.deleteGroup(group.id);
      }

      final stopwatch = Stopwatch()..start();

      for (final group in groups) {
        final result = await repository.saveGroup(group);
        if (result.isFailure) {
          throw Exception('Failed to save group: ${result.error}');
        }
      }

      stopwatch.stop();
      durations.add(stopwatch.elapsed);
    }

    return BenchmarkResult(
      operation: 'saveGroups',
      durations: durations,
      config: config,
      metadata: {'groupsSaved': groups.length},
    );
  }

  /// Benchmarks loading all groups
  Future<BenchmarkResult> _benchmarkLoadAllGroups(BenchmarkConfig config) async {
    final durations = <Duration>[];

    for (int i = 0; i < config.iterations; i++) {
      // Clear cache if caching is disabled for this test
      if (!config.enableCaching && repository is FileBasedExpenseGroupRepository) {
        (repository as FileBasedExpenseGroupRepository).clearCache();
      }

      final stopwatch = Stopwatch()..start();

      final result = await repository.getAllGroups();
      if (result.isFailure) {
        throw Exception('Failed to load groups: ${result.error}');
      }

      stopwatch.stop();
      durations.add(stopwatch.elapsed);
    }

    return BenchmarkResult(
      operation: 'loadAllGroups',
      durations: durations,
      config: config,
    );
  }

  /// Benchmarks loading groups by ID
  Future<BenchmarkResult> _benchmarkLoadGroupsById(
      List<ExpenseGroup> groups, BenchmarkConfig config) async {
    final durations = <Duration>[];

    for (int i = 0; i < config.iterations; i++) {
      final stopwatch = Stopwatch()..start();

      for (final group in groups) {
        final result = await repository.getGroupById(group.id);
        if (result.isFailure) {
          throw Exception('Failed to load group: ${result.error}');
        }
      }

      stopwatch.stop();
      durations.add(stopwatch.elapsed);
    }

    return BenchmarkResult(
      operation: 'loadGroupsById',
      durations: durations,
      config: config,
      metadata: {'groupsLoaded': groups.length},
    );
  }

  /// Benchmarks filter operations
  Future<BenchmarkResult> _benchmarkFilterOperations(BenchmarkConfig config) async {
    final durations = <Duration>[];

    for (int i = 0; i < config.iterations; i++) {
      final stopwatch = Stopwatch()..start();

      await repository.getActiveGroups();
      await repository.getArchivedGroups();
      await repository.getPinnedGroup();

      stopwatch.stop();
      durations.add(stopwatch.elapsed);
    }

    return BenchmarkResult(
      operation: 'filterOperations',
      durations: durations,
      config: config,
    );
  }

  /// Benchmarks pin operations
  Future<BenchmarkResult> _benchmarkPinOperations(
      List<ExpenseGroup> groups, BenchmarkConfig config) async {
    final durations = <Duration>[];
    final testGroupIds = groups.take(5).map((g) => g.id).toList();

    for (int i = 0; i < config.iterations; i++) {
      final stopwatch = Stopwatch()..start();

      for (final groupId in testGroupIds) {
        await repository.setPinnedGroup(groupId);
        await repository.removePinnedGroup(groupId);
      }

      stopwatch.stop();
      durations.add(stopwatch.elapsed);
    }

    return BenchmarkResult(
      operation: 'pinOperations',
      durations: durations,
      config: config,
      metadata: {'operationsPerIteration': testGroupIds.length * 2},
    );
  }

  /// Benchmarks search operations
  Future<BenchmarkResult> _benchmarkSearchOperations(BenchmarkConfig config) async {
    final durations = <Duration>[];

    for (int i = 0; i < config.iterations; i++) {
      final stopwatch = Stopwatch()..start();

      // Simulate various data integrity checks
      final integrityResult = await repository.checkDataIntegrity();
      if (integrityResult.isFailure) {
        throw Exception('Data integrity check failed: ${integrityResult.error}');
      }

      stopwatch.stop();
      durations.add(stopwatch.elapsed);
    }

    return BenchmarkResult(
      operation: 'dataIntegrityCheck',
      durations: durations,
      config: config,
    );
  }

  /// Benchmarks transaction operations
  Future<BenchmarkResult> _benchmarkTransactionOperations(
      List<ExpenseGroup> groups, BenchmarkConfig config) async {
    final durations = <Duration>[];
    final testGroups = groups.take(3).toList();

    for (int i = 0; i < config.iterations; i++) {
      final stopwatch = Stopwatch()..start();

      // Perform a complex transaction
      await repository.executeTransaction((tx) {
        for (final group in testGroups) {
          tx.saveGroup(group.copyWith(title: '${group.title} - Updated $i'));
        }
        tx.setPinnedGroup(testGroups.first.id);
        if (testGroups.length > 1) {
          tx.archiveGroup(testGroups.last.id);
        }
      });

      stopwatch.stop();
      durations.add(stopwatch.elapsed);
    }

    return BenchmarkResult(
      operation: 'transactionOperations',
      durations: durations,
      config: config,
      metadata: {'operationsPerTransaction': testGroups.length + 2},
    );
  }

  /// Prints benchmark results
  static void printResults(List<BenchmarkResult> results) {
    print('\n=== Storage Benchmark Results ===');
    
    for (final result in results) {
      print('');
      print('${result.operation}:');
      print('  Iterations: ${result.durations.length}');
      print('  Average: ${result.averageDuration.inMilliseconds}ms');
      print('  Min: ${result.minDuration.inMilliseconds}ms');
      print('  Max: ${result.maxDuration.inMilliseconds}ms');
      print('  P50: ${result.p50Duration.inMilliseconds}ms');
      print('  P95: ${result.p95Duration.inMilliseconds}ms');
      print('  P99: ${result.p99Duration.inMilliseconds}ms');
      print('  Std Dev: ${result.standardDeviation.toStringAsFixed(1)}μs');
      
      if (result.metadata.isNotEmpty) {
        print('  Metadata: ${result.metadata}');
      }
    }
    
    print('\n=== Summary ===');
    final totalOperations = results.length;
    final avgDuration = results
        .map((r) => r.averageDuration.inMilliseconds)
        .reduce((a, b) => a + b) / totalOperations;
    
    print('Total operations: $totalOperations');
    print('Average duration across all operations: ${avgDuration.toStringAsFixed(1)}ms');
    
    // Find slowest operation
    final slowest = results.reduce((a, b) =>
        a.averageDuration > b.averageDuration ? a : b);
    print('Slowest operation: ${slowest.operation} (${slowest.averageDuration.inMilliseconds}ms)');
    
    // Find fastest operation
    final fastest = results.reduce((a, b) =>
        a.averageDuration < b.averageDuration ? a : b);
    print('Fastest operation: ${fastest.operation} (${fastest.averageDuration.inMilliseconds}ms)');
  }
}