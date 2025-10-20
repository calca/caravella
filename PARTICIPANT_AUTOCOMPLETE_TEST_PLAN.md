# Participant Global Autocomplete Manual Testing Plan

## Overview
This document outlines the manual testing procedures for the newly implemented global participant autocomplete system. The system allows users to access participants from all expense groups when creating expenses inline, with intelligent UUID reuse for consistency.

## Setup Requirements
1. Install Flutter SDK (latest stable)
2. Run `flutter pub get` to install dependencies
3. Build the app: `flutter build apk --flavor staging --release --dart-define=FLAVOR=staging`
4. Create multiple expense groups with different participants to test cross-group functionality

## Test Scenarios

### 1. Basic Participant Autocomplete Functionality

**Setup:**
- Create Group A with participants: "Alice", "Bob"
- Create Group B with participants: "Charlie", "David"
- Create Group C with participants: "alice" (lowercase), "Eve"

**Test Steps:**
1. Open Group A and create a new expense
2. Tap on the participant selector
3. Start typing "a" in the search field
4. Verify that "Alice" from Group A and "alice" from Group C appear
5. Verify that the search is case-insensitive
6. Select "Alice" and complete the expense creation

**Expected Results:**
- Search should return participants from all groups matching the query
- Case-insensitive search should work correctly
- Selection should work without errors

### 2. UUID Reuse Verification

**Setup:**
- Use the groups from Test 1
- Note the UUIDs of participants (check via data export if possible)

**Test Steps:**
1. Create an expense in Group A with participant "Alice"
2. Navigate to Group C and create an expense
3. When selecting participant, search for "alice"
4. Select "alice" (should be the same as "Alice" due to case-insensitive matching)
5. Export data and verify UUID consistency

**Expected Results:**
- The same UUID should be used for "Alice" and "alice" entries
- Participant deduplication should work correctly
- Most recent version should be preserved

### 3. Search Prioritization

**Setup:**
- Create groups with participants:
  - "Alice", "Alexander", "Alicia", "Charlie Allen"

**Test Steps:**
1. Open any group and create a new expense
2. In participant selector, search for "al"
3. Observe the order of results

**Expected Results:**
- Exact matches should appear first
- Prefix matches should appear next
- Contains matches should appear last
- Order should be: "Alice" → "Alexander" → "Alicia" → "Charlie Allen"

### 4. Performance Testing

**Setup:**
- Create 5+ groups with 10+ participants each (total 50+ unique participants)
- Include some duplicate names across groups

**Test Steps:**
1. Open participant selector in any group
2. Measure response time for empty search (should show all participants)
3. Measure response time for specific searches
4. Test rapid typing and search responsiveness

**Expected Results:**
- Initial load should be fast (< 1 second)
- Search should be responsive during typing
- No noticeable lag with 50+ participants
- UI should remain smooth during interaction

### 5. Backward Compatibility

**Setup:**
- Temporarily disable ParticipantService (comment out in provider setup)
- Or test in a context where only local participants are available

**Test Steps:**
1. Open participant selector
2. Verify only local group participants appear
3. Verify selection still works correctly

**Expected Results:**
- Should fall back to local-only participant selection
- No crashes or errors
- Normal functionality maintained

### 6. Cache Invalidation

**Setup:**
- Create initial groups with participants

**Test Steps:**
1. Open participant selector and perform a search (loads cache)
2. Go back and add a new participant to current group
3. Create a new expense and open participant selector
4. Search for the newly added participant

**Expected Results:**
- Newly added participant should appear in search results
- Cache should be automatically invalidated when new participants are added
- No stale data should be displayed

### 7. Edge Cases

#### 7.1 Empty Groups
**Test Steps:**
1. Create a group with no participants
2. Try to create an expense
3. Test participant selector behavior

**Expected Results:**
- Should show participants from other groups
- Selector should not be disabled
- Should work normally

#### 7.2 Special Characters in Names
**Test Steps:**
1. Create participants with names: "José", "François", "李明", "O'Connor"
2. Test search functionality with these names

**Expected Results:**
- Unicode names should work correctly
- Search should handle special characters
- Selection should work for all character sets

#### 7.3 Very Long Names
**Test Steps:**
1. Create participant with very long name (50+ characters)
2. Test display and search functionality

**Expected Results:**
- Names should be properly truncated in UI
- Search should still work
- Selection should function correctly

### 8. Integration Testing

**Test Steps:**
1. Create expense using global participant autocomplete
2. Verify expense is saved correctly
3. Check expense appears in group details
4. Export group data and verify participant consistency
5. Test expense editing maintains participant selection

**Expected Results:**
- Full workflow should work seamlessly
- Data consistency maintained throughout
- No regression in existing functionality

## Success Criteria

The implementation passes testing if:
- ✅ All participants from all groups are accessible during expense creation
- ✅ UUID reuse works correctly for same-named participants
- ✅ Search functionality is responsive and accurate
- ✅ Backward compatibility is maintained
- ✅ Performance is acceptable with realistic data volumes
- ✅ No regressions in existing functionality
- ✅ Edge cases are handled gracefully

## Reporting Issues

If any test fails:
1. Document the specific steps that led to the failure
2. Note the expected vs actual behavior
3. Include relevant device/app version information
4. Provide screenshots or screen recordings if helpful
5. Check console logs for any error messages

## Additional Notes

- This testing should be performed on both Android and iOS if possible
- Test with different screen sizes and orientations
- Verify accessibility features still work correctly
- Test with different locale settings if internationalization is important