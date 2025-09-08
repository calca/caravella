# Performance Best Practices for Large Datasets

This document outlines the performance optimizations implemented in the Caravella app to handle large datasets efficiently.

## Overview

The performance optimization system consists of multiple layers working together:

1. **Storage Cache Layer** - In-memory caching with TTL support
2. **Pagination System** - Chunked data loading to reduce memory usage
3. **Index Optimization** - Fast O(1) lookups for filtering operations
4. **Memory Monitoring** - Real-time tracking and leak detection
5. **Performance Metrics** - Comprehensive monitoring and reporting

## Core Components

### 1. StorageCache

The `StorageCache` class provides a high-performance caching layer:

```dart
// Basic usage
StorageCache.set('key', data, ttl: Duration(minutes: 5));
final cached = StorageCache.get<DataType>('key');

// With automatic cache management
class MyRepository with CacheableStorage {
  Future<Data> loadData() {
    return cachedOperation(
      'loadData',
      () => _actualLoadOperation(),
      ttl: Duration(minutes: 2),
    );
  }
}
```

**Features:**
- Automatic TTL-based expiration
- Memory management (max 100 entries)
- LRU eviction when cache is full
- Hit/miss rate tracking
- Size estimation for memory monitoring

### 2. Pagination Support

All repository methods now support pagination to handle large datasets:

```dart
// Load first 20 groups
final result = await repository.getAllGroupsPaginated(limit: 20, offset: 0);

// Load next 20 groups
final nextResult = await repository.getAllGroupsPaginated(limit: 20, offset: 20);
```

**Available Paginated Methods:**
- `getAllGroupsPaginated({int? limit, int? offset})`
- `getActiveGroupsPaginated({int? limit, int? offset})`
- `getArchivedGroupsPaginated({int? limit, int? offset})`

### 3. Enhanced Index System

The index system provides fast lookups and filtering:

```dart
// O(1) group lookup by ID
final group = groupIndex.getById('group-id');

// Paginated filtering
final activeGroups = groupIndex.getActiveGroups(limit: 10, offset: 0);

// Search with pagination
final searchResults = groupIndex.searchByTitle('vacation', limit: 5);
```

**Index Features:**
- Hash-based O(1) lookups
- Set-based filtering for active/archived groups
- Pagination support in all operations
- Consistency validation
- Statistics tracking

### 4. Memory Monitoring

The `MemoryMonitor` tracks memory usage and detects potential leaks:

```dart
// Enable monitoring
MemoryMonitor.enable();

// Automatic monitoring in repositories
class MyRepository with MemoryMonitoring {
  Future<Data> operation() {
    return measureMemoryUsage(
      'operationName',
      () => _doOperation(),
      metadata: {'param': 'value'},
    );
  }
}

// Check for memory leaks
final leaks = MemoryMonitor.detectMemoryLeaks();
```

### 5. Performance Metrics

Comprehensive performance tracking across all operations:

```dart
// Enable performance monitoring
StoragePerformanceMonitor.enable();

// Get performance summary
final summary = StoragePerformanceMonitor.getSummary();

// Repository integration
final repository = FileBasedExpenseGroupRepository();
repository.initializePerformanceOptimizations();

final metrics = repository.getPerformanceMetrics();
// Returns: storage, cache, memory, and index statistics
```

## Usage Guidelines

### 1. Initialize Performance Optimizations

```dart
final repository = FileBasedExpenseGroupRepository();
repository.initializePerformanceOptimizations();

// Use repository...

// Cleanup when done
repository.cleanupPerformanceOptimizations();
```

### 2. Use Pagination for Large Datasets

When working with large datasets, always use pagination:

```dart
// Good: Paginated loading
const pageSize = 20;
var offset = 0;

while (true) {
  final result = await repository.getAllGroupsPaginated(
    limit: pageSize,
    offset: offset,
  );
  
  if (result.data!.isEmpty) break;
  
  // Process page
  processBatch(result.data!);
  offset += pageSize;
}

// Avoid: Loading all data at once for large datasets
final allGroups = await repository.getAllGroups(); // Can be memory-intensive
```

### 3. Monitor Performance

Regular performance monitoring helps identify bottlenecks:

