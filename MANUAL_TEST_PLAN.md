# Manual Testing Plan for Expense Filters

## Overview
This document outlines the manual testing scenarios for the newly implemented expense filtering functionality on the expense group details page.

## Test Scenarios

### 1. Basic Filter Display
**Steps:**
1. Navigate to an expense group with multiple expenses
2. Verify the "Attività" header shows expense count
3. Click the filter icon (filter_list) next to the header
4. Verify filter controls appear with:
   - Search bar with placeholder "Cerca per nome o nota..."
   - "Categoria" section with filter chips
   - "Pagato da" section with filter chips

### 2. Search Functionality
**Steps:**
1. Open filter controls
2. Type in search bar to search by expense name
3. Verify expenses are filtered in real-time
4. Clear search and type a note keyword
5. Verify expenses with matching notes are shown
6. Test partial matches and case insensitivity

### 3. Category Filter
**Steps:**
1. Open filter controls
2. Click on different category filter chips
3. Verify only expenses from selected category are shown
4. Click "Tutte" to show all categories again
5. Test with groups that have no categories (filter should not appear)

### 4. Participant Filter  
**Steps:**
1. Open filter controls
2. Click on different participant filter chips
3. Verify only expenses paid by selected participant are shown
4. Click "Tutti" to show all participants again
5. Test with single-participant groups

### 5. Combined Filters
**Steps:**
1. Apply search + category filter
2. Apply search + participant filter
3. Apply category + participant filter
4. Apply all three filters together
5. Verify filters work correctly in combination

### 6. Clear Filters
**Steps:**
1. Apply multiple filters
2. Verify "Pulisci" (Clear) button appears
3. Click clear button
4. Verify all filters are reset and all expenses shown

### 7. Empty States
**Steps:**
1. Apply filters that result in no matches
2. Verify appropriate empty state message is shown
3. Test with group that has no expenses at all
4. Verify correct empty state for no expenses vs no filtered results

### 8. UI/UX Validation
**Steps:**
1. Verify filter toggle icon changes between filter_list and filter_list_off
2. Check tooltip text changes correctly
3. Verify expense count updates when filters are applied
4. Test filter panel styling matches app theme
5. Verify smooth animations and transitions

## Expected Results

### Filter Display
- Filter controls should integrate seamlessly with existing UI
- Material 3 design consistent with rest of app
- Proper spacing and layout on different screen sizes

### Search Results
- Real-time filtering as user types
- Matches both expense names and notes
- Case-insensitive matching
- Partial word matching

### Filter Chips
- Visual feedback when selected
- Proper color scheme following app theme
- "All" options work correctly to reset individual filters

### Performance
- No lag when filtering large numbers of expenses
- Smooth state transitions
- Proper memory management

## Test Data Requirements

For comprehensive testing, create expense groups with:
- Multiple categories (Food, Transport, Accommodation, etc.)
- Multiple participants (3-5 people)  
- Expenses with both names and notes
- Mix of amounts and dates
- Special characters in names/notes
- Groups with 0, 1, 5, 15+ expenses

## Known Limitations

- Filters are not persistent across app sessions (by design)
- Search is limited to name and note fields only
- Amount and date filtering not implemented (not requested)

## Screenshots to Capture

1. Default view without filters
2. Filter controls expanded
3. Search in action with results
4. Category filter applied
5. Participant filter applied
6. Combined filters active with count
7. Empty state when no matches found
8. Clear filters button visible