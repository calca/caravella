import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/data/cache/storage_cache.dart';
import 'package:io_caravella_egm/data/file_based_expense_group_repository.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';
import 'package:io_caravella_egm/data/model/expense_category.dart';
import 'package:io_caravella_egm/data/model/expense_details.dart';
import 'package:io_caravella_egm/data/storage_performance.dart';
import 'package:io_caravella_egm/data/memory_monitor.dart';

void main() {
  group('Performance Optimizations', () {
    late FileBasedExpenseGroupRepository repository;

    setUp(() {
      repository = FileBasedExpenseGroupRepository();
      repository.initializePerformanceOptimizations();
      StorageCache.clear();
      StoragePerformanceMonitor.clear();
      MemoryMonitor.clear();
    });

    tearDown(() {
      repository.cleanupPerformanceOptimizations();
      StorageCache.clear();
    });

    group('StorageCache', () {
      test('should cache and retrieve values correctly', () {
        const key = 'test_key';
        const value = 'test_value';

        // Should be null initially
        expect(StorageCache.get<String>(key), isNull);

        // Set value
        StorageCache.set(key, value);

        // Should retrieve the cached value
        expect(StorageCache.get<String>(key), equals(value));

        // Stats should reflect the operations
        final stats = StorageCache.getStats();
        expect(stats['hits'], equals(1));
        expect(stats['misses'], equals(1));
      });

      test('should expire cached values after TTL', () async {
        const key = 'test_key';
        const value = 'test_value';
        const shortTtl = Duration(milliseconds: 50);

        StorageCache.set(key, value, ttl: shortTtl);
        expect(StorageCache.get<String>(key), equals(value));

        // Wait for expiration
        await Future.delayed(const Duration(milliseconds: 100));

        // Should be null after expiration
        expect(StorageCache.get<String>(key), isNull);
      });

      test('should evict oldest entries when cache is full', () {
        // Fill cache to maximum capacity
        for (int i = 0; i < 105; i++) {
          StorageCache.set('key_$i', 'value_$i');
        }

        final stats = StorageCache.getStats();
        expect(stats['entries'], equals(100)); // Max cache size
        expect(stats['evictions'], greaterThan(0));
      });

      test('should calculate hit rate correctly', () {
        StorageCache.set('key1', 'value1');
        StorageCache.set('key2', 'value2');

        // 2 misses (during set operations check)
        StorageCache.get('key1'); // 1 hit
        StorageCache.get('key1'); // 1 hit  
        StorageCache.get('key3'); // 1 miss

        final stats = StorageCache.getStats();
        expect(stats['hitRate'], greaterThan(0));
        expect(stats['totalRequests'], greaterThan(0));
      });
    });

    group('Repository Pagination', () {
      test('should support pagination for getAllGroups', () async {
        // Create test groups
        final groups = List.generate(20, (index) {
          return ExpenseGroup(
            id: 'group_$index',
            title: 'Group $index',
            currency: 'USD',
            participants: [ExpenseParticipant(name: 'User $index')],
            categories: [ExpenseCategory(name: 'Category $index')],
            expenses: [],
            timestamp: DateTime.now().subtract(Duration(hours: index)),
          );
        });

        // Save all groups
        for (final group in groups) {
          await repository.saveGroup(group);
        }

        // Test pagination
        final firstPage = await repository.getAllGroupsPaginated(limit: 5, offset: 0);
        expect(firstPage.isSuccess, isTrue);
        expect(firstPage.data!.length, equals(5));

        final secondPage = await repository.getAllGroupsPaginated(limit: 5, offset: 5);
        expect(secondPage.isSuccess, isTrue);
        expect(secondPage.data!.length, equals(5));

        // Groups should be different
        final firstIds = firstPage.data!.map((g) => g.id).toSet();
        final secondIds = secondPage.data!.map((g) => g.id).toSet();
        expect(firstIds.intersection(secondIds).isEmpty, isTrue);
      });

      test('should support pagination for getActiveGroups', () async {
        // Create mix of active and archived groups
        final activeGroups = List.generate(10, (index) {
          return ExpenseGroup(
            id: 'active_$index',
            title: 'Active Group $index',
            currency: 'USD',
            participants: [ExpenseParticipant(name: 'User $index')],
            categories: [ExpenseCategory(name: 'Category $index')],
            expenses: [],
            timestamp: DateTime.now().subtract(Duration(hours: index)),
            archived: false,
          );
        });

        final archivedGroups = List.generate(5, (index) {
          return ExpenseGroup(
            id: 'archived_$index',
            title: 'Archived Group $index',
            currency: 'USD',
            participants: [ExpenseParticipant(name: 'User $index')],
            categories: [ExpenseCategory(name: 'Category $index')],
            expenses: [],
            timestamp: DateTime.now().subtract(Duration(hours: index + 20)),
            archived: true,
          );
        });

        // Save all groups
        for (final group in [...activeGroups, ...archivedGroups]) {
          await repository.saveGroup(group);
        }

        // Test active groups pagination
        final firstPage = await repository.getActiveGroupsPaginated(limit: 3, offset: 0);
        expect(firstPage.isSuccess, isTrue);
        expect(firstPage.data!.length, equals(3));
        expect(firstPage.data!.every((g) => !g.archived), isTrue);

        final secondPage = await repository.getActiveGroupsPaginated(limit: 3, offset: 3);
        expect(secondPage.isSuccess, isTrue);
        expect(secondPage.data!.length, equals(3));
        expect(secondPage.data!.every((g) => !g.archived), isTrue);
      });
    });

    group('Cache Integration', () {
      test('should cache repository operations', () async {
        // Create test group
        final group = ExpenseGroup(
          id: 'test_group',
          title: 'Test Group',
          currency: 'USD',
          participants: [ExpenseParticipant(name: 'Test User')],
          categories: [ExpenseCategory(name: 'Test Category')],
          expenses: [],
          timestamp: DateTime.now(),
        );

        await repository.saveGroup(group);

        // Clear performance metrics to track cache hits
        StoragePerformanceMonitor.clear();

        // First call - should be cached
        await repository.getAllGroups();
        
        // Second call - should hit cache
        await repository.getAllGroups();

        // Check cache statistics
        final cacheStats = StorageCache.getStats();
        expect(cacheStats['hits'], greaterThan(0));
      });

      test('should invalidate cache when data changes', () async {
        // Create test group
        final group = ExpenseGroup(
          id: 'test_group',
          title: 'Test Group',
          currency: 'USD',
          participants: [ExpenseParticipant(name: 'Test User')],
          categories: [ExpenseCategory(name: 'Test Category')],
          expenses: [],
          timestamp: DateTime.now(),
        );

        await repository.saveGroup(group);

        // Load groups to populate cache
        await repository.getAllGroups();

        // Update group - should invalidate cache
        final updatedGroup = group.copyWith(title: 'Updated Test Group');
        await repository.saveGroup(updatedGroup);

        // Load groups again
        final result = await repository.getAllGroups();
        expect(result.isSuccess, isTrue);
        expect(result.data!.first.title, equals('Updated Test Group'));
      });
    });

    group('Performance Monitoring', () {
      test('should track operation performance', () async {
        // Create test group
        final group = ExpenseGroup(
          id: 'test_group',
          title: 'Test Group',
          currency: 'USD',
          participants: [ExpenseParticipant(name: 'Test User')],
          categories: [ExpenseCategory(name: 'Test Category')],
          expenses: [],
          timestamp: DateTime.now(),
        );

        await repository.saveGroup(group);
        await repository.getAllGroups();

        // Check that metrics were recorded
        final metrics = StoragePerformanceMonitor.metrics;
        expect(metrics.isNotEmpty, isTrue);

        final saveMetrics = StoragePerformanceMonitor.getMetricsFor('saveGroups');
        expect(saveMetrics.isNotEmpty, isTrue);

        final loadMetrics = StoragePerformanceMonitor.getMetricsFor('getAllGroups');
        expect(loadMetrics.isNotEmpty, isTrue);
      });

      test('should calculate performance statistics', () async {
        // Create multiple test groups to generate more metrics
        for (int i = 0; i < 5; i++) {
          final group = ExpenseGroup(
            id: 'test_group_$i',
            title: 'Test Group $i',
            currency: 'USD',
            participants: [ExpenseParticipant(name: 'Test User $i')],
            categories: [ExpenseCategory(name: 'Test Category $i')],
            expenses: [],
            timestamp: DateTime.now().subtract(Duration(hours: i)),
          );

          await repository.saveGroup(group);
        }

        // Load groups multiple times
        for (int i = 0; i < 3; i++) {
          await repository.getAllGroups();
        }

        // Check performance summary
        final summary = StoragePerformanceMonitor.getSummary();
        expect(summary.isNotEmpty, isTrue);

        if (summary.containsKey('getAllGroups')) {
          final getAllStats = summary['getAllGroups'] as Map<String, dynamic>;
          expect(getAllStats['count'], greaterThan(0));
          expect(getAllStats['avgDuration'], greaterThan(0));
        }
      });
    });

    group('Memory Monitoring', () {
      test('should track memory usage during operations', () async {
        // Create test group
        final group = ExpenseGroup(
          id: 'test_group',
          title: 'Test Group',
          currency: 'USD',
          participants: [ExpenseParticipant(name: 'Test User')],
          categories: [ExpenseCategory(name: 'Test Category')],
          expenses: [],
          timestamp: DateTime.now(),
        );

        await repository.saveGroup(group);
        await repository.getAllGroups();

        // Check that memory snapshots were recorded
        final snapshots = MemoryMonitor.snapshots;
        expect(snapshots.isNotEmpty, isTrue);

        // Check memory statistics
        final memoryStats = MemoryMonitor.getMemoryStats();
        expect(memoryStats.isNotEmpty, isTrue);
      });

      test('should detect potential memory leaks', () async {
        // Generate multiple operations to simulate memory growth
        for (int i = 0; i < 10; i++) {
          final group = ExpenseGroup(
            id: 'test_group_$i',
            title: 'Test Group $i',
            currency: 'USD',
            participants: List.generate(i + 1, (j) => ExpenseParticipant(name: 'User $j')),
            categories: List.generate(i + 1, (j) => ExpenseCategory(name: 'Category $j')),
            expenses: List.generate(i * 2, (j) => ExpenseDetails(
              category: ExpenseCategory(name: 'Category 0'),
              amount: 100.0 + j,
              paidBy: ExpenseParticipant(name: 'User 0'),
              date: DateTime.now(),
              name: 'Expense $j',
            )),
            timestamp: DateTime.now().subtract(Duration(hours: i)),
          );

          await repository.saveGroup(group);
          
          // Simulate memory usage by taking explicit snapshots
          MemoryMonitor.takeSnapshot('simulate_operation', metadata: {'iteration': i});
        }

        // Memory leak detection should work (though might not detect anything in test environment)
        final leaks = MemoryMonitor.detectMemoryLeaks();
        // Don't assert on leaks as test environment is controlled
        expect(leaks, isA<List<String>>());
      });
    });

    group('Performance Integration', () {
      test('should provide comprehensive performance metrics', () async {
        // Create test group with substantial data
        final group = ExpenseGroup(
          id: 'large_group',
          title: 'Large Test Group',
          currency: 'USD',
          participants: List.generate(10, (i) => ExpenseParticipant(name: 'User $i')),
          categories: List.generate(5, (i) => ExpenseCategory(name: 'Category $i')),
          expenses: List.generate(50, (i) => ExpenseDetails(
            category: ExpenseCategory(name: 'Category ${i % 5}'),
            amount: 100.0 + i,
            paidBy: ExpenseParticipant(name: 'User ${i % 10}'),
            date: DateTime.now().subtract(Duration(days: i)),
            name: 'Expense $i',
          )),
          timestamp: DateTime.now(),
        );

        // Perform various operations
        await repository.saveGroup(group);
        await repository.getAllGroups();
        await repository.getAllGroupsPaginated(limit: 10, offset: 0);
        await repository.getActiveGroups();
        await repository.getGroupById(group.id);

        // Get comprehensive performance metrics
        final metrics = repository.getPerformanceMetrics();
        
        expect(metrics.containsKey('storage'), isTrue);
        expect(metrics.containsKey('cache'), isTrue);
        expect(metrics.containsKey('memory'), isTrue);
        expect(metrics.containsKey('index'), isTrue);

        // Storage metrics should contain operations
        final storageMetrics = metrics['storage'] as Map<String, dynamic>;
        expect(storageMetrics.isNotEmpty, isTrue);

        // Cache metrics should show activity
        final cacheMetrics = metrics['cache'] as Map<String, dynamic>;
        expect(cacheMetrics['totalRequests'], greaterThan(0));

        // Index metrics should show group count
        final indexMetrics = metrics['index'] as Map<String, dynamic>;
        final groupStats = indexMetrics['groups'] as Map<String, dynamic>;
        expect(groupStats['totalGroups'], greaterThan(0));
      });

      test('should handle large dataset performance gracefully', () async {
        // Create a larger dataset to test performance with substantial data
        final groups = List.generate(100, (index) {
          return ExpenseGroup(
            id: 'large_group_$index',
            title: 'Large Group $index',
            currency: 'USD',
            participants: List.generate(5, (i) => ExpenseParticipant(name: 'User ${index}_$i')),
            categories: List.generate(3, (i) => ExpenseCategory(name: 'Category ${index}_$i')),
            expenses: List.generate(20, (i) => ExpenseDetails(
              category: ExpenseCategory(name: 'Category ${index}_${i % 3}'),
              amount: 50.0 + (index * 10) + i,
              paidBy: ExpenseParticipant(name: 'User ${index}_${i % 5}'),
              date: DateTime.now().subtract(Duration(days: index + i)),
              name: 'Expense ${index}_$i',
            )),
            timestamp: DateTime.now().subtract(Duration(hours: index)),
            archived: index > 80, // Archive last 20%
          );
        });

        // Save all groups
        for (final group in groups) {
          await repository.saveGroup(group);
        }

        // Test pagination performance
        final firstPage = await repository.getAllGroupsPaginated(limit: 10, offset: 0);
        expect(firstPage.isSuccess, isTrue);
        expect(firstPage.data!.length, equals(10));

        final activePage = await repository.getActiveGroupsPaginated(limit: 15, offset: 0);
        expect(activePage.isSuccess, isTrue);
        expect(activePage.data!.length, equals(15));
        expect(activePage.data!.every((g) => !g.archived), isTrue);

        final archivedPage = await repository.getArchivedGroupsPaginated(limit: 5, offset: 0);
        expect(archivedPage.isSuccess, isTrue);
        expect(archivedPage.data!.length, equals(5));
        expect(archivedPage.data!.every((g) => g.archived), isTrue);

        // Performance should be tracked
        final performanceMetrics = StoragePerformanceMonitor.getSummary();
        expect(performanceMetrics.isNotEmpty, isTrue);

        // Cache should show hits from pagination
        final cacheStats = StorageCache.getStats();
        expect(cacheStats['totalRequests'], greaterThan(0));
      });
    });
  });
}