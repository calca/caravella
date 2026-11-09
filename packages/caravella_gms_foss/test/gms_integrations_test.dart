import 'package:caravella_gms/caravella_gms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FOSS gmsIntegrations has no proprietary feature (QR scanning is free)', () {
    expect(gmsIntegrations.isAvailable, isFalse);
    expect(gmsIntegrations.createPositionProvider(), isNull);
    expect(gmsIntegrations.createReceiptTextRecognizer(), isNull);
    expect(gmsIntegrations.storeReview, isNull);
    expect(gmsIntegrations.createCloudChannel(), isNull);
    expect(gmsIntegrations.supportsBluetoothSync, isFalse);
    expect(gmsIntegrations.createBluetoothChannel(), isNull);
    // Read with CameraX + ZXing, see zxing_qr_decode_test.dart.
    expect(gmsIntegrations.supportsQrScanning, isTrue);
    expect(gmsIntegrations.appUpdates, isNull);
  });
}
