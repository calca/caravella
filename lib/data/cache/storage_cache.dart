import 'dart:async';
import '../services/logger_service.dart';

/// Generic cache layer for storage operations
class StorageCache {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _timestamps = {};
  static final Map<String, Duration> _customTtl = {};
  static const Duration _defaultTtl = Duration(minutes: 5);
  
  /// Maximum cache size to prevent memory issues
  static const int _maxCacheSize = 100;
  
  /// Cache statistics
  static int _hits = 0;
  static int _misses = 0;
  static int _evictions = 0;
  
  /// Gets a cached value if still valid
  static T? get<T>(String key) {
    final timestamp = _timestamps[key];
    if (timestamp == null) {
      _misses++;
      return null;
    }
    
    final ttl = _customTtl[key] ?? _defaultTtl;
    if (DateTime.now().difference(timestamp) > ttl) {
      remove(key);
      _misses++;
      return null;
    }
    
    _hits++;
    return _cache[key] as T?;
  }
  
  /// Sets a cached value with optional custom TTL
  static void set<T>(String key, T value, {Duration? ttl}) {
    // Check if we need to evict old entries
    if (_cache.length >= _maxCacheSize) {
      _evictOldest();
    }
    
    _cache[key] = value;
    _timestamps[key] = DateTime.now();
    
    if (ttl != null) {
      _customTtl[key] = ttl;
    } else {
      _customTtl.remove(key);
    }
    
    LoggerService.debug(
      'Cache set: $key (size: ${_estimateSize(value)} bytes)',
      name: 'storage.cache',
    );
  }
  
  /// Removes a specific key from cache
  static void remove(String key) {
    _cache.remove(key);
    _timestamps.remove(key);
    _customTtl.remove(key);
  }
  
  /// Clears all cached data
  static void clear() {
    _cache.clear();
    _timestamps.clear();
    _customTtl.clear();
    _hits = 0;
    _misses = 0;
    _evictions = 0;
  }
  
  /// Evicts expired entries
  static void evictExpired() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _timestamps.entries) {
      final key = entry.key;
      final timestamp = entry.value;
      final ttl = _customTtl[key] ?? _defaultTtl;
      
      if (now.difference(timestamp) > ttl) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      remove(key);
    }
    
    if (keysToRemove.isNotEmpty) {
      LoggerService.debug(
        'Evicted ${keysToRemove.length} expired cache entries',
        name: 'storage.cache',
      );
    }
  }
  
  /// Evicts the oldest cache entry
  static void _evictOldest() {
    if (_timestamps.isEmpty) return;
    
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _timestamps.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value;
      }
    }
    
    if (oldestKey != null) {
      remove(oldestKey);
      _evictions++;
      LoggerService.debug(
        'Evicted oldest cache entry: $oldestKey',
        name: 'storage.cache',
      );
    }
  }
  
  /// Gets cache statistics
  static Map<String, dynamic> getStats() {
    final totalRequests = _hits + _misses;
    final hitRate = totalRequests > 0 ? (_hits / totalRequests) * 100 : 0.0;
    
    return {
      'entries': _cache.length,
      'maxSize': _maxCacheSize,
      'hits': _hits,
      'misses': _misses,
      'evictions': _evictions,
      'hitRate': hitRate,
      'totalRequests': totalRequests,
      'memoryUsageBytes': _estimateTotalSize(),
    };
  }
  
  /// Checks if a key exists in cache (without affecting hit/miss stats)
  static bool containsKey(String key) {
    return _cache.containsKey(key);
  }
  
  /// Gets all cache keys
  static Set<String> get keys => _cache.keys.toSet();
  
  /// Estimates the size of a cached value in bytes
  static int _estimateSize(dynamic value) {
    if (value == null) return 8;
    if (value is String) return value.length * 2; // UTF-16
    if (value is List) return value.length * 8; // Rough estimate
    if (value is Map) return value.length * 16; // Rough estimate
    return 64; // Default estimate for objects
  }
  
  /// Estimates total cache memory usage
  static int _estimateTotalSize() {
    return _cache.values.map(_estimateSize).fold<int>(0, (sum, size) => sum + size);
  }
  
  /// Prints cache statistics
  static void printStats() {
    final stats = getStats();
    LoggerService.info('=== Storage Cache Statistics ===', name: 'storage.cache');
    LoggerService.info('Entries: ${stats['entries']}/${stats['maxSize']}', name: 'storage.cache');
    LoggerService.info('Hit Rate: ${stats['hitRate'].toStringAsFixed(1)}%', name: 'storage.cache');
    LoggerService.info('Hits: ${stats['hits']}, Misses: ${stats['misses']}', name: 'storage.cache');
    LoggerService.info('Evictions: ${stats['evictions']}', name: 'storage.cache');
    LoggerService.info('Memory Usage: ${(stats['memoryUsageBytes'] / 1024).toStringAsFixed(1)}KB', name: 'storage.cache');
  }
}

/// Mixin to add caching capabilities to repository operations
mixin CacheableStorage {
  /// Cached operation with automatic cache key generation
  Future<T> cachedOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? ttl,
    String? customKey,
  }) async {
    final cacheKey = customKey ?? operationName;
    
    // Try to get from cache first
    final cached = StorageCache.get<T>(cacheKey);
    if (cached != null) {
      LoggerService.debug(
        'Cache hit for $operationName',
        name: 'storage.cache',
      );
      return cached;
    }
    
    // Execute operation and cache result
    final result = await operation();
    StorageCache.set(cacheKey, result, ttl: ttl);
    
    LoggerService.debug(
      'Cache miss for $operationName, result cached',
      name: 'storage.cache',
    );
    
    return result;
  }
  
  /// Synchronous cached operation
  T cachedSyncOperation<T>(
    String operationName,
    T Function() operation, {
    Duration? ttl,
    String? customKey,
  }) {
    final cacheKey = customKey ?? operationName;
    
    // Try to get from cache first
    final cached = StorageCache.get<T>(cacheKey);
    if (cached != null) {
      return cached;
    }
    
    // Execute operation and cache result
    final result = operation();
    StorageCache.set(cacheKey, result, ttl: ttl);
    
    return result;
  }
  
  /// Invalidates cache for specific operations
  void invalidateCache(List<String> keys) {
    for (final key in keys) {
      StorageCache.remove(key);
    }
  }
  
  /// Invalidates all cache entries for this storage instance
  void invalidateAllCache() {
    StorageCache.clear();
  }
}

/// Cache management utilities
class CacheManager {
  static Timer? _cleanupTimer;
  
  /// Starts automatic cache cleanup
  static void startAutomaticCleanup({Duration interval = const Duration(minutes: 1)}) {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(interval, (_) {
      StorageCache.evictExpired();
    });
  }
  
  /// Stops automatic cache cleanup
  static void stopAutomaticCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
  
  /// Performs cache maintenance
  static void performMaintenance() {
    StorageCache.evictExpired();
    final stats = StorageCache.getStats();
    
    LoggerService.debug(
      'Cache maintenance completed. Entries: ${stats['entries']}, Hit rate: ${stats['hitRate'].toStringAsFixed(1)}%',
      name: 'storage.cache',
    );
  }
}