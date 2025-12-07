import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../pages/tabs/usecase/settlements_logic.dart';

/// Utility for generating Markdown export for an expense group.
class MarkdownExporter {
  const MarkdownExporter._();

  /// Generates Markdown content. Returns empty string if group is null or has no expenses.
  static String generate(ExpenseGroup? group, gen.AppLocalizations loc) {
    if (group == null || group.expenses.isEmpty) return '';
    final buffer = StringBuffer();

    // Header with group info
    buffer.writeln('# ${_escape(group.title)}');
    buffer.writeln();
    
    // General information
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

    // Statistics section
    buffer.writeln('## ${loc.statistics}');
    buffer.writeln();

    // Total expenses
    final totalAmount = group.expenses.fold<double>(
      0.0,
      (sum, expense) => sum + (expense.amount ?? 0.0),
    );
    buffer.writeln(
      '**${loc.total_expenses}**: ${CurrencyDisplay.formatCurrencyText(totalAmount, group.currency)}',
    );
    buffer.writeln();

    // Number of expenses
    buffer.writeln('**${loc.number_of_expenses}**: ${group.expenses.length}');
    buffer.writeln();

    // Statistics by participant
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

    // Statistics by category
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

    // Expenses table
    buffer.writeln('## ${loc.expenses}');
    buffer.writeln();

    // Table header
    buffer.writeln(
      '| ${loc.csv_expense_name} | ${loc.csv_amount} | ${loc.csv_paid_by} | ${loc.csv_category} | ${loc.csv_date} |',
    );
    buffer.writeln('|---|---|---|---|---|');

    // Expense rows
    for (final e in group.expenses) {
      buffer.writeln(
        '| ${_escape(e.name ?? '')} | ${CurrencyDisplay.formatCurrencyText(e.amount ?? 0, group.currency)} | ${_escape(e.paidBy.name)} | ${_escape(e.category.name)} | ${_formatDate(e.date)} |',
      );
    }

    return buffer.toString();
  }

  /// Builds the Markdown filename in the format: YYYYMMDD_[title]_export.md
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
        .replaceAll(RegExp(r'_+'), '_');
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
