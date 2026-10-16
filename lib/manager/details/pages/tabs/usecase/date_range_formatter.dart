import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

/// Formats a single date for display in the app's locale (numeric, e.g.
/// 16/10/2026 in Italian, 10/16/2026 in English). Every date shown in the UI
/// goes through here or [formatDateRange] so screens agree on the format;
/// exports use their own fixed formats.
String formatDate(DateTime date, Locale locale) =>
    DateFormat.yMd(locale.toString()).format(date);

/// Formats a date range using the current locale with graceful fallbacks.
/// Rules:
/// - both null => returns '–'
/// - only a start => "start –"; only an end => "– end"
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

  if (start != null) return '${fmt(start)} –';
  return '– ${fmt(end!)}';
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
