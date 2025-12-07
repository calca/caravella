import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../pages/tabs/usecase/settlements_logic.dart';

/// Utility per generare Markdown per un gruppo di spese.
class MarkdownExporter {
  const MarkdownExporter._();

  /// Genera il contenuto Markdown. Ritorna stringa vuota se gruppo nullo o senza spese.
  static String generate(ExpenseGroup? group, gen.AppLocalizations loc) {
    if (group == null || group.expenses.isEmpty) return '';
    final buffer = StringBuffer();

    // Intestazione con le info del gruppo
    buffer.writeln('# ${_escape(group.title)}');
    buffer.writeln();
    
    // Informazioni generali
    if (group.startDate != null || group.endDate != null) {
      buffer.write('**${loc.period}**: ');
      if (group.startDate != null) {
        buffer.write(_formatDate(group.startDate!));
      }
      if (group.startDate != null && group.endDate != null) {
        buffer.write(' - ');
      }
      if (group.endDate != null) {
        buffer.write(_formatDate(group.endDate!));
      }
      buffer.writeln();
      buffer.writeln();
    }

    buffer.writeln('**${loc.currency}**: ${group.currency}');
    buffer.writeln();
    buffer.writeln('**${loc.participants}**: ${group.participants.length}');
    buffer.writeln();

    // Sezione statistiche del gruppo
    buffer.writeln('## ${loc.statistics}');
    buffer.writeln();

    // Totale spese
    final totalAmount = group.expenses.fold<double>(
      0.0,
      (sum, expense) => sum + (expense.amount ?? 0.0),
    );
    buffer.writeln(
      '**${loc.total_expenses}**: ${CurrencyDisplay.formatCurrencyText(totalAmount, group.currency)}',
    );
    buffer.writeln();

    // Numero spese
    buffer.writeln('**${loc.number_of_expenses}**: ${group.expenses.length}');
    buffer.writeln();

    // Statistiche per partecipante
    buffer.writeln('### ${loc.expenses_by_participant}');
    buffer.writeln();
    
    final idToName = {for (final p in group.participants) p.id: p.name};
    
    for (final p in group.participants) {
      final total = group.expenses
          .where((e) => e.paidBy.id == p.id)
          .fold<double>(0, (s, e) => s + (e.amount ?? 0));
      buffer.writeln(
        '- **${_escape(p.name)}**: ${CurrencyDisplay.formatCurrencyText(total, group.currency)}',
      );
    }
    buffer.writeln();

    // Statistiche per categoria
    if (group.categories.isNotEmpty) {
      buffer.writeln('### ${loc.expenses_by_category}');
      buffer.writeln();

      final categoryTotals = <String, double>{};
      for (final expense in group.expenses) {
        final catName = expense.category.name;
        categoryTotals[catName] = (categoryTotals[catName] ?? 0.0) + (expense.amount ?? 0.0);
      }

      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedCategories) {
        buffer.writeln(
          '- **${_escape(entry.key)}**: ${CurrencyDisplay.formatCurrencyText(entry.value, group.currency)}',
        );
      }
      buffer.writeln();
    }

    // Settlements
    final settlements = computeSettlements(group);
    if (settlements.isEmpty) {
      buffer.writeln('### ${loc.settlement}');
      buffer.writeln();
      buffer.writeln(loc.all_balanced);
      buffer.writeln();
    } else {
      buffer.writeln('### ${loc.settlement}');
      buffer.writeln();
      for (final s in settlements) {
        final fromName = idToName[s.fromId] ?? s.fromId;
        final toName = idToName[s.toId] ?? s.toId;
        buffer.writeln(
          '- **${_escape(fromName)}** → **${_escape(toName)}**: ${CurrencyDisplay.formatCurrencyText(s.amount, group.currency)}',
        );
      }
      buffer.writeln();
    }

    // Tabella con le spese
    buffer.writeln('## ${loc.expenses}');
    buffer.writeln();

    // Intestazione tabella
    buffer.writeln(
      '| ${loc.csv_expense_name} | ${loc.csv_amount} | ${loc.csv_paid_by} | ${loc.csv_category} | ${loc.csv_date} |',
    );
    buffer.writeln('|---|---|---|---|---|');

    // Righe spese
    for (final e in group.expenses) {
      buffer.writeln(
        '| ${_escape(e.name ?? '')} | ${CurrencyDisplay.formatCurrencyText(e.amount ?? 0, group.currency)} | ${_escape(e.paidBy.name)} | ${_escape(e.category.name)} | ${_formatDate(e.date)} |',
      );
    }

    return buffer.toString();
  }

  /// Costruisce il nome file Markdown nel formato: YYYYMMDD_[titolo]_export.md
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
    return '${date}_${safeTitle}_export.md';
  }

  static String _escape(String value) {
    // Escape pipe characters and backslashes for Markdown tables
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('|', '\\|')
        .replaceAll('\n', ' ');
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
