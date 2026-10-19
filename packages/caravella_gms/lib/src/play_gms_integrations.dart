import 'package:caravella_core/caravella_core.dart';
import 'package:google_drive_sync/google_drive_sync.dart';
import 'package:material_ui/material_ui.dart';

import 'geolocator_position_provider.dart';
import 'in_app_review_client.dart';
import 'mlkit_receipt_text_recognizer.dart';
import 'mobile_scanner_qr_view.dart';
import 'nearby_bluetooth_sync_channel.dart';
import 'play_store_app_updates.dart';

/// [GmsIntegrations] backed by Google Play Services, ML Kit and Play Core.
class PlayGmsIntegrations extends GmsIntegrations {
  const PlayGmsIntegrations();

  @override
  bool get isAvailable => true;

  @override
  PositionProvider? createPositionProvider() => GeolocatorPositionProvider();

  @override
  ReceiptTextRecognizer? createReceiptTextRecognizer() =>
      MlKitReceiptTextRecognizer();

  @override
  StoreReviewClient? get storeReview => const InAppReviewClient();

  // Still gated on --dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true.
  @override
  CloudRelayChannel? createCloudChannel() =>
      GoogleDriveSyncFactory.createCloudChannel();

  // Same flag as cloud sync (it shares its Google sign-in).
  @override
  CloudBackupStore? createCloudBackupStore() =>
      GoogleDriveSyncFactory.createBackupStore();

  @override
  bool get supportsBluetoothSync => true;

  @override
  BluetoothSyncChannel? createBluetoothChannel() =>
      NearbyBluetoothSyncChannel();

  @override
  bool get supportsQrScanning => true;

  @override
  Widget? buildQrScanner({
    required ValueChanged<String> onDetect,
    bool paused = false,
  }) => MobileScannerQrView(onDetect: onDetect, paused: paused);

  // The service behind it is still gated on --dart-define=ENABLE_PLAY_UPDATES.
  @override
  AppUpdateIntegration? get appUpdates => const PlayStoreAppUpdates();
}
