# RevenueCat Integration Guide

This guide explains the RevenueCat integration for subscription management in the Caravella multi-device sync feature.

## Overview

The app uses RevenueCat to manage two subscription tiers:
- **BASIC**: Limited features (max 5 groups, max 5 participants per group)
- **PREMIUM**: Unlimited features (unlimited groups and participants)

## Setup

### 1. RevenueCat Dashboard Configuration

1. Create a RevenueCat account at https://www.revenuecat.com/
2. Create a new project
3. Configure products in the dashboard:
   - Product ID: `caravella_basic_monthly`
   - Product ID: `caravella_premium_monthly`
4. Configure entitlements:
   - Entitlement ID: `basic` (for BASIC plan)
   - Entitlement ID: `premium` (for PREMIUM plan)
5. Get your API key from the dashboard

### 2. App Configuration

Add the RevenueCat API key to your environment:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=REVENUECAT_API_KEY=your_revenuecat_api_key
```

Or in `main.dart`:

```dart
import 'package:io_caravella_egm/sync/sync_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SyncInitializer.initialize(
    revenueCatApiKey: 'your_revenuecat_api_key',
  );
  
  runApp(const YourApp());
}
```

### 3. App Store Configuration

#### iOS (App Store Connect)

1. Create in-app purchase products in App Store Connect
2. Product IDs must match:
   - `caravella_basic_monthly`
   - `caravella_premium_monthly`
3. Configure as auto-renewable subscriptions
4. Add to RevenueCat dashboard

#### Android (Google Play Console)

1. Create subscription products in Google Play Console
2. Product IDs must match:
   - `caravella_basic_monthly`
   - `caravella_premium_monthly`
3. Configure as subscriptions
4. Add to RevenueCat dashboard

## Subscription Tiers

### BASIC Plan

**Limits:**
- Maximum 5 shared groups
- Maximum 5 participants per group

**Features:**
- Real-time sync across devices
- End-to-end encryption
- QR code sharing
- Device management

**Price:** Set in App Store/Play Store

### PREMIUM Plan

**Limits:**
- Unlimited shared groups
- Unlimited participants per group

**Features:**
- All BASIC features
- Priority support
- Advanced features
- No restrictions

**Price:** Set in App Store/Play Store

## User Flow

### Sharing a Group (Device A)

1. User clicks "Share via QR" in group options
2. App checks if user is authenticated (Supabase Auth)
3. App checks subscription status via RevenueCat
4. If no active subscription → Show subscription page
5. If subscription active → Check limits:
   - Count current shared groups
   - Count participants in this group
   - Verify against subscription tier limits
6. If limits OK → Generate QR code
7. If limits exceeded → Show error with upgrade option

### Scanning QR (Device B)

1. User opens QR scanner
2. App checks if user is authenticated (Supabase Auth)
3. User scans QR code
4. App checks subscription status via RevenueCat
5. If no active subscription → Show subscription page
6. If subscription active → Check limits:
   - Count current shared groups
   - Count participants in scanned group
   - Verify against subscription tier limits
7. If limits OK → Join group and start sync
8. If limits exceeded → Show error with upgrade option

## Error Messages

### Group Limit Reached (BASIC)

```
You have reached the maximum of 5 shared groups for your BASIC plan.
Upgrade to PREMIUM for unlimited groups.
```

### Participant Limit Reached (BASIC)

```
This group has X participants. Your BASIC plan allows maximum 5 participants per group.
Upgrade to PREMIUM for unlimited participants.
```

### No Active Subscription

```
You need an active subscription to join shared groups.
```

## API Reference

### RevenueCatService

Main service for subscription management:

```dart
final revenueCat = RevenueCatService();

// Initialize
await revenueCat.initialize(
  apiKey: 'your_api_key',
  userId: 'user_id_from_supabase',
);

// Check subscription status
final status = await revenueCat.getSubscriptionStatus();
print('Tier: ${status.tier}');
print('Active: ${status.isActive}');

// Check if user can share
final canShare = await revenueCat.canShareGroup(currentGroupCount);

// Check if user can add participant
final canAdd = await revenueCat.canAddParticipant(currentParticipantCount);

// Get offerings
final offerings = await revenueCat.getOfferings();

// Purchase
final package = offerings?.current?.availablePackages.first;
if (package != null) {
  await revenueCat.purchasePackage(package);
}

// Restore purchases
await revenueCat.restorePurchases();
```

### SubscriptionTier

Enum for subscription tiers:

```dart
enum SubscriptionTier {
  none,   // No subscription
  basic,  // BASIC plan
  premium, // PREMIUM plan
}
```

### SubscriptionLimits

Configuration for each tier:

```dart
final limits = SubscriptionLimits.forTier(SubscriptionTier.basic);
print('Max groups: ${limits.maxSharedGroups}'); // 5
print('Max participants: ${limits.maxParticipantsPerGroup}'); // 5

final premiumLimits = SubscriptionLimits.forTier(SubscriptionTier.premium);
print('Unlimited: ${premiumLimits.unlimitedGroups}'); // true
```

### SubscriptionStatus

Current subscription status:

```dart
final status = await revenueCat.getSubscriptionStatus();

// Check status
if (status.isActive) {
  print('Active ${status.tier} subscription');
}

// Check limits
final canShare = status.canShareGroup(currentCount);
final canAdd = status.canAddParticipant(participantCount);

// Get limits
final limits = status.limits;
```

## Testing

### Test Subscriptions

Both App Store and Google Play provide sandbox testing:

**iOS:**
1. Create sandbox tester account in App Store Connect
2. Sign out of App Store on device
3. Install app and try to purchase
4. Sign in with sandbox account when prompted

**Android:**
1. Add test account in Google Play Console
2. Join test track
3. Install app from Play Store
4. Purchases will be in test mode

### RevenueCat Test Mode

RevenueCat automatically detects sandbox purchases and marks them accordingly.

## Backwards Compatibility

If RevenueCat is not configured (no API key):
- App allows all features without restrictions
- Premium tier is assumed by default
- No subscription checks are performed
- This maintains backwards compatibility for existing users

## Security Considerations

1. **API Key**: Never commit API keys to version control
2. **User ID**: Link RevenueCat users to Supabase Auth users
3. **Receipt Validation**: RevenueCat handles receipt validation server-side
4. **Entitlements**: Always check entitlements, not raw product IDs
5. **Offline**: Cache subscription status for offline graceful degradation

## Troubleshooting

### Purchase Not Showing

1. Check product IDs match in App Store/Play Store and RevenueCat
2. Verify products are approved and active
3. Check RevenueCat dashboard for any errors
4. Verify app bundle ID matches

### Subscription Not Syncing

1. Check RevenueCat webhook configuration
2. Verify API key is correct
3. Check user ID is set correctly
4. Review RevenueCat dashboard logs

### Limits Not Working

1. Verify entitlement IDs in RevenueCat dashboard
2. Check subscription status returns correct tier
3. Verify limit checking logic in code
4. Review logs for any errors

## Support

For RevenueCat-specific issues:
- Documentation: https://docs.revenuecat.com/
- Support: https://www.revenuecat.com/support/

For app-specific issues:
- Check logs using `LoggerService`
- Review subscription status in app
- Contact app support

## Future Enhancements

Planned improvements:
1. Annual subscription options
2. Family sharing support
3. Lifetime purchase option
4. Promotional offers
5. Grace periods for failed payments
6. Subscription pause/resume
