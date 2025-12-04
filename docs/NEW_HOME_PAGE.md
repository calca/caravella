# New Home Page Implementation

This document describes the new home page implementation for the Caravella app.

## Overview

The new home page features a modern, Material 3 design with the following components:

1. **Custom Header** - Avatar, personalized greeting, and notification bell with badge
2. **Dashboard Card** - Global balance display with breakdown
3. **Active Groups List** - Scrollable list of group cards
4. **Floating Action Button (FAB)** - Centered button for adding new groups/expenses
5. **Bottom Navigation** - 4-item navigation bar

## File Structure

```
lib/home/
├── models/
│   ├── global_balance.dart    # Model for global balance data
│   └── group_item.dart         # Model for group items in the list
├── new_home/
│   ├── new_home_page.dart      # Main page widget
│   ├── demo_app.dart           # Standalone demo app
│   └── widgets/
│       ├── our_tab_header.dart        # Custom header widget
│       ├── global_balance_card.dart   # Balance dashboard card
│       ├── group_list_section.dart    # Groups list section
│       └── group_card_widget.dart     # Individual group card
```

## Data Models

### GlobalBalance

Represents the user's total balance across all groups:

```dart
class GlobalBalance {
  final double total;      // Overall balance
  final double owedToYou;  // Amount others owe to you
  final double youOwe;     // Amount you owe to others
}
```

### GroupItem

Represents a group in the active groups list:

```dart
class GroupItem {
  final String id;
  final String name;
  final DateTime lastActivity;
  final double amount;
  final GroupStatus status;  // positive, negative, or settled
  final String? emoji;
}
```

## Widgets

### OurTabHeader

Custom header with avatar, greeting, and notification bell.

**Props:**
- `userName` (String, required) - User's name for greeting
- `hasNotifications` (bool) - Whether to show notification badge
- `onNotificationTap` (VoidCallback?) - Callback for notification icon tap
- `avatarImage` (String?) - Optional avatar image path

### GlobalBalanceCard

Dashboard card displaying the global balance with visual indicators.

**Props:**
- `balance` (GlobalBalance, required) - Balance data to display
- `currency` (String) - Currency symbol (default: '€')

**Features:**
- Dynamic color based on balance (green for positive, red for negative)
- Breakdown indicators for "Ti devono" and "Devi"
- Rounded corners with subtle shadow

### GroupListSection

Section containing the active groups list with header and action.

**Props:**
- `groups` (List<GroupItem>, required) - List of groups to display
- `onViewAll` (VoidCallback?) - Callback for "Vedi tutti" button
- `onGroupTap` (Function(GroupItem)?) - Callback when group is tapped

### GroupCardWidget

Individual card widget for displaying a group.

**Props:**
- `group` (GroupItem, required) - Group data to display
- `onTap` (VoidCallback?) - Callback when card is tapped
- `currency` (String) - Currency symbol (default: '€')

**Features:**
- Status-based color coding (green/red/gray)
- Emoji display
- Last activity formatting
- Balance display with direction indicator

## Theme & Colors

The implementation uses the existing Caravella theme with these specific colors:

- **Background**: #F8F9FA (light gray)
- **Primary**: #009688 (teal - from existing theme)
- **Positive**: #2ECC71 (green)
- **Negative**: #E74C3C (red)
- **Font**: Montserrat (from existing theme)

## Usage

### Standalone Demo

To run the new home page independently:

```bash
flutter run lib/home/new_home/demo_app.dart
```

### Integration with Main App

To integrate the new home page into the main app:

1. Import the new home page:
```dart
import 'package:io_caravella_egm/home/new_home/new_home_page.dart';
```

2. Replace the current home page widget in your navigation:
```dart
home: const NewHomePage(),
```

3. Connect real data by replacing mock data in `_NewHomePageState`:
   - Replace `_mockBalance` with actual balance calculation
   - Replace `_mockGroups` with data from `ExpenseGroupStorageV2`
   - Implement navigation callbacks

### Connecting to Real Data

Example of connecting to real expense data:

```dart
// In _NewHomePageState
Future<void> _loadData() async {
  // Load groups
  final activeGroups = await ExpenseGroupStorageV2.getActiveGroups();
  
  // Calculate global balance
  final balance = _calculateGlobalBalance(activeGroups);
  
  // Convert to GroupItems
  final groupItems = activeGroups.map((group) {
    return GroupItem(
      id: group.id,
      name: group.title,
      lastActivity: group.timestamp,
      amount: _calculateGroupBalance(group),
      status: _determineStatus(_calculateGroupBalance(group)),
      emoji: _getGroupEmoji(group),
    );
  }).toList();
  
  setState(() {
    _balance = balance;
    _groups = groupItems;
  });
}
```

## Testing

Tests are provided in `test/new_home_page_test.dart` covering:

- Model serialization/deserialization
- Widget rendering
- User interaction handling
- Edge cases (empty states, different statuses)

Run tests with:

```bash
flutter test test/new_home_page_test.dart
```

## Future Enhancements

Potential improvements for future iterations:

1. **Pull-to-refresh** - Add refresh indicator to update data
2. **Skeleton loaders** - Show loading states while fetching data
3. **Animations** - Add transitions and micro-interactions
4. **Search/Filter** - Add ability to search and filter groups
5. **Settings** - Add gear icon in header for quick settings access
6. **Real-time updates** - Subscribe to data changes for live updates
7. **Accessibility** - Add semantic labels and screen reader support
8. **Localization** - Extract all strings to localization files

## Notes

- The current implementation uses mock data for demonstration
- Currency symbol defaults to '€' but can be customized
- User name is currently hardcoded as "Alessandro"
- Navigation callbacks show snackbars as placeholders
- The page uses `SafeArea` to respect device notches and system UI

## Related Files

- `lib/home/home_page.dart` - Existing home page implementation
- `packages/caravella_core_ui/lib/themes/caravella_themes.dart` - Theme definitions
- `packages/caravella_core/lib/model/expense_group.dart` - ExpenseGroup model
- `packages/caravella_core/lib/data/storage/expense_group_storage_v2.dart` - Data storage
