import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../model/expense_group.dart';
import 'expense_group_repository.dart';
import 'storage_errors.dart';

/// Reads the groups out of `expense_group_storage.json`, where Caravella
/// kept its data before the SQLite database. Only [StorageMigrationService]
/// uses it, once, to move them into SQLite; nothing writes this file any
/// more.
class LegacyJsonGroupReader {
  /// The file's name in the app documents directory.
  static const fileName = 'expense_group_storage.json';

  /// Reads [path] instead of the documents directory's file (tests).
  LegacyJsonGroupReader({String? path}) : _path = path;

  final String? _path;

  Future<File> file() async {
    if (_path != null) return File(_path);
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  /// The groups in the file: empty when there's no file or it's blank, a
  /// failure when it can't be read, isn't a list of groups, or breaks the
  /// rules [ExpenseGroupValidator.validateDataIntegrity] checks.
  Future<StorageResult<List<ExpenseGroup>>> readGroups() async {
    try {
      final f = await file();
      if (!await f.exists()) return const StorageResult.success([]);
      final contents = await f.readAsString();
      if (contents.trim().isEmpty) return const StorageResult.success([]);

      final dynamic json = jsonDecode(contents);
      if (json is! List) {
        return StorageResult.failure(
          SerializationError(
            'Invalid JSON format: expected list at root level',
            details: 'Found ${json.runtimeType}',
          ),
        );
      }

      final groups = <ExpenseGroup>[];
      for (var i = 0; i < json.length; i++) {
        final data = json[i];
        if (data is! Map<String, dynamic>) {
          return StorageResult.failure(
            SerializationError(
              'Invalid group data at index $i: expected object',
              details: 'Found ${data.runtimeType}',
            ),
          );
        }
        try {
          groups.add(ExpenseGroup.fromJson(data));
        } catch (e) {
          return StorageResult.failure(
            SerializationError(
              'Failed to deserialize group at index $i',
              details: e.toString(),
              cause: e is Exception ? e : Exception(e.toString()),
            ),
          );
        }
      }

      final integrity = ExpenseGroupValidator.validateDataIntegrity(groups);
      if (integrity.isFailure) return StorageResult.failure(integrity.error!);
      return StorageResult.success(groups);
    } catch (e) {
      return StorageResult.failure(
        FileOperationError(
          'Failed to read the old JSON storage',
          details: e.toString(),
          cause: e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }
}
