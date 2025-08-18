import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';

// Integration test to verify export and import work together
void main() {
  group('Export-Import Integration Tests', () {
    test('exported ZIP should be importable and preserve data integrity', () async {
      const String fileName = 'expense_group_storage.json';
      const String originalData = '''
[
  {
    "id": "integration-test-1",
    "title": "Test Export-Import",
    "startDate": "2024-01-20",
    "endDate": "2024-01-22",
    "currency": "USD",
    "participants": [
      {"id": "p1", "name": "Person 1"},
      {"id": "p2", "name": "Person 2"}
    ],
    "expenses": [
      {
        "id": "e1",
        "name": "Test Expense",
        "amount": 50.0,
        "paidBy": {"id": "p1", "name": "Person 1"},
        "category": {"id": "c1", "name": "Food"},
        "date": "2024-01-20",
        "note": "Test note"
      }
    ],
    "categories": [{"id": "c1", "name": "Food"}],
    "timestamp": 1705708800000,
    "pinned": false,
    "archived": false
  }
]
''';

      final tempDir = Directory.systemTemp;
      
      // Step 1: Create original data file
      final originalFile = File('${tempDir.path}/$fileName');
      await originalFile.writeAsString(originalData);
      
      // Step 2: Simulate EXPORT - create ZIP using the NEW approach
      final archive = Archive();
      final fileBytes = await originalFile.readAsBytes();
      final archiveFile = ArchiveFile(fileName, fileBytes.length, fileBytes);
      archive.addFile(archiveFile);
      final zipData = ZipEncoder().encode(archive);
      
      final zipFile = File('${tempDir.path}/test_backup.zip');
      await zipFile.writeAsBytes(zipData);
      
      // Step 3: Simulate IMPORT - read ZIP using existing import logic
      final zipBytes = await zipFile.readAsBytes();
      final decodedArchive = ZipDecoder().decodeBytes(zipBytes);
      
      expect(decodedArchive.length, 1, reason: 'ZIP should contain exactly 1 file');
      
      bool fileFound = false;
      String? extractedContent;
      
      for (final file in decodedArchive) {
        if (file.name == fileName) {
          extractedContent = String.fromCharCodes(file.content as List<int>);
          fileFound = true;
          break;
        }
      }
      
      expect(fileFound, true, reason: 'Backup file should be found in archive');
      expect(extractedContent, isNotNull, reason: 'Extracted content should not be null');
      
      // Step 4: Verify data integrity
      
      // Compare as JSON to ignore whitespace differences
      final originalJson = jsonDecode(originalData);
      final extractedJson = jsonDecode(extractedContent!);
      
      expect(extractedJson, equals(originalJson), reason: 'Extracted data should match original data exactly');
      
      // Verify specific fields
      expect(extractedJson[0]['id'], equals('integration-test-1'));
      expect(extractedJson[0]['title'], equals('Test Export-Import'));
      expect(extractedJson[0]['expenses'][0]['amount'], equals(50.0));
      expect(extractedJson[0]['participants'].length, equals(2));
      
      // Cleanup
      await originalFile.delete();
      await zipFile.delete();
    });
  });
}