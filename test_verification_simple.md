# Expense Group Save Bug Fix - Verification

## Problem Statement
When saving modifications to an expense group, all expenses in the group were being deleted.

## Root Cause Analysis
In `lib/manager/group/group_form_controller.dart`, the `save()` method was not preserving the `expenses` field when calling `copyWith()` on the ExpenseGroup.

## Original Code (Problematic)
```dart
final group = (_original ?? ExpenseGroup.empty()).copyWith(
  title: state.title.trim(),
  participants: state.participants
      .map((e) => ExpenseParticipant(name: e.name))
      .toList(),
  categories: state.categories
      .map((e) => ExpenseCategory(name: e.name))
      .toList(),
  startDate: state.startDate,
  endDate: state.endDate,
  currency: state.currency['code'] ?? state.currency['symbol'] ?? 'EUR',
  file: state.imagePath,
  color: state.color,
  timestamp: _original?.timestamp ?? now,
  // ❌ MISSING: expenses parameter!
);
```

## Fixed Code
```dart
final group = (_original ?? ExpenseGroup.empty()).copyWith(
  title: state.title.trim(),
  expenses: _original?.expenses ?? [], // ✅ FIXED: Preserve existing expenses
  participants: state.participants
      .map((e) => ExpenseParticipant(name: e.name))
      .toList(),
  categories: state.categories
      .map((e) => ExpenseCategory(name: e.name))
      .toList(),
  startDate: state.startDate,
  endDate: state.endDate,
  currency: state.currency['code'] ?? state.currency['symbol'] ?? 'EUR',
  file: state.imagePath,
  color: state.color,
  timestamp: _original?.timestamp ?? now,
);
```

## Logic Verification

### Case 1: Editing Existing Group with Expenses
- `_original` is not null and contains expenses
- `_original.expenses` contains the existing expenses
- Result: `expenses: _original.expenses` preserves all expenses ✅

### Case 2: Creating New Group
- `_original` is null
- `ExpenseGroup.empty()` is used as base (has empty expenses list)
- Result: `expenses: []` creates empty expenses list ✅

### Case 3: Editing Existing Group with No Expenses
- `_original` is not null but has empty expenses list
- `_original.expenses` is empty list `[]`
- Result: `expenses: []` preserves empty state ✅

## Pattern Consistency Check

### Similar pattern in expense_group_notifier.dart
```dart
// Line 66: When adding expense, they explicitly pass expenses
final updatedGroup = _currentGroup!.copyWith(expenses: updatedExpenses);
```

### Similar pattern in expense_group_detail_page.dart
```dart
// Lines 454-465: When updating group, they explicitly preserve all fields
final updatedGroup = ExpenseGroup(
  title: _trip!.title,
  expenses: List<ExpenseDetails>.from(updatedExpenses), // Explicitly preserved
  participants: _trip!.participants,
  // ... other fields
);
```

## Conclusion
The fix is:
1. ✅ **Minimal**: Only adds one line
2. ✅ **Surgical**: Only affects the problematic code path
3. ✅ **Consistent**: Follows patterns used elsewhere in codebase
4. ✅ **Complete**: Handles all edge cases (new group, existing group, empty expenses)
5. ✅ **Safe**: Uses null-safe operators and sensible defaults

The fix should resolve the issue where expenses were being deleted when saving group modifications.