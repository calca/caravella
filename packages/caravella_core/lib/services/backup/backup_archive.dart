import 'dart:convert';

import 'package:archive/archive.dart';

import '../../data/expense_group_storage_v2.dart';
import '../../data/newer_format_exception.dart';
import '../../model/expense_group.dart';

/// The backup file: every group as JSON in a zip (one entry named
/// [ExpenseGroupStorageV2.fileName]). Used by the file export / import in
/// Settings and by the cloud backup (Google Drive).
///
/// The JSON is `{"format": 2, "groups": [...]}`. Format 1 (up to 2.4.1) is
/// a bare list of groups, or the same object with `"format": 1`; [decode]
/// reads both and refuses a higher format, whose fields it would drop.
/// Format 2 added the groups' `payments` and `budget`; 2.4.1 refuses it
/// rather than restoring the groups without them.
class BackupArchive {
  BackupArchive._();

  /// Version of the backup format this app writes and can read.
  static const int formatVersion = 2;

  /// `caravella_backup_20261019_213000.zip`
  static String fileNameFor(DateTime time) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'caravella_backup_${time.year.toString().padLeft(4, '0')}'
        '${two(time.month)}${two(time.day)}_'
        '${two(time.hour)}${two(time.minute)}${two(time.second)}.zip';
  }

  /// The zip bytes for [groups].
  static List<int> encode(List<ExpenseGroup> groups) {
    final jsonBytes = utf8.encode(
      jsonEncode({
        'format': formatVersion,
        'groups': groups.map((g) => g.toJson()).toList(),
      }),
    );
    final archive = Archive()
      ..addFile(
        ArchiveFile(
          ExpenseGroupStorageV2.fileName,
          jsonBytes.length,
          jsonBytes,
        ),
      );
    return ZipEncoder().encode(archive);
  }

  /// A zip of every stored group, or `null` when there are none.
  static Future<List<int>?> createFromStorage() async {
    final groups = await ExpenseGroupStorageV2.getAllGroups();
    if (groups.isEmpty) return null;
    return encode(groups);
  }

  /// The groups in a backup: a zip from [encode] or, when [isZip] is false,
  /// the bare JSON file. Throws [FormatException] if there are none, and
  /// [NewerFormatException] if a newer app made it.
  static List<ExpenseGroup> decode(List<int> bytes, {bool isZip = true}) {
    late final String json;
    if (isZip) {
      final archive = ZipDecoder().decodeBytes(bytes);
      final entry = archive.findFile(ExpenseGroupStorageV2.fileName);
      if (entry == null) {
        throw const FormatException('Backup file not found in archive');
      }
      json = utf8.decode(entry.content as List<int>);
    } else {
      json = utf8.decode(bytes);
    }
    final decoded = jsonDecode(json);
    final List<dynamic> list;
    if (decoded is List<dynamic>) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final format = decoded['format'];
      if (format is! int || decoded['groups'] is! List<dynamic>) {
        throw const FormatException('Unrecognized backup file');
      }
      if (format > formatVersion) {
        throw NewerFormatException('Backup', format);
      }
      list = decoded['groups'] as List<dynamic>;
    } else {
      throw const FormatException('Unrecognized backup file');
    }
    final groups = list
        .map((j) => ExpenseGroup.fromJson(j as Map<String, dynamic>))
        .toList();
    if (groups.isEmpty) {
      throw const FormatException('No groups found in backup');
    }
    return groups;
  }

  /// Saves [groups] one by one, stopping at the first failure. Returns the
  /// groups saved and, if one failed, why.
  static Future<({List<ExpenseGroup> saved, String? error})> restore(
    List<ExpenseGroup> groups,
  ) async {
    final repository = ExpenseGroupStorageV2.repository;
    final saved = <ExpenseGroup>[];
    for (final group in groups) {
      final result = await repository.saveGroup(group);
      if (!result.isSuccess) {
        return (
          saved: saved,
          error:
              'Failed to save group "${group.title}": ${result.error?.message}',
        );
      }
      saved.add(group);
    }
    return (saved: saved, error: null);
  }
}
