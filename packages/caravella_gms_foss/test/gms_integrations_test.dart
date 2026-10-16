import 'package:caravella_gms/caravella_gms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FOSS gmsIntegrations has no proprietary feature', () {
    expect(gmsIntegrations.isAvailable, isFalse);
    expect(gmsIntegrations.createPositionProvider(), isNull);
    expect(gmsIntegrations.createReceiptTextRecognizer(), isNull);
    expect(gmsIntegrations.storeReview, isNull);
    expect(gmsIntegrations.createCloudChannel(), isNull);
    expect(gmsIntegrations.supportsBluetoothSync, isFalse);
    expect(gmsIntegrations.createBluetoothChannel(), isNull);
    expect(gmsIntegrations.supportsQrScanning, isFalse);
    expect(gmsIntegrations.appUpdates, isNull);
  });
}
