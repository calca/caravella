import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
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
      final localization = lookupAppLocalizations(const Locale('en'));
      final result = MarkdownExporter.generate(null, localization);
      expect(result, equals(''));
    });

    test(
      'Markdown should generate empty string for group without expenses',
      () {
        final group = ExpenseGroup(
          title: 'Empty Group',
          expenses: [],
          participants: [],
          currency: '€',
        );

        final localization = lookupAppLocalizations(const Locale('en'));
        final result = MarkdownExporter.generate(group, localization);
        expect(result, equals(''));
      },
    );

    test('Amounts use the decimal separator of the language', () {
      final anna = ExpenseParticipant(id: 'a', name: 'Anna');
      final food = ExpenseCategory(id: 'f', name: 'Food');
      final group = ExpenseGroup(
        title: 'Rome',
        expenses: [
          ExpenseDetails(
            name: 'Lunch',
            amount: 22.5,
            date: DateTime(2026, 11, 5),
            paidBy: anna,
            category: food,
          ),
        ],
        participants: [anna],
        categories: [food],
        currency: '€',
      );

      final it = lookupAppLocalizations(const Locale('it'));
      final en = lookupAppLocalizations(const Locale('en'));
      expect(MarkdownExporter.generate(group, it), contains('22,50 €'));
      expect(MarkdownExporter.generate(group, it), isNot(contains('22.50 €')));
      expect(MarkdownExporter.generate(group, en), contains('22.50 €'));
    });
  });
}
