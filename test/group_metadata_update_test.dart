import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/data/model/expense_group.dart';
import 'package:io_caravella_egm/data/expense_group_storage_v2.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('eg_test')
      .path;
  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();
  group('Group Metadata Update', () {
    setUp(() async {
      // Clean up any existing test data
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/expense_group_storage.json');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('updateGroupMetadata handles non-existent group gracefully', () async {
      // Try to update a group that doesn't exist
      final nonExistentGroup = ExpenseGroup(
        id: 'non-existent',
        title: 'Does Not Exist',
        expenses: [],
        participants: [],
        categories: [],
        timestamp: DateTime.now(),
        pinned: false,
        archived: false,
        currency: 'EUR',
      );

      // This should not throw an error
      await ExpenseGroupStorageV2.updateGroupMetadata(nonExistentGroup);

      // Verify the group still doesn't exist
      final retrievedGroup = await ExpenseGroupStorageV2.getTripById(
        'non-existent',
      );
      expect(retrievedGroup, isNull);
    });
  });
}
