# New Home Page

Modern, Material 3-based home page for Caravella expense tracking app.

## Quick Start

### Run Demo

```bash
flutter run lib/home/new_home/demo_app.dart
```

### Run Tests

```bash
flutter test test/new_home_page_test.dart
```

## Structure

```
new_home/
├── README.md                        (this file)
├── new_home_page.dart               (main page widget)
├── demo_app.dart                    (standalone demo)
└── widgets/
    ├── our_tab_header.dart          (custom header)
    ├── global_balance_card.dart     (balance dashboard)
    ├── group_list_section.dart      (groups section)
    └── group_card_widget.dart       (individual group card)
```

## Features

- ✅ Custom header with avatar & notifications
- ✅ Global balance dashboard
- ✅ Active groups list with status indicators
- ✅ Centered FAB for new actions
- ✅ Bottom navigation (4 items)
- ✅ Material 3 design
- ✅ Status-based color coding
- ✅ Smart date formatting
- ✅ Empty state handling

## Usage

### Basic Integration

```dart
import 'package:io_caravella_egm/home/new_home/new_home_page.dart';

// In your app routing:
home: const NewHomePage(),
```

### With Real Data

```dart
// See docs/NEW_HOME_PAGE_INTEGRATION.md for complete guide

// 1. Create HomeDataService
// 2. Load balance and groups
// 3. Pass to NewHomePage
// 4. Handle navigation callbacks
```

## Components

### NewHomePage

Main page container with state management.

### OurTabHeader

Custom header with:
- Circular avatar
- Personalized greeting
- Notification bell with badge

### GlobalBalanceCard

Dashboard card showing:
- Total balance (colored)
- Amount owed to you
- Amount you owe

### GroupListSection

Groups list with:
- Section header
- View all action
- Scrollable cards

### GroupCardWidget

Individual group card with:
- Emoji/icon
- Group name
- Last activity
- Balance amount
- Status indicator

## Models

### GlobalBalance

```dart
class GlobalBalance {
  final double total;
  final double owedToYou;
  final double youOwe;
}
```

### GroupItem

```dart
class GroupItem {
  final String id;
  final String name;
  final DateTime lastActivity;
  final double amount;
  final GroupStatus status;
  final String? emoji;
}
```

## Theme

Colors:
- Background: `#F8F9FA`
- Primary: `#009688`
- Positive: `#2ECC71`
- Negative: `#E74C3C`
- Settled: `#95A5A6`

Font: Montserrat (from existing theme)

## Documentation

Full documentation available in `/docs`:

- `NEW_HOME_PAGE.md` - Overview & features
- `NEW_HOME_PAGE_INTEGRATION.md` - Integration guide
- `NEW_HOME_PAGE_ARCHITECTURE.md` - Technical details
- `NEW_HOME_PAGE_SUMMARY.md` - Complete summary

## Testing

Comprehensive tests in `test/new_home_page_test.dart`:

- ✅ Model serialization
- ✅ Widget rendering
- ✅ User interactions
- ✅ Edge cases
- ✅ Empty states

## Status

**✅ Production Ready**

- All components implemented
- Tests passing
- Documented
- Demo available
- Integration guide ready

## Next Steps

1. Review documentation
2. Test demo app
3. Choose integration strategy
4. Connect real data
5. Deploy

## Support

For questions or issues:
1. Check documentation in `/docs`
2. Review test cases
3. Run demo app for reference
4. See integration guide for examples
