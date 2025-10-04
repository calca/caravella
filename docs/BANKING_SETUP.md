# PSD2 Banking Integration Setup Guide

## Overview

This document provides complete instructions for implementing the GoCardless PSD2 banking integration in Caravella. This feature allows Premium users to connect their bank accounts and automatically sync transactions.

## ⚠️ Important Prerequisites

Before implementing this feature, ensure you have:

1. **Supabase Account** - Cloud backend platform
2. **GoCardless Bank Data API Account** - PSD2 banking API access
3. **RevenueCat Account** - Premium subscription management
4. **Understanding of**: PSD2 regulations, OAuth flows, and cloud security

## Architecture Overview

```
┌─────────────────┐
│  Flutter App    │
│  (Caravella)    │
└────────┬────────┘
         │
         │ 1. Check Premium (RevenueCat)
         │ 2. Request Bank Link
         │ 3. Fetch Transactions
         │
┌────────▼────────┐
│ Supabase        │
│ Edge Functions  │
│  - create-link  │
│  - fetch-trans  │
└────────┬────────┘
         │
         │ API Calls
         │
┌────────▼────────┐
│  GoCardless     │
│  Bank Data API  │
└─────────────────┘
```

## Part 1: Supabase Setup

### 1.1 Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Note your:
   - Project URL: `https://xxxxx.supabase.co`
   - Anon/Public Key: `eyJhbGc...`
   - Service Role Key: `eyJhbGc...` (keep secret!)

### 1.2 Database Schema

Run these SQL commands in the Supabase SQL Editor:

```sql
-- Profiles table (extends auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  premium BOOLEAN DEFAULT FALSE,
  last_refresh TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bank accounts table
CREATE TABLE bank_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  account_id TEXT NOT NULL,
  iban TEXT,
  account_name TEXT,
  currency TEXT DEFAULT 'EUR',
  institution_id TEXT,
  last_sync TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, account_id)
);

-- Bank transactions table
CREATE TABLE bank_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  account_id UUID REFERENCES bank_accounts(id) ON DELETE CASCADE NOT NULL,
  amount NUMERIC NOT NULL,
  currency TEXT DEFAULT 'EUR',
  date DATE NOT NULL,
  description TEXT,
  creditor_name TEXT,
  debtor_name TEXT,
  transaction_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(account_id, transaction_id)
);

-- Bank requisitions table (OAuth flow tracking)
CREATE TABLE bank_requisitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  institution_id TEXT,
  redirect_url TEXT,
  status TEXT DEFAULT 'pending',
  expires_at TIMESTAMP WITH TIME ZONE,
  account_ids TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bank_requisitions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can view own bank accounts"
  ON bank_accounts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can view own transactions"
  ON bank_transactions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can view own requisitions"
  ON bank_requisitions FOR SELECT
  USING (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX idx_bank_accounts_user_id ON bank_accounts(user_id);
CREATE INDEX idx_bank_transactions_user_id ON bank_transactions(user_id);
CREATE INDEX idx_bank_transactions_account_id ON bank_transactions(account_id);
CREATE INDEX idx_bank_transactions_date ON bank_transactions(date DESC);
```

### 1.3 Edge Functions

Create Edge Functions in `supabase/functions/`:

#### supabase/functions/create-link/index.ts

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GOCARDLESS_BASE_URL = "https://bankaccountdata.gocardless.com/api/v2";

