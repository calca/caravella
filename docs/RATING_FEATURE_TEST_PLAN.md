# Store Rating Feature - Test Plan

## Overview
This test plan covers the validation of the in-app store rating feature implemented in issue #[number].

## Feature Requirements
✅ Show rating dialog after user adds 10th expense (cumulative across all groups)
✅ After initial prompt, show rating once per month (30-day minimum gap)
✅ Use native platform rating dialogs (Google Play / App Store)
✅ Non-intrusive and fail gracefully

## Test Scenarios

### 1. Initial Rating Prompt (First 10 Expenses)

#### Test Case 1.1: No prompt before 10 expenses
**Steps:**
1. Fresh install of app / reset rating state
2. Create a group and add 9 expenses
3. Observe behavior

**Expected Result:**
- No rating dialog appears
- App functions normally
- User can continue adding expenses

**Verification:**
```dart
// Check preference state
await PreferencesService.getTotalExpenseCount(); // Should be 9
await PreferencesService.getHasShownInitialRating(); // Should be false
```

#### Test Case 1.2: Prompt appears on 10th expense
**Steps:**
1. Continue from Test Case 1.1
2. Add the 10th expense
3. Observe behavior

**Expected Result:**
- Rating dialog appears immediately after expense is saved
- Dialog is native (Google Play or App Store)
- Toast message "Spesa aggiunta con successo" still appears
- Bottom sheet closes normally

**Verification:**
```dart
// After dismissing dialog
await PreferencesService.getTotalExpenseCount(); // Should be 10
await PreferencesService.getHasShownInitialRating(); // Should be true
await PreferencesService.getLastRatingPrompt(); // Should be set to current date
```

#### Test Case 1.3: No prompt after 10th expense (already shown)
**Steps:**
1. Continue from Test Case 1.2
2. Add 11th, 12th expenses
3. Observe behavior

**Expected Result:**
- No rating dialog appears
- hasShownInitialRating remains true
- Expenses are added normally

### 2. Monthly Rating Prompts

#### Test Case 2.1: No prompt within 30 days
**Steps:**
1. Initial rating already shown (hasShownInitialRating = true)
2. Last prompt was 20 days ago
3. Add new expense

**Expected Result:**
- No rating dialog appears
- Expense is added normally

**Verification:**
```dart
final lastPrompt = await PreferencesService.getLastRatingPrompt();
final daysSince = DateTime.now().difference(lastPrompt!).inDays;
// Should be < 30
```

#### Test Case 2.2: Prompt appears after 30 days
**Steps:**
1. Initial rating already shown
2. Last prompt was 30+ days ago
3. Add new expense

**Expected Result:**
- Rating dialog appears
- Last prompt timestamp is updated

**Verification:**
```dart
final lastPrompt = await PreferencesService.getLastRatingPrompt();
final daysSince = DateTime.now().difference(lastPrompt!).inDays;
// Should be 0 (just updated)
```

**Note for Testing:**
To simulate 30 days, use:
```dart
// Set last prompt to 31 days ago
final thirtyOneDaysAgo = DateTime.now().subtract(Duration(days: 31));
await PreferencesService.setLastRatingPrompt(thirtyOneDaysAgo);
```

### 3. Multi-Group Expense Tracking

#### Test Case 3.1: Cumulative counting across groups
**Steps:**
1. Reset rating state
2. Create Group A, add 5 expenses
3. Create Group B, add 3 expenses
4. Create Group C, add 2 expenses (total = 10)

**Expected Result:**
- Rating dialog appears after 10th expense (from any group)
- Total count is cumulative across all groups

**Verification:**
```dart
// Check all groups
final allGroups = await ExpenseGroupStorageV2.getAllGroups();
final total = allGroups.fold<int>(0, (sum, g) => sum + g.expenses.length);
// Should be 10
```

### 4. Platform-Specific Behavior

#### Test Case 4.1: Android
**Platform:** Android device with Google Play Services
**Steps:**
1. Trigger rating prompt (10th expense)
2. Observe dialog

**Expected Result:**
- Native Google Play in-app review dialog appears
- Options: rate, remind later, dismiss
- No app navigation occurs

#### Test Case 4.2: iOS
**Platform:** iOS device (iOS 10.3+)
**Steps:**
1. Trigger rating prompt (10th expense)
2. Observe dialog

**Expected Result:**
- Native App Store review dialog appears
- 5-star rating interface
- Option to write review

#### Test Case 4.3: Web/Desktop
**Platform:** Web browser or Desktop app
**Steps:**
1. Trigger rating prompt
2. Observe behavior

