import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/details/pages/tabs/usecase/date_range_formatter.dart';

/// A Booking.com-style period selector with calendar and duration presets
class PeriodSelectionBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final void Function(DateTime? startDate, DateTime? endDate)
  onSelectionChanged;

  const PeriodSelectionBottomSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onSelectionChanged,
  });

  @override
  State<PeriodSelectionBottomSheet> createState() =>
      _PeriodSelectionBottomSheetState();
}

class _PeriodSelectionBottomSheetState
    extends State<PeriodSelectionBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _displayedMonth = DateTime.now();

  // Duration presets in days
  static const List<int> _durationPresets = [3, 7, 15, 30];

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _displayedMonth = widget.initialStartDate ?? DateTime.now();
  }

  void _onDateTapped(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Start new selection
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        // Complete selection
        if (date.isBefore(_startDate!)) {
          // If selected date is before start, swap them
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });
  }

  void _onDurationPresetTapped(int days) {
    final now = DateTime.now();
    setState(() {
      _startDate = now;
      _endDate = now.add(
        Duration(days: days - 1),
      ); // -1 because we include start day
    });
  }

  void _onConfirm() {
    widget.onSelectionChanged(_startDate, _endDate);
    Navigator.of(context).pop();
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  bool _isDateSelected(DateTime date) {
    return (date.year == _startDate?.year &&
            date.month == _startDate?.month &&
            date.day == _startDate?.day) ||
        (date.year == _endDate?.year &&
            date.month == _endDate?.month &&
            date.day == _endDate?.day);
  }

  Widget _buildCalendarHeader() {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: gloc.accessibility_previous_month,
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month - 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '${_getMonthName(_displayedMonth.month)} ${_displayedMonth.year}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            tooltip: gloc.accessibility_next_month,
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month + 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);
    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday;

    // Calculate how many empty cells we need at the start
    final leadingEmptyCells = firstWeekday - 1;

    return Column(
      children: [
        // Day headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children:
                [
                      gloc.weekday_mon,
                      gloc.weekday_tue,
                      gloc.weekday_wed,
                      gloc.weekday_thu,
                      gloc.weekday_fri,
                      gloc.weekday_sat,
                      gloc.weekday_sun,
                    ]
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 240, // Fixed height for 6 weeks
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 42, // 6 weeks * 7 days
              itemBuilder: (context, index) {
                if (index < leadingEmptyCells) {
                  return const SizedBox(); // Empty cell
                }

                final dayNumber = index - leadingEmptyCells + 1;
                if (dayNumber > daysInMonth) {
                  return const SizedBox(); // Empty cell
                }

                final date = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month,
                  dayNumber,
                );
                final isSelected = _isDateSelected(date);
                final isInRange = _isDateInRange(date);
                final isToday = _isToday(date);

                return GestureDetector(
                  onTap: () => _onDateTapped(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isInRange
                          ? theme.colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(6),
                      border: isToday && !isSelected
                          ? Border.all(color: theme.colorScheme.primary)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : isInRange
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w600
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Whether the selection is [days] days from today (a preset's result).
  bool _isPreset(int days) {
    final now = DateTime.now();
    bool same(DateTime? a, DateTime b) =>
        a != null && a.year == b.year && a.month == b.month && a.day == b.day;
    return same(_startDate, now) &&
        same(_endDate, now.add(Duration(days: days - 1)));
  }

  Widget _buildDurationPresets() {
    final gloc = gen.AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionLabel(gloc.suggested_duration),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final days in _durationPresets)
              FormPill(
                label: gloc.days_count(days),
                style: _isPreset(days)
                    ? FormPillStyle.selected
                    : FormPillStyle.normal,
                onTap: () => _onDurationPresetTapped(days),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canConfirm = _startDate != null && _endDate != null;

    return FilledButton(
      onPressed: canConfirm ? _onConfirm : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        elevation: 0,
      ),
      child: Text(
        gloc.confirm,
        style: theme.textTheme.titleSmall?.copyWith(
          color: canConfirm
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// "11 Oct – 20 Oct · 10 days", or the hint when nothing is chosen.
  String _summary(gen.AppLocalizations gloc) {
    if (_startDate == null) return gloc.dates_description;
    final range = formatDateRange(
      start: _startDate,
      end: _endDate,
      locale: Localizations.localeOf(context),
    );
    if (_endDate == null) return range;
    final days =
        DateTime(_endDate!.year, _endDate!.month, _endDate!.day)
            .difference(
              DateTime(_startDate!.year, _startDate!.month, _startDate!.day),
            )
            .inDays +
        1;
    return '$range · ${gloc.days_count(days)}';
  }

  String _getMonthName(int month) {
    final gloc = gen.AppLocalizations.of(context);
    final months = [
      gloc.month_january,
      gloc.month_february,
      gloc.month_march,
      gloc.month_april,
      gloc.month_may,
      gloc.month_june,
      gloc.month_july,
      gloc.month_august,
      gloc.month_september,
      gloc.month_october,
      gloc.month_november,
      gloc.month_december,
    ];
    return months[month - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(20);
    return CaravellaBottomSheetScaffold(
      title: gloc.period,
      subtitle: _summary(gloc),
      scrollable: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardOutline(
            borderRadius: radius,
            child: Material(
              color: s.raisedSurface,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [_buildCalendarHeader(), _buildCalendarGrid()],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDurationPresets(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }
}

/// Function to show the period selection bottom sheet
Future<void> showPeriodSelectionBottomSheet({
  required BuildContext context,
  DateTime? initialStartDate,
  DateTime? initialEndDate,
  required void Function(DateTime? startDate, DateTime? endDate)
  onSelectionChanged,
}) async {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => PeriodSelectionBottomSheet(
      initialStartDate: initialStartDate,
      initialEndDate: initialEndDate,
      onSelectionChanged: onSelectionChanged,
    ),
  );
}
