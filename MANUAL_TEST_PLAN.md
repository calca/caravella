# Manual Testing Plan for Category Autocomplete

## Test Environment Setup
1. Ensure Flutter environment is properly set up
2. Build and run the application
3. Create multiple expense groups with different categories
4. Test the autocomplete functionality

## Test Scenarios

### Scenario 1: Basic Autocomplete Functionality
**Setup:**
- Create Group A with categories: "Food", "Transport", "Accommodation"
- Create Group B with categories: "Food", "Entertainment", "Shopping"
- Create Group C with categories: "Medical", "Fuel"

**Test Steps:**
1. Open Group A
2. Start adding a new expense (inline mode)
3. Tap on category selector
4. Verify search field appears
5. Type "foo" in search field
6. Expected: Should show "Food" from both groups A and B
7. Type "ent" in search field  
8. Expected: Should show "Entertainment" from group B
9. Type "trans" in search field
10. Expected: Should show "Transport" from group A

**Expected Results:**
- Search field is visible and functional
- Categories from all groups appear in search results
- Search is case-insensitive
- Results are filtered as user types

### Scenario 2: Category Deduplication
**Test Steps:**
1. Search for "food" (case-insensitive)
2. Expected: Only one "Food" entry appears despite being in multiple groups
3. Select the Food category
4. Expected: Category is properly selected

### Scenario 3: New Category Creation
**Test Steps:**
1. In category search, type "NewCategory"
2. Expected: No existing results shown
3. Tap "Add Category" button
4. Expected: New category is created and available
5. Open another group and search for "NewCategory"
6. Expected: The new category appears in search results across all groups

### Scenario 4: Search Prioritization
**Setup:**
- Create categories: "Transport", "Transportation", "Air Transport"

**Test Steps:**
1. Search for "transport"
2. Expected results in order:
   - "Transport" (exact match first)
   - "Transportation" (prefix match second)  
   - "Air Transport" (contains match last)

### Scenario 5: Performance Testing
**Test Steps:**
1. Create 10+ groups with 5+ categories each
2. Search for categories
3. Expected: Search results appear quickly (< 500ms)
4. Search again for same term
5. Expected: Results appear immediately (cached)

### Scenario 6: Backward Compatibility
**Test Steps:**
1. Navigate to category selection in non-inline mode
2. Expected: Traditional category picker without search field
3. Ensure existing category selection still works

### Scenario 7: Empty Search Handling
**Test Steps:**
1. Open category selector with search
2. Leave search field empty
3. Expected: All available categories from all groups are shown
4. Clear search field after typing
5. Expected: All categories appear again

### Scenario 8: Cache Invalidation
**Test Steps:**
1. Search for categories (to populate cache)
2. Add a new category in any group
3. Search again immediately
4. Expected: New category appears in search results

## UI/UX Testing

### Visual Elements
- [ ] Search field appears correctly in category selector
- [ ] Loading indicator shows during search
- [ ] Clear button (X) appears when text is entered
- [ ] Results list updates in real-time
- [ ] Keyboard behavior is correct

### Interaction Testing
- [ ] Touch targets are appropriately sized
- [ ] Keyboard dismisses correctly
- [ ] Scroll behavior works with search results
- [ ] Add new category flow works from search

## Error Handling

### Network/Storage Errors
- [ ] App handles storage errors gracefully
- [ ] Search continues to work if some data is unavailable
- [ ] Fallback to local categories if global search fails

### Edge Cases
- [ ] Very long category names display correctly
- [ ] Special characters in category names work
- [ ] Large number of categories (100+) performs well
- [ ] Empty groups don't break category aggregation

## Performance Metrics
- [ ] Initial category load time: < 200ms
- [ ] Search response time: < 100ms
- [ ] Memory usage remains stable during extended use
- [ ] No memory leaks during repeated searches

## Accessibility Testing
- [ ] Screen reader support for search field
- [ ] Keyboard navigation works properly
- [ ] Focus management is correct
- [ ] Semantic labels are appropriate

## Cross-Platform Testing
- [ ] Android: Search and selection work correctly
- [ ] iOS: Search and selection work correctly  
- [ ] Web: Search and selection work correctly
- [ ] Desktop: Search and selection work correctly

## Success Criteria
✅ All test scenarios pass
✅ No performance degradation
✅ Backward compatibility maintained
✅ User experience is intuitive
✅ Error handling is robust