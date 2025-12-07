import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/details/export/markdown_exporter.dart';

void main() {
  group('Markdown Export Tests', () {

    test('Markdown filename generation should create valid filename', () {
      final now = DateTime(2024, 12, 7);
      final group = ExpenseGroup(
        title: 'Test Trip & Special/Chars',
        expenses: [],
        participants: [],
        currency: '€',
      );
      
      final result = MarkdownExporter.buildFilename(group, now: now);
      expect(result, equals('20241207_test_trip_special_chars_export.md'));
    });

    test('Markdown should generate empty string for null group', () {
      final result = MarkdownExporter.generate(null, _MockLocalizations());
      expect(result, equals(''));
    });

    test('Markdown should generate empty string for group without expenses', () {
      final group = ExpenseGroup(
        title: 'Empty Group',
        expenses: [],
        participants: [],
        currency: '€',
      );
      
      final result = MarkdownExporter.generate(group, _MockLocalizations());
      expect(result, equals(''));
    });
  });
}

// Mock localization class for testing
class _MockLocalizations {
  String get period => 'Period';
  String get currency => 'Currency';
  String get participants => 'Participants';
  String get statistics => 'Statistics';
  String get total_expenses => 'Total expenses';
  String get number_of_expenses => 'Number of expenses';
  String get expenses_by_participant => 'By participant';
  String get expenses_by_category => 'By category';
  String get settlement => 'Settlement';
  String get all_balanced => 'All accounts are balanced!';
  String get expenses => 'Expenses';
  String get csv_expense_name => 'Description';
  String get csv_amount => 'Amount';
  String get csv_paid_by => 'Paid by';
  String get csv_category => 'Category';
  String get csv_date => 'Date';
}
