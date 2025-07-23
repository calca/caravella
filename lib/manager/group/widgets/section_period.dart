import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../widgets/section_flat.dart';

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
    return SectionFlat(
      title: loc.get('dates'),
      children: [
        Row(
          children: [
            Expanded(
              child: startDate == null
                  ? IconButton.filledTonal(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => onPickDate(context, true),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurface,
                        minimumSize: const Size(54, 54),
                      ),
                      tooltip: loc.get('select_from_date'),
                    )
                  : GestureDetector(
                      onTap: () => onPickDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: Text(
                          '${startDate!.day}/${startDate!.month}/${startDate!.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('-', style: Theme.of(context).textTheme.bodyLarge),
            ),
            Expanded(
              child: endDate == null
                  ? IconButton.filledTonal(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => onPickDate(context, false),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurface,
                        minimumSize: const Size(54, 54),
                      ),
                      tooltip: loc.get('select_to_date'),
                    )
                  : GestureDetector(
                      onTap: () => onPickDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: Text(
                          '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
            ),
            if (startDate != null || endDate != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton.filledTonal(
                  icon: Icon(Icons.close,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                  onPressed: onClearDates,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    minimumSize: const Size(54, 54),
                  ),
                  tooltip: loc.get('clear_dates'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
