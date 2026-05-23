import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/details/export/ofx_exporter.dart';

void main() {
  group('OFX Export Tests', () {
    test('OFX filename generation should create valid filename', () {
      final now = DateTime(2024, 12, 7);
      final group = ExpenseGroup(
        title: 'Test Trip Name & Special/Chars',
        expenses: [],
        participants: [],
        currency: 'USD',
      );

      final result = OfxExporter.buildFilename(group, now: now);
      expect(result, equals('2024-12-07_test_trip_name_special_chars_export.ofx'));
    });

    test('OFX content generation should produce valid XML structure', () {
      final participant = ExpenseParticipant(id: 'p1', name: 'John Doe');
      final category = ExpenseCategory(id: 'c1', name: 'Food');
      final expense = ExpenseDetails(
        id: 'test-expense-1',
        name: 'Restaurant Expense',
        amount: 50.0,
        paidBy: participant,
        category: category,
        date: DateTime(2024, 1, 15),
        note: 'Dinner at restaurant',
      );
      final group = ExpenseGroup(
        id: 'test-trip-id',
        title: 'Test Trip',
        expenses: [expense],
        participants: [participant],
        categories: [category],
        currency: 'USD',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final ofxContent = OfxExporter.generate(group);

      expect(ofxContent.contains('<?xml version="1.0" encoding="UTF-8"?>'), isTrue);
      expect(ofxContent.contains('<OFX>'), isTrue);
      expect(ofxContent.contains('</OFX>'), isTrue);
      expect(ofxContent.contains('<SIGNONMSGSRSV1>'), isTrue);
      expect(ofxContent.contains('<BANKMSGSRSV1>'), isTrue);
      expect(ofxContent.contains('<STMTTRN>'), isTrue);
      expect(ofxContent.contains('</STMTTRN>'), isTrue);
      expect(ofxContent.contains('<TRNTYPE>DEBIT</TRNTYPE>'), isTrue);
      expect(ofxContent.contains('<NAME>Restaurant Expense</NAME>'), isTrue);
      expect(ofxContent.contains('<PAYEE>John Doe</PAYEE>'), isTrue);
    });

    test('OFX XML escaping of special characters in content', () {
      final participant = ExpenseParticipant(id: 'p1', name: 'John & Jane');
      final category = ExpenseCategory(id: 'c1', name: '<Food>');
      final expense = ExpenseDetails(
        id: 'e1',
        name: 'Test & "Special" Expense',
        amount: 20.0,
        paidBy: participant,
        category: category,
        date: DateTime(2024, 6, 1),
      );
      final group = ExpenseGroup(
        id: 'g1',
        title: 'Trip',
        expenses: [expense],
        participants: [participant],
        categories: [category],
        currency: 'EUR',
      );

      final ofxContent = OfxExporter.generate(group);

      expect(ofxContent.contains('<NAME>Test &amp; &quot;Special&quot; Expense</NAME>'), isTrue);
      expect(ofxContent.contains('<PAYEE>John &amp; Jane</PAYEE>'), isTrue);
      expect(ofxContent.contains('<MEMO>&lt;Food&gt;</MEMO>'), isTrue);
    });
  });
}
