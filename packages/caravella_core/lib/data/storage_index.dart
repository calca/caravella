import '../model/expense_group.dart';

/// Index for fast group lookups
class GroupIndex {
  final Map<String, ExpenseGroup> _byId = {};
  final Set<String> _pinnedGroups = {};
  final Set<String> _archivedGroups = {};
  final Set<String> _activeGroups = {};

  /// Tracks if the index is up-to-date
  bool _isDirty = true;

  /// Last update timestamp
  DateTime? _lastUpdate;

  // Testing hook: when true, skip adding one active group to active set to simulate inconsistency
  bool _testSkipActiveTracking = false;
  void enableTestSkipActiveTracking() => _testSkipActiveTracking = true;
  void disableTestSkipActiveTracking() => _testSkipActiveTracking = false;

  /// Rebuilds the index from a list of groups
  void rebuild(List<ExpenseGroup> groups) {
    _byId.clear();
    _pinnedGroups.clear();
    _archivedGroups.clear();
    _activeGroups.clear();

    for (final group in groups) {
      _byId[group.id] = group;

      if (group.pinned && !group.archived) {
        _pinnedGroups.add(group.id);
      }

      if (group.archived) {
        _archivedGroups.add(group.id);
      } else {
        if (!_testSkipActiveTracking || _activeGroups.isNotEmpty) {
          _activeGroups.add(group.id);
        }
      }
    }

    _isDirty = false;
    _lastUpdate = DateTime.now();
  }

  /// Updates a single group in the index
  void updateGroup(ExpenseGroup group) {
    final oldGroup = _byId[group.id];
    _byId[group.id] = group;

    // Update pin status
    if (oldGroup?.pinned == true && oldGroup?.archived == false) {
      _pinnedGroups.remove(group.id);
    }
    if (group.pinned && !group.archived) {
      _pinnedGroups.add(group.id);
    }

    // Update archive status
    if (oldGroup?.archived == true) {
      _archivedGroups.remove(group.id);
    }
    if (oldGroup?.archived == false) {
      _activeGroups.remove(group.id);
    }

    if (group.archived) {
      _archivedGroups.add(group.id);
      _activeGroups.remove(group.id);
    } else {
      _activeGroups.add(group.id);
      _archivedGroups.remove(group.id);
    }

    _lastUpdate = DateTime.now();
  }

  /// Removes a group from the index
  void removeGroup(String groupId) {
    final group = _byId.remove(groupId);
    if (group != null) {
      _pinnedGroups.remove(groupId);
      _archivedGroups.remove(groupId);
      _activeGroups.remove(groupId);
      _lastUpdate = DateTime.now();
    }
  }

  /// Gets a group by ID (O(1) lookup)
  ExpenseGroup? getById(String id) {
    return _byId[id];
  }

  /// Gets all groups as a sorted list
  List<ExpenseGroup> getAllGroups() {
    final groups = _byId.values.toList();
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return groups;
  }

  /// Gets active groups as a sorted list
  List<ExpenseGroup> getActiveGroups() {
    final groups = _activeGroups.map((id) => _byId[id]!).toList();
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return groups;
  }

  /// Gets archived groups as a sorted list
  List<ExpenseGroup> getArchivedGroups() {
    final groups = _archivedGroups.map((id) => _byId[id]!).toList();
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return groups;
  }

  /// Gets the pinned group (should be at most one)
  ExpenseGroup? getPinnedGroup() {
    if (_pinnedGroups.isEmpty) return null;
    return _byId[_pinnedGroups.first];
  }

  /// Gets groups by participant ID
  List<ExpenseGroup> getGroupsByParticipant(String participantId) {
    final groups = _byId.values
        .where((group) => group.participants.any((p) => p.id == participantId))
        .toList();
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return groups;
  }

  /// Gets groups by category ID
  List<ExpenseGroup> getGroupsByCategory(String categoryId) {
    final groups = _byId.values
        .where((group) => group.categories.any((c) => c.id == categoryId))
        .toList();
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return groups;
  }

  /// Gets groups by currency
  List<ExpenseGroup> getGroupsByCurrency(String currency) {
    final groups = _byId.values
        .where((group) => group.currency == currency)
        .toList();
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return groups;
  }

