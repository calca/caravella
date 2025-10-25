import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/services/google_drive_backup_service.dart';

void main() {
  group('GoogleDriveBackupService', () {
    late GoogleDriveBackupService service;

    setUp(() {
      service = GoogleDriveBackupService();
    });

    test('should initialize correctly', () {
      expect(service, isNotNull);
      expect(service.isSignedIn, isFalse);
      expect(service.currentUser, isNull);
    });

    test('should handle sign out when not signed in', () async {
      // Should not throw when signing out while not signed in
      await expectLater(
        () => service.signOut(),
        returnsNormally,
      );
    });

    test('should throw when trying to upload without authentication', () async {
      await expectLater(
        () => service.uploadBackup(),
        throwsException,
      );
    });

    test('should throw when trying to download without authentication', () async {
      await expectLater(
        () => service.downloadBackup(),
        throwsException,
      );
    });

    test('should return false for hasBackupOnDrive when not signed in', () async {
      final hasBackup = await service.hasBackupOnDrive();
      expect(hasBackup, isFalse);
    });

    test('should return null for getBackupInfo when not signed in', () async {
      final backupInfo = await service.getBackupInfo();
      expect(backupInfo, isNull);
    });
  });
}