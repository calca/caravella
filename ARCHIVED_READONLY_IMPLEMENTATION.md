# Archived Groups Read-Only Implementation

## Overview
This implementation adds read-only mode for archived expense groups, preventing modifications to both the group itself and its expenses.

## Changes Made

### 1. Localization Strings (All Languages)
Added new localization strings in all language files (`lib/l10n/app_*.arb`):
- `archived_group_readonly`: Title for archived group read-only message
- `archived_group_readonly_desc`: Description explaining that archived groups cannot be modified
- `expense_readonly`: Title for expense in read-only mode
- `expense_readonly_archived`: Message explaining that expense cannot be modified because group is archived

### 2. Core Data Structure Changes

#### `ExpenseFormConfig` (`lib/manager/expense/components/expense_form_config.dart`)
- Added `isReadOnly` parameter (defaults to `false`)
- Updated all factory constructors (`create`, `edit`, and `legacy`) to accept `isReadOnly` parameter
- This parameter controls whether the expense form allows editing

### 3. Expense Form Read-Only Implementation

#### `ExpenseFormPage` (`lib/manager/expense/pages/expense_form_page.dart`)
- Checks if the group is archived via `group.archived`
- Shows read-only indicator banner when archived
- Changes page title to "Expense - Read-only" for archived groups
- Hides save button when in read-only mode
- Disables delete button when in read-only mode
- Passes `isReadOnly` flag to `ExpenseFormComponent`

#### Form Input Widgets - All Updated with `enabled` Parameter
All input widgets now accept an `enabled` parameter (defaults to `true`):

1. **`AmountInputWidget`** (`lib/manager/expense/widgets/amount_input_widget.dart`)
   - Disables both text and amount input fields

2. **`ParticipantSelectorWidget`** (`lib/manager/expense/widgets/participant_selector_widget.dart`)
   - Prevents opening participant picker when disabled

3. **`CategorySelectorWidget`** (`lib/manager/expense/widgets/category_selector_widget.dart`)
   - Prevents opening category picker when disabled

4. **`DateSelectorWidget`** (`lib/manager/expense/widgets/date_selector_widget.dart`)
   - Prevents opening date picker when disabled

5. **`NoteInputWidget`** (`lib/manager/expense/widgets/note_input_widget.dart`)
   - Disables text input field

6. **`AttachmentInputWidget`** (`lib/manager/expense/widgets/attachment_input_widget.dart`)
   - Prevents adding new attachments
   - Prevents removing existing attachments
   - Still allows viewing attachments

7. **`LocationInputWidget`** (`lib/manager/expense/location/widgets/location_input_widget.dart`)
   - Prevents opening place search
   - Prevents getting current location
   - Still displays existing location

#### Form Field Components
- **`ExpenseFormFields`** and **`ExpenseFormExtendedFields`** updated to pass `isReadOnly` flag to all child widgets
- All form fields are disabled when `isReadOnly` is `true`

### 4. Group Edit Page Read-Only Implementation

#### `ExpensesGroupEditPage` (`lib/manager/group/pages/expenses_group_edit_page.dart`)
- Checks if group is archived at the start of `build()` method
- Shows a centered read-only message screen for archived groups:
  - Archive icon
  - "Archived Group - Read-only" title
  - Explanation text
- Prevents all group editing when archived
- Normal edit flow continues for non-archived groups

### 5. Group Detail Page Updates

#### `ExpenseGroupDetailPage` (`lib/manager/details/pages/expense_group_detail_page.dart`)
- Hides the floating action button (FAB) for adding expenses when group is archived
- This prevents users from attempting to add new expenses to archived groups

#### `OptionsSheet` (`lib/manager/details/widgets/options_sheet.dart`)
- Disables the "Edit Group" option when group is archived
- Visual feedback: grayed out with reduced opacity
- Prevents navigation to group edit page for archived groups

## User Experience Flow

### When a Group is Archived:

1. **From Group Detail Page:**
   - No floating action button to add new expenses
   - Tapping on existing expenses opens them in read-only mode
   - Options menu shows "Edit Group" as disabled/grayed out
   - Pin option is also disabled (archived groups cannot be pinned)

