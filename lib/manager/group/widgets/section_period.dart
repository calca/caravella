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
        if (startDate == null && endDate == null) ...[
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                      currentFocus.unfocus();
                    }
                    onPickDate(context, true);
                    // Unfocus again after picker closes
                    Future.delayed(const Duration(milliseconds: 10), () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                        currentFocus.unfocus();
                      }
                    });
                  },
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
                  onTap: () async {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                      currentFocus.unfocus();
                    }
                    onPickDate(context, false);
                    Future.delayed(const Duration(milliseconds: 10), () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                        currentFocus.unfocus();
                      }
                    });
                  },
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
                  onTap: () async {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                      currentFocus.unfocus();
                    }
                    onPickDate(context, true);
                    Future.delayed(const Duration(milliseconds: 10), () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                        currentFocus.unfocus();
                      }
                    });
                  },
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
                  onTap: () async {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                      currentFocus.unfocus();
                    }
                    onPickDate(context, false);
                    Future.delayed(const Duration(milliseconds: 10), () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                        currentFocus.unfocus();
                      }
                    });
                  },
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
      child: SizedBox(
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(icon, size: 22)
                  : Text(
                      day != null ? day.toString() : '--',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: date == null
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 24,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _formatDate(date!),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                size: 24, color: theme.colorScheme.outline),
          ],
        ),
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
