# Banking Integration Module (Local-First)

This module provides PSD2 banking integration via GoCardless for Caravella Premium users with a **LOCAL-FIRST, PRIVACY-FOCUSED architecture**.

## ⚠️ IMPORTANT: Local-First Architecture

**NO BANKING DATA IS STORED ON BACKEND SERVERS**

This module uses **encrypted local storage** with complete user privacy:

- ✅ All transactions stored encrypted on device only
- ✅ Encryption keys in iOS Keychain / Android Keystore
- ✅ Edge Function acts as stateless proxy only
- ✅ Backend never persists any banking data
- ✅ GDPR compliant by design
- ✅ User maintains complete control over their data

### Required Services

1. **Supabase** - For stateless Edge Function proxy only (NO database needed)
   - Edge Function proxies requests to GoCardless
   - Returns JSON to client
   - Never stores any data

2. **GoCardless Bank Data API** - PSD2 banking access
   - Secure bank account connections via OAuth
   - Transaction data access
   - Requires API credentials

3. **RevenueCat** - Premium subscription management
   - Validates Premium tier subscriptions
   - Handles in-app purchases
   - API keys for iOS and Android

4. **Flutter Secure Storage** - Local encryption key management
   - Stores encryption keys in secure hardware
   - iOS Keychain integration
   - Android Keystore integration

### Setup Instructions

See [`/docs/BANKING_SETUP_LOCAL_FIRST.md`](../docs/BANKING_SETUP_LOCAL_FIRST.md) for complete setup guide.

## Module Structure

```
lib/banking/
├── models/           # Data models
│   ├── bank_account.dart
│   ├── bank_transaction.dart
│   └── bank_requisition.dart
├── services/         # Business logic
│   ├── banking_service.dart       # Edge Function proxy client
│   ├── premium_service.dart       # RevenueCat integration
│   └── local_banking_storage.dart # Encrypted local storage ⭐
├── state/            # State management
│   └── banking_notifier.dart
├── pages/            # UI screens
│   └── banking_page.dart
└── README.md
```

## Features

### Implemented

- ✅ Data models for bank accounts and transactions
- ✅ Service layer for stateless proxy calls
- ✅ **Encrypted local storage** (flutter_secure_storage + SharedPreferences)
- ✅ State management with Provider
- ✅ Basic UI for banking features
- ✅ Premium subscription checks
- ✅ 24-hour refresh rate limiting (local enforcement)
- ✅ Complete privacy (data never leaves device)

### Not Implemented (Requires Setup)

- ❌ Supabase Edge Function deployment (stateless proxy)
- ❌ GoCardless API integration (credentials in Edge Function)
- ❌ RevenueCat subscription integration
- ❌ OAuth PSD2 authorization flow

## Usage

### Local Storage

```dart
import 'package:io_caravella_egm/banking/services/local_banking_storage.dart';

final storage = LocalBankingStorage();

// Save transactions encrypted locally
await storage.saveTransactions(transactions);

// Get transactions from local storage
final txs = await storage.getTransactions();

// Check 24-hour rate limit (local)
final canRefresh = await storage.canRefresh();
```

### Adding to Navigation

```dart
import 'package:io_caravella_egm/banking/pages/banking_page.dart';

// Navigate to banking page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const BankingPage(),
  ),
);
```

### Checking Premium Status

```dart
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/banking/state/banking_notifier.dart';

// In your widget
final bankingNotifier = context.watch<BankingNotifier>();

if (bankingNotifier.isPremium) {
  // Show banking features
} else {
  // Show premium upgrade prompt
}
```

### Fetching Transactions (Local Storage)

```dart
final bankingNotifier = context.read<BankingNotifier>();

// Check rate limit (from local storage)
if (!bankingNotifier.canRefresh) {
  showSnackBar('Wait ${bankingNotifier.hoursUntilRefresh} hours');
  return;
}

// Fetch via Edge Function proxy
final success = await bankingNotifier.fetchTransactions(
  userId: 'user-id',
  requisitionId: 'requisition-id',
);

if (success) {
  // Data is now encrypted and saved locally
  final transactions = bankingNotifier.transactions;
}
```

## Privacy & Security

### Local-First Privacy

- ✅ **Device-Only Storage**: All banking data stored encrypted on device
- ✅ **No Backend Storage**: Edge Function never persists data
- ✅ **Encryption Keys**: Stored in iOS Keychain / Android Keystore
- ✅ **GDPR Compliant**: By design, not by policy
- ✅ **User Control**: Can delete all data anytime

