import 'package:flutter_test/flutter_test.dart';
import 'package:google_drive_sync/google_drive_sync.dart';

/// `ENABLE_GOOGLE_DRIVE_SYNC` is a compile-time `--dart-define`, so it can't
/// be flipped at test runtime — these tests only cover the default (unset)
/// state, which is what every build not explicitly opting in gets
/// (including `flutter test` itself). The `true` path is exercised by
/// actually building with the flag (see docs/GOOGLE_DRIVE_SYNC_SETUP.md's
/// manual smoke-test section).
void main() {
  group('GoogleDriveSyncFactory — default (flag unset)', () {
    test('isEnabled is false', () {
      expect(GoogleDriveSyncFactory.isEnabled, isFalse);
    });

    test('createCloudChannel returns null', () {
      expect(GoogleDriveSyncFactory.createCloudChannel(), isNull);
    });
  });

  test('ships the Web OAuth client ID that Android sign-in requires', () {
    // Without it every Android sign-in fails with "serverClientId must be
    // provided on Android" before the signing certificate is even checked.
    expect(
      GoogleDriveSyncFactory.serverClientId,
      matches(RegExp(r'^\d+-[a-z0-9]+\.apps\.googleusercontent\.com$')),
    );
  });
}
