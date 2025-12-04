# New Home Page Architecture

## Component Hierarchy

```
NewHomePage (StatefulWidget)
├── Scaffold
│   ├── body: SafeArea
│   │   └── SingleChildScrollView
│   │       └── Column
│   │           ├── OurTabHeader
│   │           │   ├── Row (Avatar + Greeting)
│   │           │   │   ├── CircleAvatar
│   │           │   │   └── Text ("Ciao, {name} 👋")
│   │           │   └── Stack (Notification Bell + Badge)
│   │           │       ├── IconButton (notifications_outlined)
│   │           │       └── Badge (red dot if hasNotifications)
│   │           │
│   │           ├── GlobalBalanceCard
│   │           │   └── Container (rounded, shadowed)
│   │           │       └── Column
│   │           │           ├── Text ("Il tuo bilancio totale")
│   │           │           ├── Text (large amount, colored)
│   │           │           └── Row (indicators)
│   │           │               ├── _BalanceIndicator ("Ti devono")
│   │           │               └── _BalanceIndicator ("Devi")
│   │           │
│   │           └── GroupListSection
│   │               ├── Row (Section Header)
│   │               │   ├── Text ("Gruppi Attivi")
│   │               │   └── TextButton ("Vedi tutti >")
│   │               │
│   │               └── ListView.builder
│   │                   └── GroupCardWidget (for each group)
│   │                       └── Container (card)
│   │                           └── Row
│   │                               ├── Container (emoji box)
│   │                               ├── Column (group info)
│   │                               │   ├── Text (name)
│   │                               │   └── Text (last activity)
│   │                               └── Column (amount)
│   │                                   ├── Text (amount)
│   │                                   └── Text (status label)
│   │
│   ├── floatingActionButton: FloatingActionButton.extended
│   │   ├── Icon (add)
│   │   └── Text ("Nuovo")
│   │
│   └── bottomNavigationBar: BottomAppBar
│       └── Row
│           ├── NavItem (Home)
│           ├── NavItem (Amici)
│           ├── SizedBox (space for FAB)
│           ├── NavItem (Attività)
│           └── NavItem (Profilo)
```

## Data Flow

```
┌─────────────────────────────────────────────────────┐
│                   NewHomePage                       │
│                  (Main Container)                   │
└──────────────────────┬──────────────────────────────┘
                       │
                       ├── Manages State:
                       │   - _balance (GlobalBalance)
                       │   - _groups (List<GroupItem>)
                       │   - _selectedIndex (int)
                       │   - _loading (bool)
                       │
                       ├── Data Loading:
                       │   └── HomeDataService
                       │       ├── calculateGlobalBalance()
                       │       └── getActiveGroupItems()
                       │           └── ExpenseGroupStorageV2
                       │               ├── getActiveGroups()
                       │               └── getPinnedTrip()
                       │
                       ├── Passes Data Down:
                       │   ├── OurTabHeader
                       │   │   └── userName, hasNotifications
                       │   ├── GlobalBalanceCard
                       │   │   └── balance (GlobalBalance)
                       │   └── GroupListSection
                       │       └── groups (List<GroupItem>)
                       │           └── GroupCardWidget (each item)
                       │
                       └── Handles Events:
                           ├── onNotificationTap()
                           ├── onFabPressed()
                           ├── onGroupTap(GroupItem)
                           ├── onViewAllGroups()
                           └── onBottomNavTap(int)
```

## State Management

### Current State (Mock Data)

```dart
_NewHomePageState {
  int _selectedIndex = 0;
  GlobalBalance _mockBalance = const GlobalBalance(...);
  List<GroupItem> _mockGroups = [...];
}
```

### Future State (Real Data)

```dart
_NewHomePageState {
  int _selectedIndex = 0;
  GlobalBalance _balance;
  List<GroupItem> _groups;
  bool _loading = true;
  String _userName = '';
  
  @override
  void initState() {
    _loadData();
    _loadUserName();
  }
  
  Future<void> _loadData() async {
    // Fetch from service
  }
}
```

## Models

### GlobalBalance

```dart
class GlobalBalance {
  final double total;      // Net balance
  final double owedToYou;  // Positive amounts
  final double youOwe;     // Negative amounts (as positive)
  
  // Methods: fromJson, toJson, copyWith
}
```

### GroupItem

```dart
class GroupItem {
  final String id;
  final String name;
  final DateTime lastActivity;
  final double amount;
  final GroupStatus status;  // positive/negative/settled
  final String? emoji;
  
  // Methods: fromJson, toJson, copyWith
}
```

### GroupStatus (Enum)

```dart
enum GroupStatus {
  positive,  // You're owed money (green)
  negative,  // You owe money (red)
  settled,   // Balanced (gray)
}
```

## Widget Communication

### Parent → Child (Props)

```
NewHomePage
    ↓ userName, hasNotifications
OurTabHeader

NewHomePage
    ↓ balance, currency
GlobalBalanceCard

NewHomePage
    ↓ groups, onViewAll, onGroupTap
GroupListSection
    ↓ group, onTap, currency
GroupCardWidget
```

### Child → Parent (Callbacks)

```
OurTabHeader
    ↑ onNotificationTap()
NewHomePage

GroupCardWidget
    ↑ onTap()
GroupListSection
    ↑ onGroupTap(GroupItem)
NewHomePage

FloatingActionButton
    ↑ onPressed()
NewHomePage
```

