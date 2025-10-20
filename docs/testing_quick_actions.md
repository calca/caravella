# Testing Android Quick Actions

## Prerequisites
- Android device or emulator with Android 7.1 (API 25) or higher
- Caravella app built and installed

## Test Scenarios

### 1. Basic Functionality
**Steps:**
1. Create at least 3 expense groups
2. Add some expenses to each group
3. Pin one of the groups (from group detail page)
4. Exit the app
5. Long-press the Caravella app icon on the home screen/launcher

**Expected Result:**
- Quick Actions menu appears
- Pinned group appears first with 📌 emoji
- 2-3 most recently updated groups appear below
- Each shortcut shows the group title (truncated to 25 chars if needed)

### 2. Shortcut Tap Navigation
**Steps:**
1. Long-press the app icon
2. Tap on one of the shortcuts

**Expected Result:**
- App opens (or comes to foreground)
- Navigates directly to the expense detail page for the selected group
- Group title and data are displayed correctly

### 3. Pinned Group Priority
**Steps:**
1. Create multiple groups
2. Pin one group
3. Update other groups (add expenses, modify)
4. Long-press app icon

**Expected Result:**
- Pinned group always appears first, regardless of last update time
- Shows 📌 emoji prefix on pinned group
- Up to 3 other recent groups shown after pinned group

### 4. Dynamic Update
**Steps:**
1. Open app
2. Create a new group
3. Exit app
4. Long-press app icon

**Expected Result:**
- New group appears in the shortcuts list
- Shortcuts are sorted by most recent update

### 5. Group Deletion
**Steps:**
1. Note which shortcuts are visible
2. Open app and delete one of the groups shown in shortcuts
3. Exit app
4. Long-press app icon

**Expected Result:**
- Deleted group no longer appears in shortcuts
- Remaining shortcuts are still shown

### 6. No Groups Scenario
**Steps:**
1. Fresh install or clear app data
2. Long-press app icon

**Expected Result:**
- No shortcuts appear (or minimal default shortcuts if any)

### 7. Maximum Shortcuts
**Steps:**
1. Create 10+ groups
2. Pin one group
3. Long-press app icon

**Expected Result:**
- Maximum of 4 shortcuts shown
- 1 pinned + 3 most recent non-pinned groups

### 8. Archived Groups
**Steps:**
1. Create groups
2. Archive some groups
3. Long-press app icon

**Expected Result:**
- Only active (non-archived) groups appear in shortcuts
- Archived groups are excluded

## Known Issues
- None at this time

## Performance Notes
- Shortcuts update asynchronously and may take a moment to appear
- Failed updates are silent to avoid disrupting user experience
- Shortcut data is cached by Android system until next update
