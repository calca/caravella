import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

/// Formats a date range using the current locale with graceful fallbacks.
/// Rules:
/// - both null => returns '–'
/// - single date => that date
/// - same day start/end => single date
/// - otherwise => "start - end"
String formatDateRange({
  required DateTime? start,
  required DateTime? end,
  required Locale locale,
}) {
  if (start == null && end == null) return '–';

  final currentYear = DateTime.now().year;
  String fmt(DateTime d) {
    // Hide the year when it's the current year for a shorter, cleaner display.
    if (d.year == currentYear) {
      return DateFormat.Md(locale.toString()).format(d); // e.g. 9/5
    }
    return DateFormat.yMd(locale.toString()).format(d); // includes year
  }

  if (start != null && end != null) {
    if (_isSameDay(start, end)) return fmt(start);
    final sameYear = start.year == end.year;
    // If range spans different years always show years for clarity
    if (!sameYear) {
      final full = DateFormat.yMd(locale.toString());
      return '${full.format(start)} - ${full.format(end)}';
    }
    // Same year: if it's current year we already hide year via fmt(), otherwise show year via yMd()
    return '${fmt(start)} - ${fmt(end)}';
  }

  final single = start ?? end!;
  return fmt(single);
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