  /// Gets groups within a date range
  List<ExpenseGroup> getGroupsByDateRange(
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final groups = _byId.values.where((group) {
      if (startDate != null &&
          group.endDate != null &&
          group.endDate!.isBefore(startDate)) {
        return false;
      }
      if (endDate != null &&
          group.startDate != null &&
          group.startDate!.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return groups;
  }

  /// Searches groups by title (case-insensitive)
  List<ExpenseGroup> searchByTitle(String query) {
    final lowerQuery = query.toLowerCase();
    final groups = _byId.values
        .where((group) => group.title.toLowerCase().contains(lowerQuery))
        .toList();
    groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return groups;
  }

  /// Gets index statistics
  Map<String, dynamic> getStats() {
    return {
      'totalGroups': _byId.length,
      'activeGroups': _activeGroups.length,
      'archivedGroups': _archivedGroups.length,
      'pinnedGroups': _pinnedGroups.length,
      'lastUpdate': _lastUpdate?.toIso8601String(),
      'isDirty': _isDirty,
    };
  }

  /// Checks if the index needs rebuilding
  bool get isDirty => _isDirty;

  /// Marks the index as dirty (needs rebuilding)
  void markDirty() {
    _isDirty = true;
  }

  /// Clears the index
  void clear() {
    _byId.clear();
    _pinnedGroups.clear();
    _archivedGroups.clear();
    _activeGroups.clear();
    _isDirty = true;
    _lastUpdate = null;
  }

  /// Gets the number of groups in the index
  int get size => _byId.length;

  /// Checks if the index is empty
  bool get isEmpty => _byId.isEmpty;

  /// Validates index consistency
  List<String> validateConsistency() {
    final issues = <String>[];

    // Check that pinned groups are not archived
    for (final pinnedId in _pinnedGroups) {
      final group = _byId[pinnedId];
      if (group == null) {
        issues.add('Pinned group $pinnedId not found in main index');
      } else if (group.archived) {
        issues.add('Pinned group $pinnedId is archived');
      } else if (!group.pinned) {
        issues.add('Group $pinnedId in pinned set but not marked as pinned');
      }
    }

    // Check that archived/active sets are mutually exclusive
    final intersection = _archivedGroups.intersection(_activeGroups);
    if (intersection.isNotEmpty) {
      issues.add(
        'Groups in both archived and active sets: ${intersection.join(', ')}',
      );
    }

    // Check that all groups are in either archived or active
    for (final group in _byId.values) {
      final inArchived = _archivedGroups.contains(group.id);
      final inActive = _activeGroups.contains(group.id);

      if (group.archived && !inArchived) {
        issues.add('Archived group ${group.id} not in archived set');
      }
      if (!group.archived && !inActive) {
        issues.add('Active group ${group.id} not in active set');
      }
      if (group.archived && inActive) {
        issues.add('Archived group ${group.id} in active set');
      }
      if (!group.archived && inArchived) {
        issues.add('Active group ${group.id} in archived set');
      }
    }

    return issues;
  }
}

/// Expense index for fast expense lookups within groups
class ExpenseIndex {
  // Map expenseId -> { 'groupId': String, 'expenseIndex': int }
  final Map<String, Map<String, dynamic>> _expenseToGroupIndex = {};

  /// Rebuilds the expense index from groups
  void rebuild(List<ExpenseGroup> groups) {
    _expenseToGroupIndex.clear();

    for (final group in groups) {
      for (int i = 0; i < group.expenses.length; i++) {
        final expense = group.expenses[i];
        _expenseToGroupIndex[expense.id] = {
          'groupId': group.id,
          'expenseIndex': i,
        };
      }
    }
  }

  /// Finds which group contains an expense
  String? getGroupIdForExpense(String expenseId) {
    final info = _expenseToGroupIndex[expenseId];
    return info != null ? info['groupId'] as String? : null;
  }

  /// Gets expense location info (group ID and index within group)
  Map<String, dynamic>? getExpenseLocation(String expenseId) {
    return _expenseToGroupIndex[expenseId];
  }

  /// Whether the index is empty
  bool get isEmpty => _expenseToGroupIndex.isEmpty;

  /// Updates expense index when a group changes
  void updateGroup(ExpenseGroup group) {
    // Remove old entries for this group
    _expenseToGroupIndex.removeWhere(
      (expenseId, info) => info['groupId'] == group.id,
    );

    // Add new entries
    for (int i = 0; i < group.expenses.length; i++) {
      final expense = group.expenses[i];
      _expenseToGroupIndex[expense.id] = {
        'groupId': group.id,
        'expenseIndex': i,
      };
    }
  }

  /// Removes all expenses for a group
  void removeGroup(String groupId) {
    _expenseToGroupIndex.removeWhere(
      (expenseId, info) => info['groupId'] == groupId,
    );
  }

  /// Clears the expense index
  void clear() {
    _expenseToGroupIndex.clear();
  }

  /// Gets statistics about the expense index
  Map<String, dynamic> getStats() {
    final groupCounts = <String, int>{};
    for (final info in _expenseToGroupIndex.values) {
      final groupId = info['groupId'] as String;
      groupCounts[groupId] = (groupCounts[groupId] ?? 0) + 1;
    }

    return {
      'totalExpenses': _expenseToGroupIndex.length,
      'groupsWithExpenses': groupCounts.length,
      'expensesPerGroup': groupCounts,
    };
  }
}
