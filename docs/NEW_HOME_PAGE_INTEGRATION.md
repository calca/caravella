# New Home Page Integration Guide

This guide explains how to integrate the new home page into the existing Caravella app.

## Visual Layout

```
┌─────────────────────────────────────────────┐
│  👤 Ciao, Alessandro 👋          🔔(•)      │  ← Header
├─────────────────────────────────────────────┤
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │  Il tuo bilancio totale               │ │
│  │                                       │ │
│  │  +150.50 €                            │ │  ← Balance Card
│  │                                       │ │
│  │  ⬆️ Ti devono    ⬇️ Devi              │ │
│  │  200.00 €       49.50 €               │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  Gruppi Attivi          Vedi tutti >        │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ 🏖️ Vacanza Roma         +75.50 €      │ │
│  │    Oggi                  Ti devono     │ │
│  └───────────────────────────────────────┘ │
│                                             │  ← Groups List
│  ┌───────────────────────────────────────┐ │
│  │ 🍕 Cena Amici           -25.00 €      │ │
│  │    Ieri                  Devi          │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ ⛰️ Weekend Montagna      Saldato      │ │
│  │    3 giorni fa                         │ │
│  └───────────────────────────────────────┘ │
│                                             │
├─────────────────────────────────────────────┤
│  🏠 Home  👥 Amici  [+]  📊 Attività  👤   │  ← Bottom Nav + FAB
└─────────────────────────────────────────────┘
```

## Step-by-Step Integration

### Option 1: Replace Existing Home Page

If you want to completely replace the existing home page:

1. **Update `lib/main/caravella_home_page.dart`** or equivalent routing file:

```dart
import 'package:io_caravella_egm/home/new_home/new_home_page.dart';

// Replace the existing home page widget with:
home: const NewHomePage(),
```

### Option 2: Add as New Route

If you want to keep both versions and add navigation:

1. **Define the route** in your router or MaterialApp:

```dart
MaterialApp(
  routes: {
    '/': (context) => const HomePage(), // Existing
    '/new-home': (context) => const NewHomePage(), // New
  },
)
```

2. **Add navigation** from existing page:

```dart
Navigator.pushNamed(context, '/new-home');
```

### Option 3: Feature Flag

For A/B testing or gradual rollout:

```dart
import 'package:io_caravella_egm/home/home_page.dart';
import 'package:io_caravella_egm/home/new_home/new_home_page.dart';

// In your app configuration
final bool useNewHomePage = AppConfig.featureFlags['new_home_page'] ?? false;

// In your routing
home: useNewHomePage ? const NewHomePage() : const HomePage(),
```

## Connecting Real Data

The new home page currently uses mock data. Here's how to connect it to real data:

### 1. Create a Data Service

Create `lib/home/new_home/services/home_data_service.dart`:

```dart
import 'package:caravella_core/caravella_core.dart';
import '../../models/global_balance.dart';
import '../../models/group_item.dart';

class HomeDataService {
  /// Calculate global balance from all active groups
  static Future<GlobalBalance> calculateGlobalBalance() async {
    final groups = await ExpenseGroupStorageV2.getActiveGroups();
    
    double owedToYou = 0.0;
    double youOwe = 0.0;
    
    for (final group in groups) {
      final balance = _calculateGroupBalance(group);
      if (balance > 0) {
        owedToYou += balance;
      } else {
        youOwe += balance.abs();
      }
    }
    
    return GlobalBalance(
      total: owedToYou - youOwe,
      owedToYou: owedToYou,
      youOwe: youOwe,
    );
  }
  
  /// Convert ExpenseGroups to GroupItems
  static Future<List<GroupItem>> getActiveGroupItems() async {
    final groups = await ExpenseGroupStorageV2.getActiveGroups();
    
    return groups.map((group) {
      final balance = _calculateGroupBalance(group);
      return GroupItem(
        id: group.id,
        name: group.title,
        lastActivity: group.timestamp,
        amount: balance,
        status: _determineStatus(balance),
        emoji: _extractEmoji(group.title),
      );
    }).toList();
  }
  
  static double _calculateGroupBalance(ExpenseGroup group) {
    // TODO: Implement actual balance calculation logic
    // This should calculate the user's balance in this group
    return 0.0;
  }
  
  static GroupStatus _determineStatus(double balance) {
    if (balance > 0.01) return GroupStatus.positive;
    if (balance < -0.01) return GroupStatus.negative;
    return GroupStatus.settled;
  }
  
  static String? _extractEmoji(String title) {
    // Extract emoji from title if present
    final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true);
    final match = emojiRegex.firstMatch(title);
    return match?.group(0);
  }
}
```

### 2. Update NewHomePage to Use Real Data

Modify `lib/home/new_home/new_home_page.dart`:

