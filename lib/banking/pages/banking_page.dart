import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/banking_notifier.dart';
import '../../../widgets/base_card.dart';

/// Banking integration page (PSD2 via GoCardless)
/// 
/// This page provides access to banking features for Premium users.
/// Users can connect their bank accounts, view transactions, and sync data.
/// 
/// **IMPORTANT**: This feature requires:
/// - Supabase backend with Edge Functions deployed
/// - GoCardless API credentials configured
/// - RevenueCat Premium subscription
/// 
/// See /docs/BANKING_SETUP.md for complete setup instructions.
class BankingPage extends StatefulWidget {
  const BankingPage({super.key});

  @override
  State<BankingPage> createState() => _BankingPageState();
}

class _BankingPageState extends State<BankingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BankingNotifier>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Connections'),
      ),
      body: Consumer<BankingNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!notifier.isPremium) {
            return _buildPremiumRequired(context, notifier);
          }

          if (notifier.error != null) {
            return _buildError(context, notifier);
          }

          if (!notifier.hasAccounts) {
            return _buildNoAccounts(context);
          }

          return _buildAccountsList(context, notifier);
        },
      ),
    );
  }

  Widget _buildPremiumRequired(BuildContext context, BankingNotifier notifier) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Premium Feature',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Bank integration requires a Premium subscription. '
              'Upgrade to connect your bank accounts and sync transactions.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                await notifier.showPaywall();
              },
              icon: const Icon(Icons.upgrade),
              label: const Text('Upgrade to Premium'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await notifier.restorePurchases();
              },
              child: const Text('Restore Purchases'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, BankingNotifier notifier) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Setup Required',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              notifier.error ?? 'An error occurred',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                notifier.initialize();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAccounts(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Bank Accounts',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Connect your bank account to automatically sync transactions '
              'and track your expenses.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Navigate to bank selection page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Bank connection requires Supabase backend setup. '
                      'See docs/BANKING_SETUP.md for instructions.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Connect Bank Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList(BuildContext context, BankingNotifier notifier) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Accounts section
        Text(
          'Connected Accounts',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...notifier.accounts.map((account) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BaseCard(
                child: ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: Text(account.accountName ?? 'Bank Account'),
                  subtitle: Text(account.iban ?? account.accountId),
                  trailing: account.lastSync != null
                      ? Text(
                          'Synced: ${_formatDate(account.lastSync!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
                ),
              ),
            )),

        const SizedBox(height: 24),

        // Transactions section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (notifier.canRefresh)
              IconButton(
                onPressed: () {
                  // TODO: Implement refresh
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction sync requires backend setup'),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh transactions',
              )
            else
              Tooltip(
                message: 'Next refresh in ${notifier.hoursUntilRefresh}h',
                child: Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (notifier.hasTransactions)
          ...notifier.transactions.take(10).map((transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BaseCard(
                  child: ListTile(
                    title: Text(
                      transaction.description ?? 'Transaction',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(_formatDate(transaction.date)),
                    trailing: Text(
                      '${transaction.amount >= 0 ? '+' : ''}${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                      style: TextStyle(
                        color: transaction.amount >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ))
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No transactions yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
