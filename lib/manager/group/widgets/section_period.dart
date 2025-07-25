import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import 'date_card.dart';

class SectionPeriod extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(bool) onPickDate;
  final void Function() onClearDates;
  final AppLocalizations loc;

  const SectionPeriod({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickDate,
    required this.onClearDates,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.get('dates'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (startDate != null || endDate != null)
              IconButton.filledTonal(
                onPressed: onClearDates,
                icon: const Icon(Icons.delete_outline, size: 22),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  foregroundColor: Theme.of(context).colorScheme.error,
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Always show two separate rows for start and end date
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.unfocus();
              }
              onPickDate(true);
              final focusAfter = FocusScope.of(context);
              Future.delayed(const Duration(milliseconds: 10), () {
                if (!focusAfter.hasPrimaryFocus &&
                    focusAfter.focusedChild != null) {
                  focusAfter.unfocus();
                }
              });
            },
            child: DateCard(
              day: startDate?.day,
              label: 'Data Inizio',
              date: startDate,
              isActive: startDate != null,
              icon: startDate == null ? Icons.calendar_today : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.unfocus();
              }
              onPickDate(false);
              final focusAfter = FocusScope.of(context);
              Future.delayed(const Duration(milliseconds: 10), () {
                if (!focusAfter.hasPrimaryFocus &&
                    focusAfter.focusedChild != null) {
                  focusAfter.unfocus();
                }
              });
            },
            child: DateCard(
              day: endDate?.day,
              label: 'Data Fine',
              date: endDate,
              isActive: endDate != null,
              icon: endDate == null ? Icons.calendar_today : null,
            ),
          ),
        ),
      ],
    );
  }
}

// _DateCard is now in date_card.dart as DateCard
