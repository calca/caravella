/// Caravella features that need proprietary Google libraries.
///
/// The app only uses [gmsIntegrations] (installed into
/// `GmsIntegrations.instance` at startup). The F-Droid build swaps this
/// package for `packages/caravella_gms_foss`, which has the same name and
/// exports the same [gmsIntegrations] with nothing in it — see
/// `docs/PACKAGE_CARAVELLA_GMS.md`.
library;

import 'package:caravella_core/caravella_core.dart';

import 'src/play_gms_integrations.dart';

export 'src/geolocator_position_provider.dart';
export 'src/in_app_review_client.dart';
export 'src/mlkit_receipt_text_recognizer.dart';
export 'src/mobile_scanner_qr_view.dart';
export 'src/nearby_bluetooth_sync_channel.dart';
export 'src/play_gms_integrations.dart';
export 'src/play_store_app_updates.dart';

/// The integrations of this build: the real Google implementations.
const GmsIntegrations gmsIntegrations = PlayGmsIntegrations();
