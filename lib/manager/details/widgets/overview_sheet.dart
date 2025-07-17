import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../state/locale_notifier.dart';
// ...existing code...
import '../../../data/expense_group.dart';
import 'overview_content.dart';

class OverviewSheet extends StatelessWidget {
  final ExpenseGroup trip;
  const OverviewSheet({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                loc.get('overview'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: OverviewContent(trip: trip),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
