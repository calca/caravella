import 'package:flutter/material.dart';
import '../../models/global_balance.dart';

/// Dashboard card displaying the user's total global balance with breakdown.
class GlobalBalanceCard extends StatelessWidget {
  /// The global balance data to display
  final GlobalBalance balance;
  
  /// Currency symbol to display
  final String currency;

  const GlobalBalanceCard({
    super.key,
    required this.balance,
    this.currency = '€',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = balance.total >= 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Il tuo bilancio totale',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Large amount
          Text(
            '${isPositive ? '+' : ''}${balance.total.toStringAsFixed(2)} $currency',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: isPositive 
                  ? const Color(0xFF2ECC71) // Positive green
                  : const Color(0xFFE74C3C), // Negative red
              fontWeight: FontWeight.w700,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 20),
          // Indicators row
          Row(
            children: [
              // "Ti devono" indicator
              Expanded(
                child: _BalanceIndicator(
                  icon: '⬆️',
                  label: 'Ti devono',
                  amount: balance.owedToYou,
                  currency: currency,
                  color: const Color(0xFF2ECC71),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 16),
              // "Devi" indicator
              Expanded(
                child: _BalanceIndicator(
                  icon: '⬇️',
                  label: 'Devi',
                  amount: balance.youOwe,
                  currency: currency,
                  color: const Color(0xFFE74C3C),
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Internal widget for balance indicators (owed to you / you owe)
class _BalanceIndicator extends StatelessWidget {
  final String icon;
  final String label;
  final double amount;
  final String currency;
  final Color color;
  final ThemeData theme;

  const _BalanceIndicator({
    required this.icon,
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${amount.toStringAsFixed(2)} $currency',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
