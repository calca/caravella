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
  final loc = locale.toString();
  final df = DateFormat.yMd(loc);
  if (start != null && end != null) {
    if (_isSameDay(start, end)) return df.format(start);
    return '${df.format(start)} - ${df.format(end)}';
  }
  final single = start ?? end!;
  return df.format(single);
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
