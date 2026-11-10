import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ExpenseGroup aGroup(String title) => ExpenseGroup(
    title: title,
    expenses: const [],
    participants: [ExpenseParticipant(name: 'Anna')],
    currency: '€',
  );

  test('a backup zip round-trips its groups', () {
    final bytes = BackupArchive.encode([aGroup('Norway'), aGroup('Home')]);
    final groups = BackupArchive.decode(bytes);
    expect(groups.map((g) => g.title), ['Norway', 'Home']);
    expect(groups.first.participants.single.name, 'Anna');
  });

  test('a bare JSON backup is read too', () {
    final json = utf8.encode(jsonEncode([aGroup('Trip').toJson()]));
    expect(BackupArchive.decode(json, isZip: false).single.title, 'Trip');
  });

  test('an empty backup is rejected', () {
    expect(
      () => BackupArchive.decode(BackupArchive.encode(const [])),
      throwsFormatException,
    );
  });

  group('format version', () {
    List<int> bytesOf(Object json) => utf8.encode(jsonEncode(json));

    test('format 1 as an object is read', () {
      final json = bytesOf({
        'format': 1,
        'groups': [aGroup('Trip').toJson()],
      });
      expect(BackupArchive.decode(json, isZip: false).single.title, 'Trip');
    });

    test('a backup from a newer app is refused, not read with losses', () {
      final json = bytesOf({
        'format': 2,
        'groups': [aGroup('Trip').toJson()],
      });
      expect(
        () => BackupArchive.decode(json, isZip: false),
        throwsA(
          isA<NewerFormatException>().having((e) => e.version, 'version', 2),
        ),
      );
    });

    test('an object without format or groups is not a backup', () {
      expect(
        () => BackupArchive.decode(bytesOf({'groups': []}), isZip: false),
        throwsA(
          isA<FormatException>().having(
            (e) => e is NewerFormatException,
            'newer',
            false,
          ),
        ),
      );
    });

    test('this app still writes format 1 as a plain list', () {
      final bytes = BackupArchive.encode([aGroup('Trip')]);
      final archive = ZipDecoder().decodeBytes(bytes);
      final json = jsonDecode(
        utf8.decode(archive.files.single.content as List<int>),
      );
      expect(json, isA<List<dynamic>>());
    });
  });

  test('file names carry the date and time', () {
    expect(
      BackupArchive.fileNameFor(DateTime(2026, 10, 9, 7, 5, 3)),
      'caravella_backup_20261009_070503.zip',
    );
  });
}
