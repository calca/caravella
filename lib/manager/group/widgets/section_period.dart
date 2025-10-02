import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'date_card.dart';
import 'section_header.dart';
import '../../../themes/app_text_styles.dart';

class SectionPeriod extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(bool) onPickDate;
  final void Function() onClearDates;
  final String? description;
  final String? errorText;
  final bool isEndDateEnabled;

  const SectionPeriod({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onPickDate,
    required this.onClearDates,
    this.description,
    this.errorText,
    this.isEndDateEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    void handleTap(bool isStart) {
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        currentFocus.unfocus();
      }
      onPickDate(isStart);
      final focusAfter = FocusScope.of(context);
      Future.delayed(const Duration(milliseconds: 10), () {
        if (!focusAfter.hasPrimaryFocus && focusAfter.focusedChild != null) {
          focusAfter.unfocus();
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: gen.AppLocalizations.of(context).dates,
          description: description,
          padding: EdgeInsets.zero,
          spacing: 4,
        ),
        const SizedBox(height: 12),
        // Start date row
        Row(
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => handleTap(true),
                  child: DateCard(
                    day: startDate?.day,
                    label: gen.AppLocalizations.of(context).from,
                    date: startDate,
                    isActive: startDate != null,
                    icon: startDate == null ? Icons.event_outlined : null,
                  ),
                ),
              ),
            ),
            if (startDate != null || endDate != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClearDates,
                tooltip: gen.AppLocalizations.of(context).delete,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // End date row
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isEndDateEnabled
                ? () {
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
                  }
                : null,
            child: DateCard(
              day: endDate?.day,
              label: gen.AppLocalizations.of(context).to,
              date: endDate,
              isActive: endDate != null,
              icon: endDate == null ? Icons.event_outlined : null,
              isEnabled: isEndDateEnabled,
            ),
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
}

// _DateCard is now in date_card.dart as DateCard
