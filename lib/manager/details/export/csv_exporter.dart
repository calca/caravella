import '../../../data/model/expense_group.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Utility per generare CSV per un gruppo di spese.
class CsvExporter {
  const CsvExporter._();

  /// Genera il contenuto CSV. Ritorna stringa vuota se gruppo nullo o senza spese.
  static String generate(ExpenseGroup? group, gen.AppLocalizations loc) {
    if (group == null || group.expenses.isEmpty) return '';
    final buffer = StringBuffer();

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
      ].join(','),
    );

    for (final e in group.expenses) {
      buffer.writeln(
        [
          _escape(e.name ?? ''),
          e.amount?.toStringAsFixed(2) ?? '',
          _escape(e.paidBy.name),
          _escape(e.category.name),
          e.date.toIso8601String().split('T').first,
          _escape(e.note ?? ''),
          _escape(e.location?.displayText ?? ''),
        ].join(','),
      );
    }
    return buffer.toString();
  }

  /// Costruisce il nome file CSV nel formato: YYYY-MM-DD_[titolo]_export.csv
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