```dart
// Print performance report
repository.printPerformanceReport();

// Get specific metrics
final cacheStats = StorageCache.getStats();
print('Cache hit rate: ${cacheStats['hitRate']}%');

final memoryStats = MemoryMonitor.getMemoryStats();
final leaks = MemoryMonitor.detectMemoryLeaks();
```

### 4. Cache Management

Optimize cache usage for your use case:

```dart
// Short-lived data
StorageCache.set('temp_data', data, ttl: Duration(seconds: 30));

// Long-lived reference data
StorageCache.set('categories', categories, ttl: Duration(hours: 1));

// Clear cache when data changes
StorageCache.remove('stale_key');

// Batch cache invalidation
invalidateCache(['key1', 'key2', 'key3']);
```

## Performance Tuning

### 1. Cache Configuration

Adjust cache settings based on your needs:

```dart
// In StorageCache class, modify these constants:
static const int _maxCacheSize = 100; // Increase for more caching
static const Duration _defaultTtl = Duration(minutes: 5); // Adjust TTL
```

### 2. Pagination Size

Choose appropriate page sizes:

```dart
// For UI lists (responsive)
const uiPageSize = 20;

// For background processing (efficient)
const batchSize = 100;

// For memory-constrained environments
const smallPageSize = 10;
```

### 3. Index Optimization

Keep indexes fresh for best performance:

```dart
// Rebuild indexes after bulk operations
groupIndex.rebuild(allGroups);

// Check index consistency
final issues = groupIndex.validateConsistency();
if (issues.isNotEmpty) {
  // Handle inconsistencies
  groupIndex.rebuild(allGroups);
}
```

## Best Practices

### 1. Memory Management

- **Use pagination** for datasets larger than 50 items
- **Monitor memory usage** in production environments
- **Clear caches** when memory is constrained
- **Avoid loading all data** unless absolutely necessary

### 2. Cache Strategy

- **Cache frequently accessed data** with appropriate TTL
- **Invalidate caches** when underlying data changes
- **Use custom TTL** for different data types
- **Monitor hit rates** to optimize cache effectiveness

### 3. Performance Monitoring

- **Enable monitoring** in development and staging
- **Track key metrics**: cache hit rate, memory usage, operation duration
- **Set up alerts** for performance degradation
- **Regular performance reviews** to identify optimization opportunities

### 4. Error Handling

- **Graceful degradation** when cache is unavailable
- **Fallback to full scan** when indexes are inconsistent
- **Timeout handling** for long-running operations
- **Memory pressure handling** with automatic cache eviction

## Troubleshooting

### Performance Issues

1. **Slow loading times**:
   - Check cache hit rates
   - Verify index usage
   - Consider pagination
   - Monitor memory usage

2. **High memory usage**:
   - Enable memory monitoring
   - Check for memory leaks
   - Reduce cache size
   - Implement more aggressive eviction

3. **Cache misses**:
   - Verify TTL settings
   - Check cache invalidation logic
   - Monitor cache size limits
   - Review access patterns

### Debugging Tools

```dart
// Performance report
repository.printPerformanceReport();

// Cache analysis
StorageCache.printStats();

// Memory analysis
MemoryMonitor.printStats();

// Index validation
final issues = groupIndex.validateConsistency();
```

## Migration Guide

To upgrade existing code to use the new performance optimizations:

### 1. Update Repository Usage

```dart
// Before
final groups = await repository.getAllGroups();

// After
final groups = await repository.getAllGroupsPaginated(limit: 20, offset: 0);
```

### 2. Initialize Performance Features

```dart
// Add to app initialization
final repository = FileBasedExpenseGroupRepository();
repository.initializePerformanceOptimizations();
```

### 3. Update Error Handling

```dart
// Handle potential cache-related errors
try {
  final result = await repository.getAllGroups();
  // Process result
} catch (e) {
  // Fallback to non-cached operation if needed
  StorageCache.clear();
  final result = await repository.getAllGroups();
}
```

## Conclusion

These performance optimizations provide a solid foundation for handling large datasets efficiently. The combination of caching, pagination, indexing, and monitoring ensures smooth user experience even with substantial amounts of data.

Key benefits:
- **Reduced memory usage** through pagination
- **Faster operations** through caching and indexing
- **Proactive monitoring** to prevent performance degradation
- **Scalable architecture** that grows with data size

Regular monitoring and tuning based on actual usage patterns will help maintain optimal performance as the application scales.