```dart
class _NewHomePageState extends State<NewHomePage> {
  int _selectedIndex = 0;
  GlobalBalance _balance = const GlobalBalance(total: 0, owedToYou: 0, youOwe: 0);
  List<GroupItem> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    
    try {
      final balance = await HomeDataService.calculateGlobalBalance();
      final groups = await HomeDataService.getActiveGroupItems();
      
      if (mounted) {
        setState(() {
          _balance = balance;
          _groups = groups;
          _loading = false;
        });
      }
    } catch (e) {
      LoggerService.warning('Error loading home data: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // ... rest of the implementation
}
```

### 3. Add Pull-to-Refresh

Wrap the content in a `RefreshIndicator`:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          // ... existing content
        ),
      ),
    ),
    // ... rest of the scaffold
  );
}
```

### 4. Get User Name

Replace the hardcoded "Alessandro" with actual user data:

```dart
// In your state class
String _userName = '';

@override
void initState() {
  super.initState();
  _loadUserName();
  _loadData();
}

Future<void> _loadUserName() async {
  final userName = await UserNameNotifier.getUserName(); // Or your user service
  if (mounted) {
    setState(() => _userName = userName ?? 'Utente');
  }
}

// In the build method:
OurTabHeader(
  userName: _userName,
  hasNotifications: true,
  onNotificationTap: _onNotificationTap,
),
```

### 5. Implement Navigation Callbacks

```dart
void _onGroupTap(GroupItem group) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ExpenseGroupDetailPage(groupId: group.id),
    ),
  );
}

void _onViewAllGroups() {
  // Navigate to groups list page
  // Navigator.pushNamed(context, '/groups');
}

void _onFabPressed() {
  // Show bottom sheet to create new group
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const CreateGroupBottomSheet(),
  );
}

void _onNotificationTap() {
  // Navigate to notifications
  // Navigator.pushNamed(context, '/notifications');
}

void _onBottomNavTap(int index) {
  setState(() {
    _selectedIndex = index;
  });
  
  // Navigate based on index
  switch (index) {
    case 0: // Home - already here
      break;
    case 1: // Friends
      // Navigator.pushNamed(context, '/friends');
      break;
    case 2: // Activity
      // Navigator.pushNamed(context, '/activity');
      break;
    case 3: // Profile
      // Navigator.pushNamed(context, '/profile');
      break;
  }
}
```

## Localization

To add localization support, extract hardcoded strings:

1. Add keys to `lib/l10n/app_en.arb` and `app_it.arb`:

```json
{
  "home_greeting": "Ciao, {name} 👋",
  "home_balance_title": "Il tuo bilancio totale",
  "home_balance_owed_to_you": "Ti devono",
  "home_balance_you_owe": "Devi",
  "home_groups_title": "Gruppi Attivi",
  "home_groups_view_all": "Vedi tutti",
  "home_groups_empty": "Nessun gruppo attivo",
  "home_status_settled": "Saldato",
  "home_fab_new": "Nuovo",
  "home_nav_home": "Home",
  "home_nav_friends": "Amici",
  "home_nav_activity": "Attività",
  "home_nav_profile": "Profilo"
}
```

2. Update widgets to use localization:

```dart
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

// In build method:
final loc = gen.AppLocalizations.of(context);

Text(loc.home_balance_title),
Text(loc.home_balance_owed_to_you),
// etc.
```

## Testing the Integration

After integration, test the following:

1. ✅ Page loads without errors
2. ✅ Balance displays correctly
3. ✅ Groups list shows active groups
4. ✅ Tapping a group navigates to details
5. ✅ FAB opens create group dialog
6. ✅ Bottom navigation switches sections
7. ✅ Notification bell shows badge when applicable
8. ✅ Pull-to-refresh updates data
9. ✅ Empty state shows when no groups
10. ✅ Loading state shows while fetching data

## Rollback Plan

If issues arise, you can easily rollback:

1. Revert the routing changes
2. Or use the feature flag to disable: `AppConfig.featureFlags['new_home_page'] = false`
3. The old home page remains unchanged in `lib/home/home_page.dart`

## Performance Considerations

- Use `ListView.builder` for groups list (already implemented)
- Cache balance calculations
- Implement pagination for large group lists
- Use `const` constructors where possible (already implemented)
- Consider using `AutomaticKeepAliveClientMixin` for the page state

## Accessibility

To improve accessibility:

```dart
Semantics(
  label: loc.home_balance_card_label,
  child: GlobalBalanceCard(balance: _balance),
)
```

Add semantic labels to all interactive elements.

## Next Steps

After basic integration:

1. Connect to real expense calculation logic
2. Add user authentication/profile
3. Implement actual navigation routes
4. Add skeleton loaders for better UX
5. Implement notifications system
6. Add analytics tracking
7. Perform user acceptance testing
8. Monitor crash reports and fix issues
9. Gather user feedback
10. Iterate and improve based on feedback
