# Participant Global Autocomplete Implementation Summary

## Overview
Following the user's request to extend global autocomplete functionality to participants (with UUID reuse), this implementation provides the same comprehensive autocomplete system for participants that was previously implemented for categories.

## Key Question Answered
**"anche per i partecipandi. nel caso di riutilizzo, possiamo utilizzare lo stesso UUID ?"**

**Answer:** Yes! The implementation includes intelligent UUID reuse:
- When a participant with the same name (case-insensitive) exists across groups, the existing UUID is reused
- This ensures data consistency and unified participant identity across all expense groups
- The most recent participant version is preserved during deduplication

## Implementation Details

### 1. Repository Layer (`lib/data/expense_group_repository.dart`)
**Added Methods:**
```dart
Future<StorageResult<List<ExpenseParticipant>>> getAllParticipants();
Future<StorageResult<List<ExpenseParticipant>>> searchParticipants(String query);
```

### 2. Storage Index (`lib/data/storage_index.dart`)
**Enhanced GroupIndex with:**
- `getAllParticipants()` - Aggregates and deduplicates participants from all groups
- `searchParticipants(String query)` - Searches participants across all groups
- `getMostUsedParticipants()` - Returns frequently used participants
- Automatic cache invalidation for participant data

**Deduplication Logic:**
```dart
// Uses participant name as key (case-insensitive)
// Keeps the most recent participant with the same name
final existing = participantMap[participant.name.toLowerCase()];
if (existing == null || participant.createdAt.isAfter(existing.createdAt)) {
  participantMap[participant.name.toLowerCase()] = participant;
}
```

### 3. Repository Implementation (`lib/data/file_based_expense_group_repository.dart`)
**Added Methods:**
- `getAllParticipants()` - Uses index for fast retrieval with fallback
- `searchParticipants()` - Efficient searching with caching support

### 4. Participant Service (`lib/data/participant_service.dart`)
**New Service with:**
- 5-minute TTL cache for performance
- `getAllParticipants()` - Returns all participants with caching
- `searchParticipants(String query)` - Smart search functionality
- `getParticipantSuggestions()` - Prioritized autocomplete results
- `findParticipantByName()` - Finds existing participant by name
- `createOrReuseParticipant()` - **UUID reuse logic**

**UUID Reuse Implementation:**
```dart
Future<ExpenseParticipant> createOrReuseParticipant(String name) async {
  final existing = await findParticipantByName(name);
  
  if (existing != null) {
    // Reuse the existing participant's UUID
    return ExpenseParticipant(
      id: existing.id, // Reuse UUID
      name: name,
      createdAt: DateTime.now(),
    );
  }
  
  // Create new participant with new UUID
  return ExpenseParticipant(name: name);
}
```

### 5. UI Component (`lib/manager/expense/expense_form/participant_selector_widget.dart`)
**Enhanced ParticipantSelectorWidget:**
- Optional `ParticipantService` parameter for global search
- Backward compatibility with local-only participants
- Integration with `SelectionBottomSheet` search functionality
- Proper participant object handling vs. string names

**Usage Pattern:**
```dart
ParticipantSelectorWidget(
  participants: localParticipants.map((p) => p.name).toList(),
  selectedParticipant: currentSelection?.name,
  onParticipantSelected: onSelected,
  participantService: globalParticipantService, // New parameter
)
```

### 6. Dependency Injection (`lib/main.dart`)
**Added Provider:**
```dart
ProxyProvider<IExpenseGroupRepository, ParticipantService>(
  create: (context) => ParticipantService(
    Provider.of<IExpenseGroupRepository>(context, listen: false),
  ),
  update: (context, repository, _) => ParticipantService(repository),
),
```

### 7. Form Integration
**Updated ExpenseFormComponent and ExpenseEntrySheet:**
- Added `ParticipantService` parameter
- Passed service to `ParticipantSelectorWidget`
- Provider integration for service access

## Technical Benefits

### Performance
- **O(1) Lookups**: GroupIndex provides fast participant access
- **Smart Caching**: 5-minute TTL with automatic invalidation
- **Efficient Search**: Cached results for common queries

### Data Consistency
- **UUID Reuse**: Same participant across groups uses same UUID
- **Deduplication**: Automatic handling of duplicate names
- **Version Control**: Most recent participant data preserved

### User Experience
- **Global Access**: All participants available from any group
- **Smart Search**: Prioritized results (exact → prefix → contains)
- **Backward Compatibility**: Works with existing local-only mode

## Search Prioritization Logic
```dart
// 1. Exact matches first
if (lowerName == lowerQuery) exactMatches.add(participant);
// 2. Prefix matches next  
else if (lowerName.startsWith(lowerQuery)) prefixMatches.add(participant);
// 3. Contains matches last
else containsMatches.add(participant);
```

## Cache Management
- **Automatic Invalidation**: When participants are modified
- **TTL Expiration**: Prevents stale data (5 minutes)
- **Graceful Degradation**: Falls back to repository if cache fails
- **Memory Efficient**: Only caches when needed

## Testing
- Comprehensive unit tests in `test/participant_service_test.dart`
- Manual test plan in `PARTICIPANT_AUTOCOMPLETE_TEST_PLAN.md`
- Edge case coverage including Unicode names, empty groups, etc.

## Migration Notes
- **Zero Breaking Changes**: Existing code works unchanged
- **Opt-in Enhancement**: Global search only when service is provided
- **Data Compatibility**: Existing participant data remains valid
- **UUID Stability**: Existing UUIDs are preserved and reused

## Files Modified
1. `lib/data/expense_group_repository.dart` - Interface extension
2. `lib/data/file_based_expense_group_repository.dart` - Implementation  
3. `lib/data/storage_index.dart` - Index enhancement
4. `lib/data/participant_service.dart` - **New service**
5. `lib/manager/expense/expense_form/participant_selector_widget.dart` - UI enhancement
6. `lib/manager/expense/expense_form_component.dart` - Integration
7. `lib/manager/details/widgets/expense_entry_sheet.dart` - Provider integration
8. `lib/main.dart` - Dependency injection
9. `test/participant_service_test.dart` - **New tests**

This implementation provides a complete, production-ready solution for global participant autocomplete with intelligent UUID reuse, following the same proven patterns used for the category system.