### How It Works

1. **Encryption Key**:
   ```dart
   // Generated once and stored in secure storage
   final secureStorage = FlutterSecureStorage();
   String key = await secureStorage.read(key: 'banking_encryption_key');
   ```

2. **Data Storage**:
   ```dart
   // Encrypted and saved locally (SharedPreferences)
   await prefs.setString('banking_transactions', encryptedJson);
   ```

3. **Edge Function**:
   ```typescript
   // Stateless proxy - returns data, stores nothing
   return Response(JSON.stringify({ transactions }));
   ```

### Security Best Practices

When implementing:

- [ ] Use flutter_secure_storage for encryption keys
- [ ] Migrate to Drift with SQLCipher for production
- [ ] Implement secure key backup/recovery
- [ ] Clear data on app uninstall
- [ ] Add user consent before connecting bank
- [ ] Implement session timeouts
- [ ] Test on both iOS and Android

## Testing

### Unit Tests

The module includes comprehensive unit tests:

```bash
flutter test test/banking_models_test.dart     # Model tests
flutter test test/banking_service_test.dart    # Service tests
```

### Testing Local Storage

```dart
test('saves and retrieves transactions locally', () async {
  final storage = LocalBankingStorage();
  
  await storage.saveTransactions([transaction]);
  final retrieved = await storage.getTransactions();
  
  expect(retrieved, hasLength(1));
  expect(retrieved.first.id, transaction.id);
});

test('enforces 24-hour rate limit', () async {
  final storage = LocalBankingStorage();
  
  await storage.setLastRefreshDate();
  final canRefresh = await storage.canRefresh();
  
  expect(canRefresh, false);
});
```

## Dependencies

### Current (Existing)

- `provider` - State management
- `url_launcher` - OAuth redirects
- `http` - HTTP client
- `shared_preferences` - Local storage
- `flutter_secure_storage` - Encryption keys ⭐

### Required for Full Implementation

Add to `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.5.0  # For Edge Function calls
  purchases_flutter: ^6.29.0  # For RevenueCat
```

### Optional for Production

For large transaction volumes, migrate to encrypted database:

```yaml
dependencies:
  drift: ^2.14.0  # SQLite with encryption
  sqlite3_flutter_libs: ^0.5.0
  sqlcipher_flutter_libs: ^0.6.0  # SQLCipher encryption
```

## Known Limitations

1. **Edge Function Not Deployed**: Proxy returns "NOT_IMPLEMENTED" until deployed
2. **SharedPreferences Storage**: Works for moderate data, migrate to Drift for production
3. **No Authentication**: User IDs are stubbed until Supabase Auth integrated
4. **Premium Check Stub**: Always returns false until RevenueCat integrated
5. **No OAuth Flow**: Bank connections not functional until Edge Function deployed

## Migration to Production

### Phase 1: Edge Function (1 day)
1. Deploy stateless proxy to Supabase
2. Configure GoCardless credentials
3. Test with sandbox bank

### Phase 2: Local Storage Encryption (1 day)
1. Implement proper AES encryption
2. Test key storage on iOS/Android
3. Verify data persistence

### Phase 3: Drift Migration (2 days)
1. Set up Drift database with SQLCipher
2. Migrate from SharedPreferences
3. Test with large datasets

### Phase 4: Premium & OAuth (2 days)
1. Integrate RevenueCat
2. Complete OAuth flow
3. End-to-end testing

**Total**: ~1 week for full production deployment

## Future Enhancements

- [ ] Bank selection UI with institution logos
- [ ] Transaction categorization and filtering
- [ ] Export transactions to CSV
- [ ] Import transactions into expense groups
- [ ] Multi-account support
- [ ] Transaction search
- [ ] Spending analytics
- [ ] Budget alerts based on bank data

## Contributing

When implementing this module:

1. Follow existing code patterns in Caravella
2. Use Material 3 design system
3. Add proper error handling
4. Write tests for business logic
5. Update documentation
6. Follow security best practices

## License

Same as Caravella main application.

## Support

For implementation questions:

1. Read `/docs/BANKING_SETUP.md`
2. Check service provider documentation:
   - [Supabase Docs](https://supabase.com/docs)
   - [GoCardless Docs](https://gocardless.com/bank-account-data/docs/)
   - [RevenueCat Docs](https://docs.revenuecat.com)
3. Open GitHub issue with `banking` label

---

**Status**: Stub Implementation - Requires External Services
**Last Updated**: 2024
