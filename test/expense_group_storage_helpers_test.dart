import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/expense_group_storage_v2.dart';
import 'dart:io';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('repo_test')
      .path;
  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

void main() {
  // Ensure Flutter bindings are initialized for file/path provider usage in storage
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ExpenseGroupStorageV2 helpers', () {
    setUp(() async {
      ExpenseGroupStorageV2.clearCache();
      ExpenseGroupStorageV2.forceReload();
      // Provide a fake path provider so storage can access a temp dir
      PathProviderPlatform.instance = _FakePathProvider();
    });
  });
}
