import 'dart:typed_data';

import 'package:caravella_gms/caravella_gms.dart';
import 'package:caravella_gms/src/zxing_qr_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zxing2/qrcode.dart';

/// A camera-like Y plane holding [text] as a QR code: [scale] pixels per
/// module, a quiet zone, and [padding] extra bytes at the end of each row
/// (the stride a camera driver adds).
QrFrame _frameWith(
  String text, {
  int scale = 4,
  int padding = 0,
  bool inverted = false,
}) {
  final matrix = Encoder.encode(text, ErrorCorrectionLevel.l).matrix!;
  const quiet = 4;
  final side = (matrix.width + 2 * quiet) * scale;
  final stride = side + padding;
  final dark = inverted ? 230 : 20;
  final light = inverted ? 20 : 230;
  final bytes = Uint8List(stride * side)..fillRange(0, stride * side, light);
  for (var y = 0; y < side; y++) {
    for (var x = 0; x < side; x++) {
      final mx = x ~/ scale - quiet;
      final my = y ~/ scale - quiet;
      final inside =
          mx >= 0 && my >= 0 && mx < matrix.width && my < matrix.height;
      if (inside && matrix.get(mx, my) == 1) bytes[y * stride + x] = dark;
    }
  }
  return QrFrame(bytes, side, side, stride);
}

void main() {
  const payload =
      '{"v":1,"device_id":"abc","host":"192.168.1.23","port":40400,'
      '"group_id":"g1","group_title":"Vacanza a Roma"}';

  test('decodes a QR code from a luminance plane', () {
    expect(decodeQrFrame(_frameWith(payload)), payload);
  });

  test('honours a row stride wider than the image', () {
    expect(decodeQrFrame(_frameWith(payload, padding: 64)), payload);
  });

  test('reads a light-on-dark code too (a phone in dark mode)', () {
    expect(decodeQrFrame(_frameWith(payload, inverted: true)), payload);
  });

  test('returns null when there is no code', () {
    final blank = Uint8List(320 * 240)..fillRange(0, 320 * 240, 128);
    expect(decodeQrFrame(QrFrame(blank, 320, 240, 320)), isNull);
  });

  test('the F-Droid integrations offer QR scanning', () {
    expect(gmsIntegrations.supportsQrScanning, isTrue);
    expect(
      gmsIntegrations.buildQrScanner(onDetect: (_) {}),
      isA<ZxingQrView>(),
    );
    expect(gmsIntegrations.supportsBluetoothSync, isFalse);
    expect(gmsIntegrations.isAvailable, isFalse);
  });
}
