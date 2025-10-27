
/// Utility per generare il contenuto OFX di un [ExpenseGroup].
class OfxExporter {
  const OfxExporter._();

  /// Genera il contenuto OFX delle spese del gruppo.
  /// Ritorna stringa vuota se il gruppo è nullo o senza spese.
  static String generate(ExpenseGroup? group) {
    if (group == null || group.expenses.isEmpty) return '';

    final now = DateTime.now();
    final buffer = StringBuffer();

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<?OFX OFXHEADER="200" VERSION="200" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?>',
    );
    buffer.writeln('<OFX>');
    buffer.writeln('  <SIGNONMSGSRSV1>');
    buffer.writeln('    <SONRS>');
    buffer.writeln('      <STATUS>');
    buffer.writeln('        <CODE>0</CODE>');
    buffer.writeln('        <SEVERITY>INFO</SEVERITY>');
    buffer.writeln('      </STATUS>');
    buffer.writeln('      <DTSERVER>${_formatOfxDateTime(now)}</DTSERVER>');
    buffer.writeln('      <LANGUAGE>ENG</LANGUAGE>');
    buffer.writeln('    </SONRS>');
    buffer.writeln('  </SIGNONMSGSRSV1>');
    buffer.writeln('  <BANKMSGSRSV1>');
    buffer.writeln('    <STMTTRNRS>');
    buffer.writeln('      <TRNUID>1</TRNUID>');
    buffer.writeln('      <STATUS>');
    buffer.writeln('        <CODE>0</CODE>');
    buffer.writeln('        <SEVERITY>INFO</SEVERITY>');
    buffer.writeln('      </STATUS>');
    buffer.writeln('      <STMTRS>');
    buffer.writeln('        <CURDEF>${group.currency}</CURDEF>');
    buffer.writeln('        <BANKACCTFROM>');
    buffer.writeln('          <BANKID>CARAVELLA</BANKID>');
    buffer.writeln('          <ACCTID>${group.id}</ACCTID>');
    buffer.writeln('          <ACCTTYPE>CHECKING</ACCTTYPE>');
    buffer.writeln('        </BANKACCTFROM>');
    buffer.writeln('        <BANKTRANLIST>');
    buffer.writeln(
      '          <DTSTART>${_formatOfxDate(group.startDate ?? group.expenses.first.date)}</DTSTART>',
    );
    buffer.writeln(
      '          <DTEND>${_formatOfxDate(group.endDate ?? group.expenses.last.date)}</DTEND>',
    );

    for (final expense in group.expenses) {
      buffer.writeln('          <STMTTRN>');
      buffer.writeln('            <TRNTYPE>DEBIT</TRNTYPE>');
      buffer.writeln(
        '            <DTPOSTED>${_formatOfxDate(expense.date)}</DTPOSTED>',
      );
      buffer.writeln(
        '            <TRNAMT>-${CurrencyDisplay.formatCurrencyText(expense.amount ?? 0, '').trim()}</TRNAMT>',
      );
      buffer.writeln('            <FITID>${expense.id}</FITID>');
      final description = _sanitizeXmlValue(
        expense.name ?? expense.category.name,
      );
      buffer.writeln('            <NAME>$description</NAME>');
      final payee = _sanitizeXmlValue(expense.paidBy.name);
      buffer.writeln('            <PAYEE>$payee</PAYEE>');
      if (expense.note != null && expense.note!.isNotEmpty) {
        final memo = _sanitizeXmlValue(
          '${expense.category.name} - ${expense.note}',
        );
        buffer.writeln('            <MEMO>$memo</MEMO>');
      } else {
        buffer.writeln(
          '            <MEMO>${_sanitizeXmlValue(expense.category.name)}</MEMO>',
        );
      }
      buffer.writeln('          </STMTTRN>');
    }

    buffer.writeln('        </BANKTRANLIST>');
    buffer.writeln('        <LEDGERBAL>');
    final totalAmount = group.expenses.fold<double>(
      0.0,
      (sum, expense) => sum + (expense.amount ?? 0.0),
    );
    buffer.writeln(
      '          <BALAMT>-${CurrencyDisplay.formatCurrencyText(totalAmount, '').trim()}</BALAMT>',
    );
    buffer.writeln('          <DTASOF>${_formatOfxDateTime(now)}</DTASOF>');
    buffer.writeln('        </LEDGERBAL>');
    buffer.writeln('      </STMTRS>');
    buffer.writeln('    </STMTTRNRS>');
    buffer.writeln('  </BANKMSGSRSV1>');
    buffer.writeln('</OFX>');

    return buffer.toString();
  }

  static String _formatOfxDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatOfxDateTime(DateTime dateTime) {
    return '${_formatOfxDate(dateTime)}'
        '${dateTime.hour.toString().padLeft(2, '0')}'
        '${dateTime.minute.toString().padLeft(2, '0')}'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  static String _sanitizeXmlValue(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
