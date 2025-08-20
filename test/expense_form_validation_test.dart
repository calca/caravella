# Manual Test Plan for Expense Form Real-time Validation

## Test Scenario: Real-time Save Button Validation

### Prerequisites
- Navigate to any expense group
- Tap "Add Expense" button to open expense form

### Test Steps

1. **Initial State Test**
   - **Expected**: Save button (checkmark icon) should be disabled/grayed out
   - **Reason**: No amount, no name entered yet

2. **Amount Input Test**
   - Enter an amount (e.g., "25,50")
   - **Expected**: Save button should remain disabled
   - **Reason**: Name field is still empty

3. **Name Input Test**
   - Type in expense name (e.g., "Pizza dinner")
   - **Expected**: Save button should become enabled immediately as you type
   - **Reason**: All required fields now have valid values (amount > 0, name not empty, participant pre-selected)

4. **Real-time Name Validation Test**
   - Clear the name field completely
   - **Expected**: Save button should become disabled immediately
   - Type name again
   - **Expected**: Save button should become enabled immediately

5. **Amount Validation Test** 
   - Clear amount field
   - **Expected**: Save button should become disabled immediately
   - Enter amount again
   - **Expected**: Save button should become enabled immediately

6. **Complete Form Test**
   - Ensure all fields are filled:
     - Amount: "15,00"
     - Name: "Coffee"
     - Paid by: Should be pre-selected
     - Category: Should be pre-selected (if categories exist)
   - **Expected**: Save button should be enabled
   - Tap save button
   - **Expected**: Expense should be saved and form should close

### Validation Criteria

- **Real-time Response**: Save button state should update immediately as user types (no need to lose focus from field)
- **Visual Feedback**: Button should clearly show enabled (normal color) vs disabled (grayed out) state
- **Functional**: When enabled, button should actually save the expense
- **Edge Cases**: Empty strings, whitespace-only strings should be treated as invalid

### Expected Form Validation Rules

Save button is enabled ONLY when ALL conditions are met:
1. Amount > 0 (not null, not zero)
2. Name is not empty (after trimming whitespace)
3. Paid By participant is selected
4. Category is selected (only if categories exist in the group)

This test verifies that the real-time validation implemented in `expense_form_component.dart` works correctly for the user experience described in issue #47.