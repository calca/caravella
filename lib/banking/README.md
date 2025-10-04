# Banking Integration Module

This module provides PSD2 banking integration via GoCardless for Caravella Premium users.

## ⚠️ IMPORTANT: Setup Required

This module contains **stub implementations** that require external services to function:

### Required Services

1. **Supabase** - Cloud backend with Edge Functions
   - Database for accounts and transactions
   - Edge Functions for GoCardless API integration
   - User authentication

2. **GoCardless Bank Data API** - PSD2 banking access
   - Enables secure bank account connections
   - Provides transaction data access
   - Requires API credentials

3. **RevenueCat** - Premium subscription management
   - Manages Premium tier subscriptions
   - Validates user entitlements
   - Handles in-app purchases

### Setup Instructions

See [`/docs/BANKING_SETUP.md`](../docs/BANKING_SETUP.md) for complete setup guide.

## Module Structure

```
lib/banking/
├── models/           # Data models
│   ├── bank_account.dart
│   ├── bank_transaction.dart
│   └── bank_requisition.dart
├── services/         # Business logic
│   ├── banking_service.dart
│   └── premium_service.dart
├── state/            # State management
│   └── banking_notifier.dart
├── pages/            # UI screens
│   └── banking_page.dart
└── widgets/          # Reusable widgets (future)
```

## Features

### Implemented (Stub)

- ✅ Data models for bank accounts and transactions
- ✅ Service layer architecture
- ✅ State management with Provider
- ✅ Basic UI for banking features
- ✅ Premium subscription checks
- ✅ 24-hour refresh rate limiting

### Not Implemented (Requires Setup)

- ❌ Supabase backend integration
- ❌ GoCardless API integration
- ❌ RevenueCat subscription integration
- ❌ OAuth PSD2 authorization flow
- ❌ Transaction synchronization
- ❌ Bank account management

## Usage

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

### Fetching Transactions

```dart
final success = await bankingNotifier.fetchTransactions(
  userId: 'user-id',
  requisitionId: 'requisition-id',
);

if (success) {
  // Transactions synced successfully
  final transactions = bankingNotifier.transactions;
} else {
  // Handle error
  final error = bankingNotifier.error;
}
```

## Error Handling

All service methods return `BankingResult<T>` with success/failure status:

```dart
final result = await bankingService.createBankLink(
  userId: 'user-id',
  institutionId: 'bank-id',
  redirectUrl: 'https://app.com/callback',
);

if (result.isSuccess) {
  final link = result.data; // Authorization URL
} else {
  final error = result.error; // BankingError
  print('Error: ${error.message}');
}
```

## Security Considerations

### What's Secure

- ✅ All sensitive operations in backend Edge Functions
- ✅ No API credentials stored in Flutter app
- ✅ Row Level Security (RLS) on database
- ✅ 24-hour rate limiting for transaction sync
- ✅ Premium subscription requirement

### Implementation Checklist

When implementing the backend:

- [ ] Store all secrets in environment variables
- [ ] Enable RLS on all database tables
- [ ] Implement proper error logging
- [ ] Add request rate limiting
- [ ] Use HTTPS only
- [ ] Validate all user inputs
- [ ] Implement GDPR compliance
- [ ] Add audit logging

## Testing

Since the backend is not implemented, the current code:

- Shows appropriate error messages
- Handles missing backend gracefully
- Provides UI for premium upgrade
- Documents required setup steps

To test with a real backend:

1. Complete setup in `/docs/BANKING_SETUP.md`
2. Configure environment variables
3. Deploy Supabase Edge Functions
4. Update `BankingService` with real URLs
5. Test OAuth flow with sandbox bank
6. Verify transaction sync works

## Dependencies

### Current (Existing)

- `provider` - State management
- `url_launcher` - OAuth redirects
- `http` - HTTP client (if not present, add it)

### Required for Full Implementation

Add to `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.5.0
  purchases_flutter: ^6.29.0
  http: ^1.2.0  # If not already present
```

## Known Limitations

1. **Backend Not Implemented**: All API calls return "NOT_IMPLEMENTED" errors
2. **No Real Authentication**: User IDs are hardcoded/stubbed
3. **No Actual Bank Connections**: OAuth flow not functional
4. **No Transaction Sync**: Data not fetched from banks
5. **Premium Check Stub**: Always returns false until RevenueCat integrated

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
