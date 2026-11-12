import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Builds the CSV export of a group's expenses.
class CsvExporter {
  const CsvExporter._();

  /// The CSV content; empty when there's no group or no expense.
  static String generate(ExpenseGroup? group, gen.AppLocalizations loc) {
    if (group == null || group.expenses.isEmpty) return '';
    final buffer = StringBuffer();
    // Two more columns only when some expense was entered in the second
    // currency: what the receipt said, and in which currency.
    final withOriginal = group.expenses.any((e) => e.original != null);

    // Intestazione localizzata
    buffer.writeln(
      [
        loc.csv_expense_name,
        loc.csv_amount,
        loc.csv_paid_by,
        loc.csv_category,
        loc.csv_date,
        loc.csv_note,
        loc.csv_location,
        if (withOriginal) ...[
          loc.csv_original_amount,
          loc.csv_original_currency,
        ],
      ].join(','),
    );

    for (final e in group.expenses) {
      buffer.writeln(
        [
          _escape(e.name ?? ''),
          CurrencyDisplay.formatCurrencyText(e.amount ?? 0, '').trim(),
          _escape(e.paidBy.name),
          _escape(e.category.name),
          e.date.toIso8601String().split('T').first,
          _escape(e.note ?? ''),
          _escape(e.location?.displayText ?? ''),
          if (withOriginal) ...[
            switch (e.original) {
              final o? => CurrencyDisplay.formatCurrencyText(
                o.amount,
                '',
              ).trim(),
              null => '',
            },
            e.original?.code ?? '',
          ],
        ].join(','),
      );
    }
    return buffer.toString();
  }

  /// The file name: YYYY-MM-DD_[title]_export.csv
  static String buildFilename(ExpenseGroup? group, {DateTime? now}) {
    now ??= DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final rawTitle = group?.title ?? 'export';
    final safeTitle = rawTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    return '${date}_${safeTitle}_export.csv';
  }

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      value = value.replaceAll('"', '""');
      return '"$value"';
    }
    return value;
  }
}
