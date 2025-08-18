import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

// Mock expense group data for testing
const String mockExpenseData = '''
[
  {
    "id": "test-1",
    "title": "Test Trip",
    "startDate": "2024-01-01",
    "endDate": "2024-01-05",
    "currency": "EUR",
    "participants": [],
    "expenses": [],
    "categories": [],
    "timestamp": 1704067200000,
    "pinned": false,
    "archived": false
  }
]
''';

void main() {
  group('ZIP Backup Tests', () {
    test('should create non-empty ZIP file with expense data', () async {
      // Create a temporary file with mock data
      final tempDir = Directory.systemTemp;
      final testDataFile = File('${tempDir.path}/test_expense_data.json');
      await testDataFile.writeAsString(mockExpenseData);

      // Verify test file exists and has content
      expect(await testDataFile.exists(), true);
      expect(await testDataFile.length(), greaterThan(0));

      // Create ZIP using the same method as the fixed implementation
      final archive = Archive();
      final fileBytes = await testDataFile.readAsBytes();
      final archiveFile = ArchiveFile('expense_group_storage.json', fileBytes.length, fileBytes);
      archive.addFile(archiveFile);
      final zipData = ZipEncoder().encode(archive);
      
      final zipFile = File('${tempDir.path}/test_backup.zip');
      await zipFile.writeAsBytes(zipData);

      // Verify ZIP file was created and is not empty
      expect(await zipFile.exists(), true);
      expect(await zipFile.length(), greaterThan(22)); // Greater than empty ZIP size

      // Verify ZIP content by reading it back
      final zipBytes = await zipFile.readAsBytes();
      final decodedArchive = ZipDecoder().decodeBytes(zipBytes);
      
      expect(decodedArchive.length, 1);
      expect(decodedArchive.first.name, 'expense_group_storage.json');
      expect(decodedArchive.first.size, fileBytes.length);
      
      // Verify the content is correct
      final extractedContent = String.fromCharCodes(decodedArchive.first.content as List<int>);
      final expectedContent = await testDataFile.readAsString();
      expect(extractedContent, expectedContent);

      // Cleanup
      await testDataFile.delete();
      await zipFile.delete();
    });

    test('should handle empty file gracefully', () async {
      final tempDir = Directory.systemTemp;
      final emptyFile = File('${tempDir.path}/empty_data.json');
      await emptyFile.writeAsString('');

      // Create ZIP with empty file
      final archive = Archive();
      final fileBytes = await emptyFile.readAsBytes();
      final archiveFile = ArchiveFile('expense_group_storage.json', fileBytes.length, fileBytes);
      archive.addFile(archiveFile);
      final zipData = ZipEncoder().encode(archive);
      
      final zipFile = File('${tempDir.path}/empty_backup.zip');
      await zipFile.writeAsBytes(zipData);

      // Verify ZIP file structure is correct even with empty content
      expect(await zipFile.exists(), true);
      expect(await zipFile.length(), greaterThan(0));

      final zipBytes = await zipFile.readAsBytes();
      final decodedArchive = ZipDecoder().decodeBytes(zipBytes);
      
      expect(decodedArchive.length, 1);
      expect(decodedArchive.first.name, 'expense_group_storage.json');
      expect(decodedArchive.first.size, 0);

      // Cleanup
      await emptyFile.delete();
      await zipFile.delete();
    });
  });
}