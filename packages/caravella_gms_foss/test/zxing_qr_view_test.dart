import 'package:caravella_gms/src/zxing_qr_view.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// One back camera whose permission is always refused, as after "Don't
/// allow" on the system prompt.
class _RefusingCamera extends CameraPlatform {
  int asked = 0;

  @override
  Future<List<CameraDescription>> availableCameras() async => const [
    CameraDescription(
      name: '0',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    ),
  ];

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      const Stream.empty();

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings? mediaSettings,
  ) async {
    asked++;
    throw CameraException('CameraAccessDenied', 'Camera access denied.');
  }
}

void main() {
  late _RefusingCamera camera;

  setUp(() {
    camera = _RefusingCamera();
    CameraPlatform.instance = camera;
  });

  testWidgets('a refused camera is reported once and not asked again', (
    tester,
  ) async {
    var denied = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ZxingQrView(onDetect: (_) {}, onCameraDenied: () => denied++),
      ),
    );
    await tester.pump();
    expect(camera.asked, 1);
    expect(denied, 1);

    // The prompt pauses and resumes the app, and so does going away and
    // back: neither asks for the camera again.
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
      AppLifecycleState.paused,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pump();
    }
    expect(camera.asked, 1);
    expect(denied, 1);
  });

  testWidgets('a new key asks again', (tester) async {
    Widget view(Key key) => MaterialApp(
      home: ZxingQrView(key: key, onDetect: (_) {}),
    );
    await tester.pumpWidget(view(const ValueKey(0)));
    await tester.pump();
    await tester.pumpWidget(view(const ValueKey(1)));
    await tester.pump();
    expect(camera.asked, 2);
  });
}
