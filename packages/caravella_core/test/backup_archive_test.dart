import 'dart:convert';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ExpenseGroup group(String title) => ExpenseGroup(
    title: title,
    expenses: const [],
    participants: [ExpenseParticipant(name: 'Anna')],
    currency: '€',
  );

  test('a backup zip round-trips its groups', () {
    final bytes = BackupArchive.encode([group('Norway'), group('Home')]);
    final groups = BackupArchive.decode(bytes);
    expect(groups.map((g) => g.title), ['Norway', 'Home']);
    expect(groups.first.participants.single.name, 'Anna');
  });

  test('a bare JSON backup is read too', () {
    final json = utf8.encode(jsonEncode([group('Trip').toJson()]));
    expect(BackupArchive.decode(json, isZip: false).single.title, 'Trip');
  });

  test('an empty backup is rejected', () {
    expect(
      () => BackupArchive.decode(BackupArchive.encode(const [])),
      throwsFormatException,
    );
  });

  test('file names carry the date and time', () {
    expect(
      BackupArchive.fileNameFor(DateTime(2026, 10, 9, 7, 5, 3)),
      'caravella_backup_20261009_070503.zip',
    );
  });
}
