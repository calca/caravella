import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Date filter presets available in [ExpenseSearchPage]'s date chip row.
enum ExpenseSearchDateFilter { today, last7Days, thisMonth, range }

// ---------------------------------------------------------------------------
// Date filter chips
// ---------------------------------------------------------------------------

class DateFilterChipsSection extends StatelessWidget {
  final String todayLabel;
  final String last7DaysLabel;
  final String thisMonthLabel;
  final String rangeLabel;
  final ExpenseSearchDateFilter? selectedDateFilter;
  final VoidCallback onTodaySelected;
  final VoidCallback onLast7DaysSelected;
  final VoidCallback onThisMonthSelected;
  final VoidCallback onRangeSelected;

  const DateFilterChipsSection({
    super.key,
    required this.todayLabel,
    required this.last7DaysLabel,
    required this.thisMonthLabel,
    required this.rangeLabel,
    required this.selectedDateFilter,
    required this.onTodaySelected,
    required this.onLast7DaysSelected,
    required this.onThisMonthSelected,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SearchFilterChip(
                label: todayLabel,
                selected: selectedDateFilter == ExpenseSearchDateFilter.today,
                onSelected: onTodaySelected,
                icon: Icons.today_outlined,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SearchFilterChip(
                label: last7DaysLabel,
                selected:
                    selectedDateFilter == ExpenseSearchDateFilter.last7Days,
                onSelected: onLast7DaysSelected,
                icon: Icons.history_outlined,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SearchFilterChip(
                label: thisMonthLabel,
                selected:
                    selectedDateFilter == ExpenseSearchDateFilter.thisMonth,
                onSelected: onThisMonthSelected,
                icon: Icons.calendar_month_outlined,
              ),
            ),
            SearchFilterChip(
              label: rangeLabel,
              selected: selectedDateFilter == ExpenseSearchDateFilter.range,
              onSelected: onRangeSelected,
              icon: Icons.date_range_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips section – categories, participants, attachment, location
// ---------------------------------------------------------------------------

class FilterChipsSection extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final List<ExpenseParticipant> participants;
  final String? selectedCategoryId;
  final String? selectedParticipantId;
  final bool filterHasAttachment;
  final bool filterHasLocation;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onParticipantSelected;
  final VoidCallback onHasAttachmentToggled;
  final VoidCallback onHasLocationToggled;

  const FilterChipsSection({
    super.key,
    required this.categories,
    required this.participants,
    required this.selectedCategoryId,
    required this.selectedParticipantId,
    required this.filterHasAttachment,
    required this.filterHasLocation,
    required this.onCategorySelected,
    required this.onParticipantSelected,
    required this.onHasAttachmentToggled,
    required this.onHasLocationToggled,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // Participant chips (paid by)
            ...participants.map(
              (p) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SearchFilterChip(
                  label: p.name,
                  selected: selectedParticipantId == p.id,
                  onSelected: () => onParticipantSelected(p.id),
                  icon: Icons.person_outline,
                ),
              ),
            ),

            // Category chips
            ...categories.map(
              (cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SearchFilterChip(
                  label: cat.name,
                  selected: selectedCategoryId == cat.id,
                  onSelected: () => onCategorySelected(cat.id),
                ),
              ),
            ),

            // Has attachment chip
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SearchFilterChip(
                label: gloc.has_attachment,
                selected: filterHasAttachment,
                onSelected: onHasAttachmentToggled,
                icon: Icons.attach_file_outlined,
              ),
            ),

            // Has location chip
            SearchFilterChip(
              label: gloc.has_location,
              selected: filterHasLocation,
              onSelected: onHasLocationToggled,
              icon: Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchFilterSectionLabel extends StatelessWidget {
  final String label;

  const SearchFilterSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable filter chip matching existing style
// ---------------------------------------------------------------------------

class SearchFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  const SearchFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: scheme.onSurface.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
      ),
      child: FilterChip(
        avatar: icon != null
            ? Icon(
                icon,
                size: 16,
                color: selected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              )
            : null,
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        side: BorderSide(
          color: selected
              ? scheme.onSurfaceVariant.withValues(alpha: 0.2)
              : scheme.outlineVariant.withValues(alpha: 0.4),
        ),
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.onSurfaceVariant.withValues(alpha: 0.15),
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
