import 'package:flutter/foundation.dart';
import 'model/expense_category.dart';
import 'expense_group_repository.dart';

/// Service for category operations with caching and search capabilities
class CategoryService extends ChangeNotifier {
  final IExpenseGroupRepository _repository;
  
  List<ExpenseCategory>? _cachedCategories;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  CategoryService(this._repository);

  /// Gets all categories from all groups with caching
  Future<List<ExpenseCategory>> getAllCategories() async {
    if (_isCacheValid()) {
      return _cachedCategories!;
    }

    final result = await _repository.getAllCategories();
    if (result.isSuccess) {
      _cachedCategories = result.data!;
      _lastCacheUpdate = DateTime.now();
      notifyListeners();
      return _cachedCategories!;
    } else {
      debugPrint('Failed to load categories: ${result.error}');
      return _cachedCategories ?? [];
    }
  }

  /// Searches categories by name with caching
  Future<List<ExpenseCategory>> searchCategories(String query) async {
    // For empty query, return all categories
    if (query.trim().isEmpty) {
      return getAllCategories();
    }

    // Use repository search if cache is invalid or we don't have cached data
    if (!_isCacheValid()) {
      final result = await _repository.searchCategories(query);
      if (result.isSuccess) {
        return result.data!;
      } else {
        debugPrint('Failed to search categories: ${result.error}');
        return [];
      }
    }

    // Search in cached categories
    final lowerQuery = query.toLowerCase();
    return _cachedCategories!
        .where((category) => category.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Gets filtered category suggestions for autocomplete
  Future<List<ExpenseCategory>> getCategorySuggestions(String query, {int limit = 10}) async {
    final categories = await searchCategories(query);
    
    // Prioritize exact matches, then prefix matches, then contains matches
    final exactMatches = <ExpenseCategory>[];
    final prefixMatches = <ExpenseCategory>[];
    final containsMatches = <ExpenseCategory>[];
    
    final lowerQuery = query.toLowerCase();
    
    for (final category in categories) {
      final lowerName = category.name.toLowerCase();
      if (lowerName == lowerQuery) {
        exactMatches.add(category);
      } else if (lowerName.startsWith(lowerQuery)) {
        prefixMatches.add(category);
      } else {
        containsMatches.add(category);
      }
    }
    
    // Combine results with priority ordering
    final suggestions = <ExpenseCategory>[];
    suggestions.addAll(exactMatches);
    suggestions.addAll(prefixMatches);
    suggestions.addAll(containsMatches);
    
    return suggestions.take(limit).toList();
  }

  /// Invalidates the cache (call when categories are modified)
  void invalidateCache() {
    _cachedCategories = null;
    _lastCacheUpdate = null;
    notifyListeners();
  }

  /// Checks if the cache is still valid
  bool _isCacheValid() {
    if (_cachedCategories == null || _lastCacheUpdate == null) {
      return false;
    }
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  /// Returns whether categories are currently cached
  bool get hasCachedCategories => _cachedCategories != null;

  /// Returns the number of cached categories
  int get cachedCategoryCount => _cachedCategories?.length ?? 0;
}