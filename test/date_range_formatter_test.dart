import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:io_caravella_egm/manager/details/pages/tabs/usecase/date_range_formatter.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it');
    await initializeDateFormatting('en');
  });

  test('formatDate follows the app locale', () {
    final d = DateTime(2026, 10, 16);
    expect(formatDate(d, const Locale('it')), '16/10/2026');
    expect(formatDate(d, const Locale('en')), '10/16/2026');
  });

  test('formatDateRange uses the same order as formatDate', () {
    final year = DateTime.now().year;
    final start = DateTime(year, 10, 9);
    final end = DateTime(year, 10, 18);
    expect(
      formatDateRange(start: start, end: end, locale: const Locale('it')),
      '09/10 - 18/10',
    );
    expect(
      formatDateRange(start: start, end: end, locale: const Locale('en')),
      '10/9 - 10/18',
    );
  });

  test('open-ended ranges show which side is missing', () {
    final year = DateTime.now().year;
    final d = DateTime(year, 10, 9);
    const it = Locale('it');
    expect(formatDateRange(start: d, end: null, locale: it), '09/10 –');
    expect(formatDateRange(start: null, end: d, locale: it), '– 09/10');
    expect(formatDateRange(start: null, end: null, locale: it), '–');
  });
}