**Expected Result:**
- No dialog appears (gracefully skipped)
- Log message: "In-app review not available on this platform"
- Expense is added normally

### 5. Error Handling

#### Test Case 5.1: Network unavailable
**Steps:**
1. Disable network connection
2. Trigger rating prompt

**Expected Result:**
- App doesn't crash
- Rating check completes (may or may not show dialog depending on platform)
- Expense is added successfully

#### Test Case 5.2: Corrupted preferences
**Steps:**
1. Manually corrupt rating preferences
2. Trigger rating prompt

**Expected Result:**
- App doesn't crash
- Falls back to default values (0 expenses, not shown)
- New tracking starts from 0

### 6. User Experience

#### Test Case 6.1: Non-blocking flow
**Steps:**
1. Start adding expense
2. Fill out form
3. Save expense (triggers 10th)
4. Observe timing

**Expected Result:**
- Expense save completes immediately
- Success toast appears
- Bottom sheet closes
- Rating dialog appears after (non-blocking)
- User can continue using app

#### Test Case 6.2: Quick successive expense additions
**Steps:**
1. At 8 expenses, quickly add 9th and 10th
2. Observe behavior

**Expected Result:**
- Both expenses are saved
- Rating dialog appears only once (after 10th)
- No duplicate dialogs

### 7. Edge Cases

#### Test Case 7.1: App restart after reaching 10 expenses
**Steps:**
1. Add 10th expense, see rating dialog
2. Close app completely
3. Reopen app
4. Add 11th expense

**Expected Result:**
- No rating dialog on 11th expense
- State persisted correctly

#### Test Case 7.2: Expense deletion
**Steps:**
1. Add 10 expenses (dialog shown)
2. Delete 2 expenses (total = 8)
3. Add another expense (total = 9)

**Expected Result:**
- No new rating dialog
- hasShownInitialRating remains true
- Monthly timing is preserved

## Testing Utilities

### Reset Rating State
```dart
import 'package:io_caravella_egm/data/services/rating_service.dart';

// Reset all rating preferences
await RatingService.resetRatingState();
```

### Check Current State
```dart
import 'package:io_caravella_egm/data/services/preferences_service.dart';

// Check preferences
final count = await PreferencesService.getTotalExpenseCount();
final hasShown = await PreferencesService.getHasShownInitialRating();
final lastPrompt = await PreferencesService.getLastRatingPrompt();

print('Total expenses: $count');
print('Initial shown: $hasShown');
print('Last prompt: $lastPrompt');
```

### Simulate 30-Day Gap
```dart
// Set last prompt to 31 days ago
final pastDate = DateTime.now().subtract(Duration(days: 31));
await PreferencesService.setLastRatingPrompt(pastDate);
```

## Automated Tests

### Unit Tests
Location: `test/rating_service_test.dart`

Run with:
```bash
flutter test test/rating_service_test.dart
```

Tests cover:
- Preference storage and retrieval
- Default values
- Timestamp handling
- Multiple updates

### Integration Tests (Future Enhancement)
Consider adding:
- Full flow from adding expense to dialog appearance
- Multi-group expense counting
- Time-based throttling simulation

## Acceptance Criteria

✅ All test cases pass
✅ No crashes or errors in logs
✅ Rating dialogs appear at correct times
✅ Native platform dialogs are used
✅ User flow is not blocked or interrupted
✅ State persists across app restarts
✅ Works correctly on all supported platforms
✅ Gracefully handles unavailable platforms

## Known Limitations

1. **iOS Simulator:** Rating dialog may not appear in simulator (Apple limitation)
   - Test on real iOS device for accurate behavior

2. **Testing Frequency:** Apple and Google limit how often rating dialogs can be shown
   - System may suppress dialogs if shown too frequently during testing
   - Use `resetRatingState()` between test runs

3. **Dialog Appearance:** Final decision to show dialog is made by OS
   - App can request, but OS may choose not to show
   - This is expected behavior per platform guidelines

## Logging

Monitor these logs during testing:

```
[rating] Showing rating prompt at X expenses
[rating] In-app review not available on this platform
[rating] Error checking/prompting for rating: ...
```

## Sign-Off

- [ ] All test cases executed
- [ ] No critical bugs found
- [ ] Performance acceptable
- [ ] UX smooth and non-intrusive
- [ ] Documentation complete
- [ ] Ready for production

---

**Testing Date:** _____________
**Tester:** _____________
**Platform(s) Tested:** _____________
**Result:** Pass / Fail / Conditional
**Notes:** _____________
