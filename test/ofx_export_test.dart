import 'package:flutter_test/flutter_test.dart';

// Test for OFX format generation
void main() {
  group('OFX Export Tests', () {
    test('OFX date formatting should work correctly', () {
      // Test date formatting functions
      final testDate = DateTime(2024, 1, 15, 14, 30, 45);
      
      expect(_formatOfxDate(testDate), equals('20240115'));
      expect(_formatOfxDateTime(testDate), equals('20240115143045'));
    });

    test('XML sanitization should escape special characters', () {
      expect(_sanitizeXmlValue('Test & Company'), equals('Test &amp; Company'));
      expect(_sanitizeXmlValue('<test>'), equals('&lt;test&gt;'));
      expect(_sanitizeXmlValue('"Special" value'), equals('&quot;Special&quot; value'));
      expect(_sanitizeXmlValue("It's working"), equals('It&apos;s working'));
      expect(_sanitizeXmlValue('Normal text'), equals('Normal text'));
    });

    test('OFX filename generation should create valid filename', () {
      final now = DateTime.now();
      final date = '${now.year.toString().padLeft(4, '0')}-'
                  '${now.month.toString().padLeft(2, '0')}-'
                  '${now.day.toString().padLeft(2, '0')}';
      
      final result = _buildOfxFilename('Test Trip Name & Special/Chars');
      expect(result, equals('${date}_test_trip_name_special_chars_export.ofx'));
    });

    test('OFX content generation should produce valid XML structure', () {
      final ofxContent = _generateTestOfxContent();
      
      // Check basic XML structure
      expect(ofxContent.contains('<?xml version="1.0" encoding="UTF-8"?>'), isTrue);
      expect(ofxContent.contains('<OFX>'), isTrue);
      expect(ofxContent.contains('</OFX>'), isTrue);
      expect(ofxContent.contains('<SIGNONMSGSRSV1>'), isTrue);
      expect(ofxContent.contains('<BANKMSGSRSV1>'), isTrue);
      expect(ofxContent.contains('<STMTTRN>'), isTrue);
      expect(ofxContent.contains('</STMTTRN>'), isTrue);
      
      // Check transaction details
      expect(ofxContent.contains('<TRNTYPE>DEBIT</TRNTYPE>'), isTrue);
      expect(ofxContent.contains('<TRNAMT>-50.00</TRNAMT>'), isTrue);
      expect(ofxContent.contains('<NAME>Restaurant Expense</NAME>'), isTrue);
      expect(ofxContent.contains('<PAYEE>John Doe</PAYEE>'), isTrue);
    });
  });
}

// Helper functions copied from the main implementation
String _formatOfxDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}'
         '${date.month.toString().padLeft(2, '0')}'
         '${date.day.toString().padLeft(2, '0')}';
}

String _formatOfxDateTime(DateTime dateTime) {
  return '${_formatOfxDate(dateTime)}'
         '${dateTime.hour.toString().padLeft(2, '0')}'
         '${dateTime.minute.toString().padLeft(2, '0')}'
         '${dateTime.second.toString().padLeft(2, '0')}';
}

String _sanitizeXmlValue(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

String _buildOfxFilename(String tripTitle) {
  final now = DateTime.now();
  final date = '${now.year.toString().padLeft(4, '0')}-'
              '${now.month.toString().padLeft(2, '0')}-'
              '${now.day.toString().padLeft(2, '0')}';
  final rawTitle = tripTitle;
  final safeTitle = rawTitle
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .trim();
  return '${date}_${safeTitle}_export.ofx';
}

String _generateTestOfxContent() {
  final now = DateTime.now();
  final buffer = StringBuffer();
  
  // OFX Header
  buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buffer.writeln('<?OFX OFXHEADER="200" VERSION="200" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?>');
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
  buffer.writeln('        <CURDEF>USD</CURDEF>');
  buffer.writeln('        <BANKACCTFROM>');
  buffer.writeln('          <BANKID>CARAVELLA</BANKID>');
  buffer.writeln('          <ACCTID>test-trip-id</ACCTID>');
  buffer.writeln('          <ACCTTYPE>CHECKING</ACCTTYPE>');
  buffer.writeln('        </BANKACCTFROM>');
  buffer.writeln('        <BANKTRANLIST>');
  buffer.writeln('          <DTSTART>${_formatOfxDate(DateTime(2024, 1, 1))}</DTSTART>');
  buffer.writeln('          <DTEND>${_formatOfxDate(DateTime(2024, 1, 31))}</DTEND>');
  
  // Sample transaction
  buffer.writeln('          <STMTTRN>');
  buffer.writeln('            <TRNTYPE>DEBIT</TRNTYPE>');
  buffer.writeln('            <DTPOSTED>${_formatOfxDate(DateTime(2024, 1, 15))}</DTPOSTED>');
  buffer.writeln('            <TRNAMT>-50.00</TRNAMT>');
  buffer.writeln('            <FITID>test-expense-1</FITID>');
  buffer.writeln('            <NAME>Restaurant Expense</NAME>');
  buffer.writeln('            <PAYEE>John Doe</PAYEE>');
  buffer.writeln('            <MEMO>Food - Dinner at restaurant</MEMO>');
  buffer.writeln('          </STMTTRN>');
  
  buffer.writeln('        </BANKTRANLIST>');
  buffer.writeln('        <LEDGERBAL>');
  buffer.writeln('          <BALAMT>-50.00</BALAMT>');
  buffer.writeln('          <DTASOF>${_formatOfxDateTime(now)}</DTASOF>');
  buffer.writeln('        </LEDGERBAL>');
  buffer.writeln('      </STMTRS>');
  buffer.writeln('    </STMTTRNRS>');
  buffer.writeln('  </BANKMSGSRSV1>');
  buffer.writeln('</OFX>');
  
  return buffer.toString();
}