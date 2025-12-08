import 'package:flutter/material.dart';
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
  });
}
