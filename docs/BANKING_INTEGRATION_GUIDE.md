# Banking Integration - Quick Start Guide

## How to Add Banking to Settings Menu

To make the banking feature accessible from the app, add a menu item in the settings page.

### Option 1: Add to Settings Menu

Edit `lib/settings/pages/settings_page.dart`:

```dart
// Add import
import 'package:io_caravella_egm/banking/pages/banking_page.dart';

// Add menu item in the settings list
ListTile(
  leading: Icon(Icons.account_balance),
  title: Text('Bank Connections'),
  subtitle: Text('Connect your bank account (Premium)'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BankingPage(),
      ),
    );
  },
),
```

### Option 2: Add to Home Page Actions

Edit `lib/home/home_page.dart` to add an action button:

```dart
// Add import
import 'package:io_caravella_egm/banking/pages/banking_page.dart';

// In AppBar actions
IconButton(
  icon: Icon(Icons.account_balance),
  tooltip: 'Banking',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BankingPage(),
      ),
    );
  },
),
```

### Option 3: Add Feature Flag

For controlled rollout, add a feature flag:

```dart
// In lib/config/app_config.dart
class AppConfig {
  // ... existing config ...
  
  static const bool bankingEnabled = false; // Change to true when ready
}

// In settings page
if (AppConfig.bankingEnabled)
  ListTile(
    // ... banking menu item
  ),
```

## Initialize Banking Provider

The banking notifier needs to be added to the Provider tree in `main.dart`:

```dart
import 'package:io_caravella_egm/banking/state/banking_notifier.dart';
import 'package:io_caravella_egm/banking/services/banking_service.dart';

// In _CaravellaAppState.build()
@override
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
      ChangeNotifierProvider(create: (_) => UserNameNotifier()),
      // Add banking notifier (with stub services until backend ready)
      ChangeNotifierProvider(
        create: (_) => BankingNotifier(
          bankingService: BankingService(
            supabaseUrl: 'https://your-project.supabase.co',
            supabaseAnonKey: 'your-anon-key',
          ),
        ),
      ),
    ],
    // ... rest of app
  );
}
```

**Note**: Until you configure Supabase backend, the banking service will show "NOT_IMPLEMENTED" errors, which is expected behavior.

## Testing the UI

Even without backend setup, you can test the UI:

1. Add banking menu item to settings
2. Run the app
3. Navigate to Banking page
4. You should see:
   - "Premium Feature" message (since RevenueCat is not configured)
   - "Upgrade to Premium" button (non-functional until RevenueCat setup)
   - Error messages guiding you to setup instructions

This confirms the UI works correctly before investing in backend infrastructure.

## When Ready for Production

1. Complete setup from `docs/BANKING_SETUP.md`
2. Update `BankingService` with real Supabase URLs
3. Update `PremiumService` with real RevenueCat integration
4. Add required packages to `pubspec.yaml`:
   ```yaml
   supabase_flutter: ^2.5.0
   purchases_flutter: ^6.29.0
   ```
5. Remove stub implementations
6. Test thoroughly with sandbox credentials
7. Deploy to production

## Rollback Plan

If you need to hide the feature:

1. Set `AppConfig.bankingEnabled = false`
2. Or comment out the menu item
3. The code remains in the codebase but is not accessible to users

No data cleanup needed since no data is stored locally.
