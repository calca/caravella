import 'package:flutter/material.dart';
import '../../../app_localizations.dart';

class SectionPeriod extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(BuildContext, bool) onPickDate;
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
              FilledButton.tonal(
                onPressed: onClearDates,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                  foregroundColor: Theme.of(context).colorScheme.error,
                  minimumSize: const Size(44, 44),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 20),
                    const SizedBox(width: 6),
                    Text(loc.get('clear_dates')),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (startDate == null && endDate == null) ...[
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onPickDate(context, true),
                  child: const _DateCard(
                    day: null,
                    label: 'Data Inizio',
                    date: null,
                    isActive: false,
                    icon: Icons.calendar_today,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => onPickDate(context, false),
                  child: const _DateCard(
                    day: null,
                    label: 'Data Fine',
                    date: null,
                    isActive: false,
                    icon: Icons.calendar_today,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onPickDate(context, true),
                  child: _DateCard(
                    day: startDate?.day,
                    label: 'Data Inizio',
                    date: startDate,
                    isActive: startDate != null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => onPickDate(context, false),
                  child: _DateCard(
                    day: endDate?.day,
                    label: 'Data Fine',
                    date: endDate,
                    isActive: endDate != null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  final int? day;
  final String label;
  final DateTime? date;
  final bool isActive;
  final IconData? icon;

  const _DateCard({
    required this.day,
    required this.label,
    required this.date,
    required this.isActive,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: icon != null
                    ? Icon(icon, color: theme.colorScheme.primary, size: 22)
                    : Text(
                        day != null ? day.toString() : '--',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          date != null
              ? Text(
                  _formatDate(date!),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                )
              : SizedBox(height: theme.textTheme.titleMedium?.fontSize ?? 20),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Formats date as dd/MM/yyyy
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