## Theme & Styling

### Color Palette

```dart
Background:     #F8F9FA  (Light gray)
Primary:        #009688  (Teal)
Positive:       #2ECC71  (Green)
Negative:       #E74C3C  (Red)
Settled:        #95A5A6  (Gray)

Surface:        theme.colorScheme.surfaceContainer
OnSurface:      theme.colorScheme.onSurface
OnVariant:      theme.colorScheme.onSurfaceVariant
```

### Typography

```dart
Font Family:    Montserrat
Greeting:       titleLarge, w600
Balance Title:  titleMedium, w500
Balance Amount: headlineLarge, w700, 36px
Group Name:     titleMedium, w600
Last Activity:  bodySmall
Section Title:  titleLarge, w600
```

### Spacing

```dart
Page Padding:   16px horizontal, 12px vertical
Card Radius:    20px (balance), 16px (groups)
Card Shadow:    12px blur, 4px offset, 0.08 alpha
Card Padding:   20px (balance), 16px (groups)
Icon Spacing:   12px, 16px
```

## Navigation Structure

```
NewHomePage (index 0)
├── Home Tab → Stay on current page
├── Amici Tab → Navigate to friends page
├── Attività Tab → Navigate to activity/history
├── Profilo Tab → Navigate to profile/settings
└── FAB → Show create group dialog
```

## Event Flow Examples

### User Taps a Group Card

```
1. User taps GroupCardWidget
2. GroupCardWidget.onTap() called
3. GroupListSection.onGroupTap(group) called
4. NewHomePage._onGroupTap(group) called
5. Navigate to group details page
```

### User Pulls to Refresh

```
1. User pulls down on ScrollView
2. RefreshIndicator triggers onRefresh
3. _loadData() called
4. HomeDataService fetches new data
5. setState() updates _balance and _groups
6. UI rebuilds with new data
```

### App Starts

```
1. NewHomePage.initState() called
2. _loadData() fetches balance and groups
3. _loadUserName() fetches user name
4. setState() triggers rebuild
5. UI shows loading state
6. Data arrives
7. setState() triggers rebuild
8. UI shows loaded data
```

## Error Handling

```dart
try {
  final balance = await HomeDataService.calculateGlobalBalance();
  final groups = await HomeDataService.getActiveGroupItems();
  setState(() {
    _balance = balance;
    _groups = groups;
    _loading = false;
  });
} catch (e) {
  LoggerService.warning('Error loading home data: $e');
  // Show error state or fallback
  setState(() {
    _loading = false;
    _error = e.toString();
  });
}
```

## Performance Optimization

### Current Optimizations

1. **Const Constructors** - All widgets use const where possible
2. **ListView.builder** - Lazy loading for group list
3. **SingleChildScrollView** - Efficient scrolling
4. **Material** - Proper ink splash rendering
5. **NeverScrollableScrollPhysics** - Nested list optimization

### Future Optimizations

1. **Memoization** - Cache balance calculations
2. **Pagination** - Load groups in batches
3. **Image Caching** - Cache avatar images
4. **Debouncing** - Debounce refresh actions
5. **AutomaticKeepAlive** - Preserve state on navigation

## Testing Strategy

### Unit Tests
- ✅ GlobalBalance model serialization
- ✅ GroupItem model serialization
- ✅ Status determination logic
- ✅ Date formatting logic

### Widget Tests
- ✅ OurTabHeader renders correctly
- ✅ GlobalBalanceCard displays data
- ✅ GroupCardWidget shows status
- ✅ GroupListSection handles empty state
- ✅ NewHomePage renders complete UI

### Integration Tests
- Navigation flow
- Data loading
- Pull to refresh
- Error handling
- State persistence

### E2E Tests
- User journey: View groups → Tap group → View details
- User journey: Create new group via FAB
- User journey: Navigate bottom tabs

## Dependencies

```yaml
flutter:
  sdk: flutter

# From caravella_core_ui package:
caravella_core_ui:
  - Material 3 theme
  - Base widgets

# Direct dependencies:
intl: ^0.20.2  # For date formatting

# From existing app:
caravella_core:
  - ExpenseGroup model
  - ExpenseGroupStorageV2
  - LoggerService
```

## File Size Breakdown

```
lib/home/models/
  global_balance.dart       ~1.4 KB
  group_item.dart           ~2.4 KB

lib/home/new_home/
  new_home_page.dart        ~6.1 KB
  demo_app.dart             ~0.7 KB
  
lib/home/new_home/widgets/
  our_tab_header.dart       ~3.0 KB
  global_balance_card.dart  ~4.4 KB
  group_list_section.dart   ~3.1 KB
  group_card_widget.dart    ~4.6 KB

test/
  new_home_page_test.dart   ~8.9 KB

docs/
  NEW_HOME_PAGE.md          ~6.3 KB
  (this file)               ~9.0 KB
  
Total:                      ~50 KB
```

## Browser/Platform Support

- ✅ Android 6.0+ (API 23+)
- ✅ iOS 12.0+
- ✅ Web (responsive, mobile-first)
- ✅ Desktop (macOS, Windows, Linux)

## Accessibility Features

- Semantic labels for screen readers
- High contrast color ratios (WCAG AA)
- Touch targets minimum 48x48 dp
- Keyboard navigation support
- Focus indicators
- RTL language support
