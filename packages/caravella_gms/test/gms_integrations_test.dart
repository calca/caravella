import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_gms/caravella_gms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gmsIntegrations exposes every Google-backed feature', () {
    expect(gmsIntegrations.isAvailable, isTrue);
    expect(gmsIntegrations.supportsBluetoothSync, isTrue);
    expect(gmsIntegrations.supportsQrScanning, isTrue);
    expect(gmsIntegrations.storeReview, isA<StoreReviewClient>());
    expect(gmsIntegrations.appUpdates, isA<AppUpdateIntegration>());
  });

  test('Cloud relay still honours ENABLE_GOOGLE_DRIVE_SYNC (off by default)',
      () {
    expect(gmsIntegrations.createCloudChannel(), isNull);
  });
}