serve(async (req) => {
  try {
    // Verify authentication
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    // Get authenticated user
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Check premium status
    const { data: profile } = await supabase
      .from("profiles")
      .select("premium")
      .eq("id", user.id)
      .single();

    if (!profile?.premium) {
      return new Response(
        JSON.stringify({ error: "Premium subscription required" }),
        {
          status: 403,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const { institutionId, redirectUrl } = await req.json();

    // Get GoCardless access token
    const tokenRes = await fetch(`${GOCARDLESS_BASE_URL}/token/new/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        secret_id: Deno.env.get("GOCARDLESS_SECRET_ID"),
        secret_key: Deno.env.get("GOCARDLESS_SECRET_KEY"),
      }),
    });

    const { access: accessToken } = await tokenRes.json();

    // Create requisition
    const reqRes = await fetch(`${GOCARDLESS_BASE_URL}/requisitions/`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        redirect: redirectUrl,
        institution_id: institutionId,
        reference: user.id,
      }),
    });

    const requisitionData = await reqRes.json();

    // Save requisition to database
    await supabase.from("bank_requisitions").insert({
      id: requisitionData.id,
      user_id: user.id,
      institution_id: institutionId,
      redirect_url: redirectUrl,
      status: "pending",
      expires_at: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(), // 90 days
    });

    return new Response(
      JSON.stringify({
        link: requisitionData.link,
        requisition_id: requisitionData.id,
      }),
      {
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
```

#### supabase/functions/fetch-transactions/index.ts

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GOCARDLESS_BASE_URL = "https://bankaccountdata.gocardless.com/api/v2";

serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Check 24-hour rate limit
    const { data: profile } = await supabase
      .from("profiles")
      .select("last_refresh, premium")
      .eq("id", user.id)
      .single();

    if (!profile?.premium) {
      return new Response(
        JSON.stringify({ error: "Premium subscription required" }),
        { status: 403, headers: { "Content-Type": "application/json" } }
      );
    }

    if (profile.last_refresh) {
      const lastRefresh = new Date(profile.last_refresh);
      const hoursSince = (Date.now() - lastRefresh.getTime()) / (1000 * 60 * 60);
      if (hoursSince < 24) {
        return new Response(
          JSON.stringify({
            error: "Please wait 24 hours between refreshes",
            hours_remaining: Math.ceil(24 - hoursSince),
          }),
          { status: 429, headers: { "Content-Type": "application/json" } }
        );
      }
    }

    const { requisitionId } = await req.json();

    // Get GoCardless access token
    const tokenRes = await fetch(`${GOCARDLESS_BASE_URL}/token/new/`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        secret_id: Deno.env.get("GOCARDLESS_SECRET_ID"),
        secret_key: Deno.env.get("GOCARDLESS_SECRET_KEY"),
      }),
    });

    const { access: accessToken } = await tokenRes.json();

    // Get requisition details
    const reqRes = await fetch(
      `${GOCARDLESS_BASE_URL}/requisitions/${requisitionId}/`,
      {
        headers: { Authorization: `Bearer ${accessToken}` },
      }
    );

    const requisition = await reqRes.json();
    const accounts = requisition.accounts || [];

    // Fetch transactions for each account
    for (const accountId of accounts) {
      // Get account details
      const accountRes = await fetch(
        `${GOCARDLESS_BASE_URL}/accounts/${accountId}/details/`,
        {
          headers: { Authorization: `Bearer ${accessToken}` },
        }
      );

      const accountDetails = await accountRes.json();

      // Save or update account
      await supabase.from("bank_accounts").upsert({
        user_id: user.id,
        account_id: accountId,
        iban: accountDetails.account?.iban,
        account_name: accountDetails.account?.name,
        currency: accountDetails.account?.currency || "EUR",
        institution_id: requisition.institution_id,
        last_sync: new Date().toISOString(),
        is_active: true,
      });

      // Get account from database
      const { data: dbAccount } = await supabase
        .from("bank_accounts")
        .select("id")
        .eq("account_id", accountId)
        .eq("user_id", user.id)
        .single();

      // Get transactions
      const txRes = await fetch(
        `${GOCARDLESS_BASE_URL}/accounts/${accountId}/transactions/`,
        {
          headers: { Authorization: `Bearer ${accessToken}` },
        }
      );

      const txData = await txRes.json();
      const transactions = txData.transactions?.booked || [];

      // Save transactions
      for (const tx of transactions) {
        await supabase.from("bank_transactions").upsert(
          {
            user_id: user.id,
            account_id: dbAccount.id,
            amount: parseFloat(tx.transactionAmount?.amount || "0"),
            currency: tx.transactionAmount?.currency || "EUR",
            date: tx.bookingDate || tx.valueDate,
            description: tx.remittanceInformationUnstructured,
            creditor_name: tx.creditorName,
            debtor_name: tx.debtorName,
            transaction_id: tx.transactionId || tx.internalTransactionId,
          },
          {
            onConflict: "account_id,transaction_id",
          }
        );
      }
    }

    // Update last refresh timestamp
    await supabase
      .from("profiles")
      .update({ last_refresh: new Date().toISOString() })
      .eq("id", user.id);

    return new Response(
      JSON.stringify({ success: true, accounts_synced: accounts.length }),
      {
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
```

### 1.4 Deploy Edge Functions

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Deploy functions
supabase functions deploy create-link
supabase functions deploy fetch-transactions

# Set environment variables
supabase secrets set GOCARDLESS_SECRET_ID=your_secret_id
supabase secrets set GOCARDLESS_SECRET_KEY=your_secret_key
```

## Part 2: GoCardless Setup

### 2.1 Create GoCardless Account

1. Go to [gocardless.com](https://gocardless.com/bank-account-data/)
2. Sign up for Bank Account Data API
3. Complete KYC verification

### 2.2 Get API Credentials

1. Navigate to "User Secrets" in dashboard
2. Create new secret
3. Note:
   - Secret ID: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - Secret Key: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### 2.3 Configure Institutions

1. Navigate to "Institutions" in dashboard
2. Select banks you want to support (e.g., "SANDBOXFINANCE_SFIN0000")
3. For production, request access to real banks

## Part 3: RevenueCat Setup

### 3.1 Create RevenueCat Project

1. Go to [revenuecat.com](https://www.revenuecat.com)
2. Create new project
3. Configure:
   - App Store Connect (iOS)
   - Google Play Console (Android)

### 3.2 Create Premium Entitlement

1. In RevenueCat dashboard, go to "Entitlements"
2. Create entitlement named "premium"
3. Create products and attach to entitlement

### 3.3 Get API Keys

Note your:
- Public API Key (for iOS): `appl_xxxxxxxxxx`
- Public API Key (for Android): `goog_xxxxxxxxxx`

## Part 4: Flutter Integration

### 4.1 Add Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  # Existing dependencies...
  
  # New dependencies for banking integration
  supabase_flutter: ^2.5.0
  purchases_flutter: ^6.29.0
  http: ^1.2.0
```

Run:
```bash
flutter pub get
```

### 4.2 Configure Supabase

Update `lib/main.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    anonKey: 'your-anon-key',
  );
  
  // Existing initialization...
  runApp(const CaravellaApp());
}
```

### 4.3 Configure RevenueCat

Update `lib/main.dart`:

```dart
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize RevenueCat
  await Purchases.setLogLevel(LogLevel.debug);
  
  final configuration = PurchasesConfiguration(
    Platform.isIOS ? 'appl_xxxxxxxxxx' : 'goog_xxxxxxxxxx',
  );
  await Purchases.configure(configuration);
  
  // Existing initialization...
  runApp(const CaravellaApp());
}
```

### 4.4 Initialize Banking Service

Update `lib/main.dart` to add BankingNotifier to providers:

```dart
@override
Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
      ChangeNotifierProvider(create: (_) => UserNameNotifier()),
      // Add banking notifier
      ChangeNotifierProvider(
        create: (_) => BankingNotifier(
          bankingService: BankingService(
            supabaseUrl: 'https://your-project.supabase.co',
            supabaseAnonKey: 'your-anon-key',
          ),
        ),
      ),
    ],
    // Rest of app...
  );
}
```

### 4.5 Add Banking Page to Navigation

Add a menu item or button to navigate to the banking page:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const BankingPage(),
  ),
);
```

## Part 5: Testing

### 5.1 Test with GoCardless Sandbox

GoCardless provides a sandbox bank "SANDBOXFINANCE_SFIN0000" for testing:

1. Use institution ID: `SANDBOXFINANCE_SFIN0000`
2. Complete OAuth flow with test credentials
3. Verify transactions appear in Supabase database

### 5.2 Test Premium Flow

1. Configure RevenueCat test products
2. Test purchase flow
3. Verify premium status enables banking features

### 5.3 Test Rate Limiting

1. Fetch transactions
2. Try to fetch again immediately
3. Verify 24-hour rate limit is enforced

## Part 6: Production Deployment

### 6.1 Security Checklist

- [ ] All API keys stored in environment variables (not code)
- [ ] RLS policies enabled on all tables
- [ ] HTTPS enforced for all endpoints
- [ ] Rate limiting configured
- [ ] Error logging enabled
- [ ] User data encryption at rest
- [ ] GDPR compliance verified

### 6.2 GoCardless Production

1. Complete GoCardless production verification
2. Request access to production institutions
3. Update institution IDs in app

### 6.3 RevenueCat Production

1. Submit apps to App Store / Play Store
2. Verify in-app purchases work in production
3. Monitor subscription analytics

## Part 7: Maintenance

### 7.1 Monitoring

- Set up Supabase alerts for Edge Function errors
- Monitor GoCardless API usage and limits
- Track RevenueCat subscription metrics

### 7.2 Updates

- Keep GoCardless API version updated
- Monitor PSD2 regulation changes
- Update Edge Functions as needed

## Troubleshooting

### Edge Functions Not Working

Check:
- Environment variables are set correctly
- Supabase CLI is logged in
- Functions are deployed to correct project

### GoCardless Authentication Fails

Check:
- Secret ID and Key are correct
- Account is verified
- API limits not exceeded

### RevenueCat Not Detecting Purchases

Check:
- API keys match platform (iOS/Android)
- App is configured in RevenueCat dashboard
- Purchases are configured correctly

## Cost Estimates

- **Supabase**: Free tier (500MB database, 2GB bandwidth) or $25/month Pro
- **GoCardless**: Pay-as-you-go (varies by bank and country)
- **RevenueCat**: Free up to $10k MRR, then 1% of tracked revenue

## Security & Compliance

### PSD2 Compliance

- Strong Customer Authentication (SCA) handled by banks
- 90-day access token validity
- Explicit user consent required

### GDPR Compliance

- User data stored in EU (if using EU Supabase region)
- Right to access: Users can view their data
- Right to deletion: Cascade delete on user deletion
- Data encryption in transit and at rest

### Best Practices

1. Never store sensitive credentials in code
2. Use environment variables for all secrets
3. Enable RLS on all database tables
4. Log all access attempts
5. Implement proper error handling
6. Use HTTPS only
7. Rate limit API calls
8. Regular security audits

## Support

For issues with:
- **Supabase**: [supabase.com/docs](https://supabase.com/docs)
- **GoCardless**: [gocardless.com/bank-account-data/docs](https://gocardless.com/bank-account-data/docs/)
- **RevenueCat**: [docs.revenuecat.com](https://docs.revenuecat.com)

## Next Steps

After completing this setup:

1. Test thoroughly in sandbox environment
2. Implement proper error handling in Flutter UI
3. Add analytics/logging
4. Create user documentation
5. Submit for app store review (may require additional documentation for financial features)
6. Monitor production deployment closely

---

**Created**: $(date)
**Version**: 1.0.0
**Status**: Implementation Required
