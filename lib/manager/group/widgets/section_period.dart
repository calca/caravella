import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/themes/app_text_styles.dart';
import 'date_card.dart';
import 'section_header.dart';
import 'period_selection_bottom_sheet.dart';

class SectionPeriod extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(bool) onPickDate;
  final void Function() onClearDates;
  final String? description;
  final String? errorText;
  final bool isEndDateEnabled;

  // New callback for setting both dates at once (optional for backwards compatibility)
  final void Function(DateTime? startDate, DateTime? endDate)?
  onDateRangeChanged;

  const SectionPeriod({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickDate,
    required this.onClearDates,
    this.description,
    this.errorText,
    this.isEndDateEnabled = true,
    this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: gen.AppLocalizations.of(context).dates,
          description: description,
          trailing: (startDate != null || endDate != null)
              ? IconButton.filledTonal(
                  onPressed: onClearDates,
                  icon: const Icon(Icons.delete_outline, size: 22),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer,
                    foregroundColor: Theme.of(context).colorScheme.error,
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                  ),
                )
              : null,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 12),
        // Period selector - single card that opens bottom sheet
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
              _showPeriodSelector(context);
              final focusAfter = FocusScope.of(context);
              Future.delayed(const Duration(milliseconds: 10), () {
                if (!focusAfter.hasPrimaryFocus &&
                    focusAfter.focusedChild != null) {
                  focusAfter.unfocus();
                }
              });
            },
            child: _PeriodDisplayCard(startDate: startDate, endDate: endDate),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            errorText!,
            style:
                (AppTextStyles.listItem(context) ??
                        Theme.of(context).textTheme.bodyMedium)
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  void _showPeriodSelector(BuildContext context) {
    showPeriodSelectionBottomSheet(
      context: context,
      initialStartDate: startDate,
      initialEndDate: endDate,
      onSelectionChanged: (newStartDate, newEndDate) {
        // Use the new callback if available, otherwise fall back to the old approach
        if (onDateRangeChanged != null) {
          onDateRangeChanged!(newStartDate, newEndDate);
        } else {
          // Fallback to old approach - this is hacky but maintains compatibility
          if (newStartDate == null && newEndDate == null) {
            onClearDates();
          } else {
            // We can't directly set both dates with the old API
            // This is a limitation of the backwards compatibility
            if (newStartDate != startDate) {
              onPickDate(true);
            }
            if (newEndDate != endDate) {
              onPickDate(false);
            }
          }
        }
      },
    );
  }
}

/// A card that displays the selected period range in a unified way
class _PeriodDisplayCard extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const _PeriodDisplayCard({required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);

    // Determine display text based on selected dates
    String displayText;
    String? secondaryText;
    IconData iconData;

    if (startDate == null && endDate == null) {
      displayText = gloc.select_period_hint;
      iconData = Icons.calendar_month_outlined;
    } else if (startDate != null && endDate != null) {
      displayText = '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
      final duration = endDate!.difference(startDate!).inDays + 1;
      secondaryText = '$duration days';
      iconData = Icons.calendar_month;
    } else if (startDate != null) {
      displayText = '${gloc.select_start}: ${_formatDate(startDate!)}';
      secondaryText = gloc.select_end;
      iconData = Icons.calendar_month_outlined;
    } else {
      displayText = '${gloc.select_end}: ${_formatDate(endDate!)}';
      secondaryText = gloc.select_start;
      iconData = Icons.calendar_month_outlined;
    }

    final hasSelection = startDate != null || endDate != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: SizedBox(
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: Icon(
                iconData,
                size: 28,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: secondaryText == null
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        displayText,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: hasSelection
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                          fontWeight: hasSelection
                              ? FontWeight.w500
                              : FontWeight.w500,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          secondaryText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 24,
              color: theme.colorScheme.outline,
            ),
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

// _DateCard is now in date_card.dart as DateCard
