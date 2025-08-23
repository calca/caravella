import 'package:flutter/foundation.dart';
import 'model/expense_participant.dart';
import 'expense_group_repository.dart';

/// Service for participant operations with caching and search capabilities
class ParticipantService extends ChangeNotifier {
  final IExpenseGroupRepository _repository;
  
  List<ExpenseParticipant>? _cachedParticipants;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  ParticipantService(this._repository);

  /// Gets all participants from all groups with caching
  Future<List<ExpenseParticipant>> getAllParticipants() async {
    if (_isCacheValid()) {
      return _cachedParticipants!;
    }

    final result = await _repository.getAllParticipants();
    if (result.isSuccess) {
      _cachedParticipants = result.data!;
      _lastCacheUpdate = DateTime.now();
      notifyListeners();
      return _cachedParticipants!;
    } else {
      debugPrint('Failed to load participants: ${result.error}');
      return _cachedParticipants ?? [];
    }
  }

  /// Searches participants by name with caching
  Future<List<ExpenseParticipant>> searchParticipants(String query) async {
    // For empty query, return all participants
    if (query.trim().isEmpty) {
      return getAllParticipants();
    }

    // Use repository search if cache is invalid or we don't have cached data
    if (!_isCacheValid()) {
      final result = await _repository.searchParticipants(query);
      if (result.isSuccess) {
        return result.data!;
      } else {
        debugPrint('Failed to search participants: ${result.error}');
        return [];
      }
    }

    // Search in cached participants
    final lowerQuery = query.toLowerCase();
    return _cachedParticipants!
        .where((participant) => participant.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Gets filtered participant suggestions for autocomplete
  Future<List<ExpenseParticipant>> getParticipantSuggestions(String query, {int limit = 10}) async {
    final participants = await searchParticipants(query);
    
    // Prioritize exact matches, then prefix matches, then contains matches
    final exactMatches = <ExpenseParticipant>[];
    final prefixMatches = <ExpenseParticipant>[];
    final containsMatches = <ExpenseParticipant>[];
    
    final lowerQuery = query.toLowerCase();
    
    for (final participant in participants) {
      final lowerName = participant.name.toLowerCase();
      if (lowerName == lowerQuery) {
        exactMatches.add(participant);
      } else if (lowerName.startsWith(lowerQuery)) {
        prefixMatches.add(participant);
      } else {
        containsMatches.add(participant);
      }
    }
    
    // Combine results with priority ordering
    final suggestions = <ExpenseParticipant>[];
    suggestions.addAll(exactMatches);
    suggestions.addAll(prefixMatches);
    suggestions.addAll(containsMatches);
    
    return suggestions.take(limit).toList();
  }

  /// Finds existing participant by name (case-insensitive) for UUID reuse
  Future<ExpenseParticipant?> findParticipantByName(String name) async {
    final participants = await getAllParticipants();
    
    final lowerName = name.toLowerCase();
    for (final participant in participants) {
      if (participant.name.toLowerCase() == lowerName) {
        return participant;
      }
    }
    
    return null;
  }

  /// Creates a new participant, reusing UUID if a participant with the same name exists
  Future<ExpenseParticipant> createOrReuseParticipant(String name) async {
    final existing = await findParticipantByName(name);
    
    if (existing != null) {
      // Reuse the existing participant's UUID but update creation date
      return ExpenseParticipant(
        id: existing.id, // Reuse UUID
        name: name, // Use the new name (preserves casing)
        createdAt: DateTime.now(),
      );
    }
    
    // Create a new participant with a new UUID
    return ExpenseParticipant(
      name: name,
      createdAt: DateTime.now(),
    );
  }

  /// Invalidates the cache (call when participants are modified)
  void invalidateCache() {
    _cachedParticipants = null;
    _lastCacheUpdate = null;
    notifyListeners();
  }

  /// Checks if the cache is still valid
  bool _isCacheValid() {
    if (_cachedParticipants == null || _lastCacheUpdate == null) {
      return false;
    }
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  /// Returns whether participants are currently cached
  bool get hasCachedParticipants => _cachedParticipants != null;

  /// Returns the number of cached participants
  int get cachedParticipantCount => _cachedParticipants?.length ?? 0;
}