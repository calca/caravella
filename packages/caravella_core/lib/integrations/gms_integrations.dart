import 'package:material_ui/material_ui.dart';

import '../services/media/location_service_abstraction.dart';
import '../sync/channels/bluetooth_sync_channel.dart';
import '../sync/channels/cloud_relay_channel.dart';
import 'update_localizations.dart';

/// Features that need proprietary Google libraries (Play Services, ML Kit,
/// Play Core), behind one interface so the app never imports them directly.
///
/// Two packages implement it, both named `caravella_gms`:
/// - `packages/caravella_gms` — the real implementations (Play Store build);
/// - `packages/caravella_gms_foss` — nothing ([NoGmsIntegrations]), used by
///   the F-Droid build so none of those libraries end up in the APK.
///
/// Which one is compiled in is a build-time switch (`./build_variant.sh`,
/// see `docs/BUILD_VARIANTS.md`). The app installs the selected one into
/// [instance] at startup; every getter returns `null` when the feature is
/// not available in the build, and callers hide the matching UI.
abstract class GmsIntegrations {
  const GmsIntegrations();

  /// The integrations compiled into this build. Defaults to
  /// [NoGmsIntegrations] (also what tests get unless they override it).
  static GmsIntegrations instance = const NoGmsIntegrations();

  /// Whether this build includes Google Mobile Services integrations.
  bool get isAvailable;

  /// Device position via Google's fused location provider. `null` → the app
  /// uses the platform `LocationManager` instead.
  PositionProvider? createPositionProvider();

  /// On-device text recognition for receipt scanning. `null` → receipt
  /// scanning is hidden.
  ReceiptTextRecognizer? createReceiptTextRecognizer();

  /// Store in-app review prompt. `null` → the app never asks for a rating.
  StoreReviewClient? get storeReview;

  /// Cloud relay for sync (Google Drive). `null` → Cloud sync is hidden.
  /// Implementations still honour the `ENABLE_GOOGLE_DRIVE_SYNC` flag.
  CloudRelayChannel? createCloudChannel();

  /// Whether [createBluetoothChannel] can return a channel.
  bool get supportsBluetoothSync;

  /// A new Bluetooth sync channel, one per pairing session. `null` when
  /// [supportsBluetoothSync] is false.
  BluetoothSyncChannel? createBluetoothChannel();

  /// Whether [buildQrScanner] can build a scanner.
  bool get supportsQrScanning;

  /// Live camera view that calls [onDetect] with the raw text of every QR
  /// code it reads, and stops the camera once [paused] becomes true. `null`
  /// when [supportsQrScanning] is false.
  Widget? buildQrScanner({
    required ValueChanged<String> onDetect,
    bool paused = false,
  });

  /// In-app updates from the Play Store. `null` → no update checks.
  AppUpdateIntegration? get appUpdates;
}

/// [GmsIntegrations] with nothing in it: the F-Droid build and tests.
class NoGmsIntegrations extends GmsIntegrations {
  const NoGmsIntegrations();

  @override
  bool get isAvailable => false;

  @override
  PositionProvider? createPositionProvider() => null;

  @override
  ReceiptTextRecognizer? createReceiptTextRecognizer() => null;

  @override
  StoreReviewClient? get storeReview => null;

  @override
  CloudRelayChannel? createCloudChannel() => null;

  @override
  bool get supportsBluetoothSync => false;

  @override
  BluetoothSyncChannel? createBluetoothChannel() => null;

  @override
  bool get supportsQrScanning => false;

  @override
  Widget? buildQrScanner({
    required ValueChanged<String> onDetect,
    bool paused = false,
  }) => null;

  @override
  AppUpdateIntegration? get appUpdates => null;
}

/// Extracts the text of an image (a receipt photo).
abstract class ReceiptTextRecognizer {
  /// All text recognized in the image at [imagePath], lines separated by
  /// `\n`. Empty when nothing was found.
  Future<String> recognizeText(String imagePath);

  /// Releases the recognizer's native resources.
  Future<void> close();
}

/// The store's in-app review flow.
abstract class StoreReviewClient {
  Future<bool> isAvailable();

  Future<void> requestReview();

  Future<void> openStoreListing();
}

/// A [CloudRelayChannel] that needs the user to sign in to an account
/// (e.g. Google Drive).
abstract class CloudAccountChannel {
  /// Email of the signed-in account, or `null`.
  String? get signedInAccountEmail;

  /// Interactive sign-in. Returns whether it succeeded.
  Future<bool> signIn();

  /// Restores a previous session without UI. Returns whether it succeeded.
  Future<bool> restoreSession();

  Future<void> signOut();
}

/// Builds the bottom sheet the update prompt is shown in.
typedef UpdateSheetBuilder =
    Widget Function(
      BuildContext context, {
      required String title,
      required Widget child,
    });

/// Store-driven app updates.
abstract class AppUpdateIntegration {
  /// Runs the periodic automatic update check and, when an update is
  /// available, recommends it in a bottom sheet built by [sheetBuilder].
  Future<void> checkAndShowUpdateIfNeeded(
    BuildContext context,
    UpdateLocalizations localizations,
    UpdateSheetBuilder sheetBuilder,
  );

  /// The manual "Check for updates" card; [cardBuilder] wraps its content.
  Widget buildUpdateCheckWidget({
    required UpdateLocalizations localizations,
    required Widget Function(BuildContext, Widget) cardBuilder,
  });
}
