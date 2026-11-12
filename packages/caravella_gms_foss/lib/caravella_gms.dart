/// FOSS build of `caravella_gms`: no Google libraries.
///
/// Selected by `./build_variant.sh foss` (the F-Droid build). Every
/// proprietary feature is reported as unavailable and the app hides it, or
/// falls back to a free implementation: location uses the platform
/// `LocationManager`, and QR codes are read with CameraX + ZXing
/// ([ZxingQrView]). See `docs/PACKAGE_CARAVELLA_GMS.md`.
library;

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/widgets.dart';

import 'src/zxing_qr_view.dart';

export 'src/zxing_qr_view.dart' show ZxingQrView;

/// The integrations of this build: only a free QR scanner, so two F-Droid
/// installs can pair over Wi-Fi.
const GmsIntegrations gmsIntegrations = FossGmsIntegrations();

/// [NoGmsIntegrations] plus QR scanning without Google libraries.
class FossGmsIntegrations extends NoGmsIntegrations {
  const FossGmsIntegrations();

  @override
  bool get supportsQrScanning => true;

  @override
  Widget? buildQrScanner({
    required ValueChanged<String> onDetect,
    bool paused = false,
    VoidCallback? onCameraDenied,
  }) => ZxingQrView(
    onDetect: onDetect,
    paused: paused,
    onCameraDenied: onCameraDenied,
  );
}
