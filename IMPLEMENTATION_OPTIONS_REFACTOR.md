# Options Menu Refactor - Implementation Summary

## Overview
This implementation refactors the options menu in the expense group detail page according to the requirements in the Italian issue. The changes improve the user experience by making the favorite/pin action more accessible and reorganizing the options into a dedicated settings page.

## Changes Made

### 1. Pin/Unpin Functionality on Avatar
**Files Modified:**
- `lib/manager/details/widgets/group_header.dart`
- `lib/manager/details/pages/expense_group_detail_page.dart`

**Changes:**
- Made the group avatar tappable to toggle pin/unpin
- Added `onPinToggle` callback parameter to `GroupHeader` widget
- Added semantic labels for accessibility
- Pin/favorite icon now always visible (not just when pinned/archived)
- Icon changes from `favorite_border` (unpinned) to `favorite` (pinned)
- Icon color changes to primary color when pinned for better visual feedback
- Added `_handlePinToggle()` method in detail page to handle the pin toggle action
- Shows toast notification after pin/unpin action

### 2. New Group Settings Page
**Files Created:**
- `lib/manager/details/pages/group_settings_page.dart`

**Structure:**
The new settings page is organized into three sections:

#### Group Section
Contains navigation to different tabs of the edit page:
- **General** (Generali): Opens edit page at tab 0 - Name, period, currency settings
- **Participants** (Partecipanti): Opens edit page at tab 1 - Manage people sharing costs
- **Categories** (Categorie): Opens edit page at tab 2 - Organize expenses by type
- **Other** (Altro): Opens edit page at tab 3 - Background, notifications

#### Export & Share Section
- **Export Options**: Opens the export options bottom sheet
- Disabled when there are no expenses to export

#### Dangerous Section (Danger Zone)
- **Archive/Unarchive**: Archives or unarchives the group
- **Delete Group**: Shows confirmation dialog before deleting

### 3. Edit Page Tab Navigation
**Files Modified:**
- `lib/manager/group/pages/expenses_group_edit_page.dart`

**Changes:**
- Added `initialTab` parameter to `ExpensesGroupEditPage` and `_GroupFormScaffold`
- Modified `TabController` initialization to use `initialIndex` from the parameter
- Default value is 0 (General tab)
- Tab indices: 0=General, 1=Participants, 2=Categories, 3=Other

### 4. Navigation Updates
**Files Modified:**
- `lib/manager/details/pages/expense_group_detail_page.dart`

**Changes:**
- Replaced `_showOptionsSheet()` method with `_showSettingsPage()`
- Updated `GroupActions` widget call to use `_showSettingsPage` instead of `_showOptionsSheet`
- Removed import of `options_sheet.dart`
- Added import of `group_settings_page.dart`
- Settings page receives callbacks for group updates, deletion, and export options

### 5. Localization
**Files Modified:**
- `lib/l10n/app_en.arb`
- `lib/l10n/app_it.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_pt.arb`
- `lib/l10n/app_zh.arb`

**New Strings Added:**
- `danger_zone`: Section title for dangerous actions
- `export_options_desc`: Description for export options

**Existing Strings Used:**
- `settings`: Page title
- `group`: Group section title
- `segment_general`: General tab name
- `settings_general_desc`: General section description
- `participants`: Participants section name
- `participants_description`: Participants description
- `categories`: Categories section name
- `categories_description`: Categories description
- `segment_other`: Other tab name
- `other_settings_desc`: Other section description
- `export_share`: Export & Share section title
- `export_options`: Export options item title
- `archive`/`unarchive`: Archive action labels
- `delete_group`: Delete action label
- `pin_group`/`unpin_group`: Pin/unpin action labels

## User Experience Changes

### Before
1. Users had to open the options menu (three-dot menu) to pin/unpin a group
2. Options were presented in a flat list in a bottom sheet
3. No clear separation between safe and dangerous actions

### After
1. Users can now tap directly on the group avatar to pin/unpin
2. Pin/favorite icon is always visible next to the avatar
3. Options are organized into logical sections in a dedicated settings page
4. Clear visual hierarchy with "Danger Zone" for destructive actions
5. Easy navigation to specific editing sections (General, Participants, Categories, Other)
6. Export options are grouped together in their own section

## Technical Notes

### State Management
- Uses `ExpenseGroupNotifier` for pin/unpin operations
- Calls `updateGroupPin()` which handles storage and shortcuts
- Refreshes group data after pin toggle to reflect changes
- Toast notifications provide immediate feedback

### Accessibility
- Added semantic labels to the tappable avatar
- Button semantics with enabled state
- Clear labeling of pin/unpin action
- Proper color contrast for disabled states

### Navigation Flow
```
Detail Page → Settings Page → Edit Page (specific tab)
                            ↓
                       Export Options Sheet
                            ↓
                       Confirm Dialogs (Archive/Delete)
```

### Backwards Compatibility
- No breaking changes to existing data structures
- All existing functionality preserved
- Old `OptionsSheet` widget still exists for history feature (different usage)

## Files Not Modified
- `lib/manager/details/widgets/options_sheet.dart` - Kept for potential future use
- `lib/manager/history/widgets/history_options_sheet.dart` - Different context, not affected

## Testing Recommendations

### Manual Testing
1. **Pin/Unpin on Avatar**
   - Tap avatar to pin group
   - Verify favorite icon appears filled and colored
   - Tap again to unpin
   - Verify favorite icon returns to outline
   - Check toast notifications appear

2. **Settings Page Navigation**
   - Open settings from detail page
   - Test navigation to each edit tab (General, Participants, Categories, Other)
   - Verify correct tab opens in edit page
   - Test export options navigation
   - Test archive action
   - Test delete action with confirmation

3. **Edge Cases**
   - Archived groups: Pin option should be disabled
   - Empty groups: Export option should be disabled
   - Verify all actions refresh data properly

### Automated Testing
- Run existing widget tests
- Run integration tests for group management
- Verify accessibility tests pass

## Future Enhancements

Potential improvements for future iterations:
1. Add animation when pin icon changes state
2. Add haptic feedback on avatar tap
3. Consider adding quick actions in settings page (e.g., duplicate group)
4. Add undo functionality for archive action
5. Consider adding group statistics in settings page
