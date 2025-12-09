import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';

/// Large featured card for the pinned/featured group.
class FeaturedGroupCard extends StatelessWidget {
  final ExpenseGroup group;
  final double balance;
  final VoidCallback? onTap;
  final VoidCallback? onSettlePayment;

  const FeaturedGroupCard({
    super.key,
    required this.group,
    required this.balance,
    this.onTap,
    this.onSettlePayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate progress (simplified)
    final totalExpenses = group.expenses.fold(0.0, (sum, e) => sum + e.amount);
    final settled = totalExpenses > 0 ? (totalExpenses - balance.abs()) / totalExpenses : 0.0;
    final progress = settled.clamp(0.0, 1.0);

    // Get flag emoji if present in title
    final titleParts = group.title.split(' ');
    String? flag;
    String displayTitle = group.title;
    
    // Simple flag detection (emoji at end)
    if (titleParts.isNotEmpty) {
      final lastPart = titleParts.last;
      if (lastPart.codeUnits.any((code) => code > 0x1F000)) {
        flag = lastPart;
        displayTitle = titleParts.take(titleParts.length - 1).join(' ');
      }
    }

    // Determine who to pay (simplified)
    String paymentText = '';
    if (balance < 0) {
      // User owes money
      final amount = balance.abs().toStringAsFixed(2);
      // Get creditors (simplified - just show amount)
      paymentText = 'Devi dare $amount€';
    } else if (balance > 0) {
      paymentText = 'Ti spettano ${balance.toStringAsFixed(2)}€';
    } else {
      paymentText = 'Tutto saldato';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A5A0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with flag
            Row(
              children: [
                Expanded(
                  child: Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (flag != null)
                  Text(
                    flag,
                    style: const TextStyle(fontSize: 28),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // "Polso del Gruppo" label
            const Text(
              'Polso del Gruppo',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Payment text
            Text(
              paymentText,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Settle payment button
            if (balance != 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSettlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4ECDC4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Salda la tua parte',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