2. **Viewing an Expense (from archived group):**
   - Page title shows "Expense - Read-only"
   - Info banner explains the expense cannot be modified
   - All input fields are disabled (grayed out)
   - Amount, name, participant, category, date, location, notes, attachments all read-only
   - Save button is hidden
   - Delete button is hidden
   - Share button remains available
   - Attachments can still be viewed but not added or removed

3. **Attempting to Edit Group:**
   - If somehow navigated to edit page, shows centered message:
     - Archive icon
     - "Archived Group - Read-only" title
     - "This group is archived. You cannot modify it or add new expenses." message
   - No form fields are shown

### When a Group is Unarchived:
- All functionality returns to normal
- FAB reappears
- Edit option becomes enabled
- Expenses can be edited normally

## Technical Implementation Details

### Architecture
- **Clean separation of concerns**: Read-only logic is implemented at multiple layers
  - UI layer (page level): Shows appropriate messages and hides actions
  - Component layer: Disables form inputs
  - Widget layer: Individual widgets respect `enabled` parameter

- **Backward compatibility**: All new parameters default to maintaining existing behavior
  - `isReadOnly` defaults to `false`
  - `enabled` defaults to `true`

### Key Design Decisions

1. **Cascade disabling**: Read-only mode is passed down through the component tree
   - `ExpenseFormPage` → `ExpenseFormComponent` → `ExpenseFormFields` / `ExpenseFormExtendedFields` → Individual widgets

2. **Attachment viewing preserved**: Users can still view attachments even in read-only mode, providing transparency

3. **Share functionality preserved**: Users can still share expense details even when archived

4. **Visual feedback**: All disabled elements use standard Material Design disabled styling (reduced opacity)

5. **Group edit prevention**: Instead of showing disabled fields, archived group edit shows a clear message screen

## Testing

### Manual Testing Checklist
- [ ] Archive a group from the detail page
- [ ] Verify FAB disappears when group is archived
- [ ] Try to edit the group - should show read-only message
- [ ] Try to edit an expense - should open in read-only mode
- [ ] Verify all form fields are disabled in expense view
- [ ] Verify save button is hidden in expense view
- [ ] Verify delete button is hidden in expense view
- [ ] Verify share button still works
- [ ] Verify attachments can be viewed but not modified
- [ ] Unarchive the group
- [ ] Verify all functionality returns to normal
- [ ] Verify FAB reappears
- [ ] Verify edit group works normally
- [ ] Verify edit expense works normally

### Unit Tests
Added `test/archived_group_readonly_test.dart`:
- Tests `ExpenseFormConfig` accepts `isReadOnly` parameter
- Tests all factory constructors handle `isReadOnly`
- Tests `isReadOnly` defaults to `false`
- Tests `ExpenseGroup` archived field functionality
- Tests `copyWith` preserves and can change archived status

### Integration Testing Recommendations
1. Create integration test that:
   - Creates a group
   - Adds some expenses
   - Archives the group
   - Attempts to edit group (should fail)
   - Attempts to edit expense (should open read-only)
   - Attempts to add expense (FAB should not be visible)
   - Unarchives group
   - Verifies all operations work again

## Future Enhancements
- Add analytics to track how often users interact with archived content
- Consider adding a "View Only" mode separate from archived
- Consider batch operations on archived groups
- Add visual badge/chip on group cards to indicate archived status more prominently
- Consider undo/redo for archive operations

## Notes for Developers
- When adding new form fields, remember to:
  1. Add `enabled` parameter to the widget
  2. Pass `!isReadOnly` to the widget from parent component
  3. Disable interaction when `enabled` is `false`
  
- The `isReadOnly` flag flows from:
  1. Group's `archived` property
  2. Through `ExpenseFormPage`
  3. Into `ExpenseFormConfig`
  4. To all form components
  5. Down to individual widgets

## Migration Notes
No database migrations needed. The `archived` field already exists in `ExpenseGroup` model.

## Performance Considerations
- Minimal performance impact
- No additional database queries
- Single property check at page/component initialization
- All disabled logic is synchronous

## Accessibility
- All disabled fields use standard Material Design disabled states
- Screen readers will properly announce disabled state
- Semantic labels preserved
- Visual indicators (reduced opacity) follow Material Design guidelines
