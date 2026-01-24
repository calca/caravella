import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:io_caravella_egm/main.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('smoke_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;

  @override
  Future<String?> getApplicationSupportPath() async => _tempDir;
}

void main() {
  testWidgets('App builds without crashing', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = _FakePathProvider();

    // Initialize SharedPreferences with mock values
    SharedPreferences.setMockInitialValues({});

    // Initialize PreferencesService before running the test
    await PreferencesService.initialize();

    // Initialize the repository
    ExpenseGroupRepositoryFactory.getRepository(useJsonBackend: true);

    await tester.pumpWidget(createAppForTest());

    // Pump once to build the widget tree
    await tester.pump();

    // Wait for the update check timer (1 second delay in HomePage)
    await tester.pump(const Duration(seconds: 1));

    // Verify MaterialApp is present (basic smoke test)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
