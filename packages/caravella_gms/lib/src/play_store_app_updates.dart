import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:play_store_updates/play_store_updates.dart' as updates;

/// [AppUpdateIntegration] backed by the `play_store_updates` package (Play
/// Core in-app updates). The update service itself stays a no-op unless the
/// app is built with `--dart-define=ENABLE_PLAY_UPDATES=true`.
class PlayStoreAppUpdates implements AppUpdateIntegration {
  const PlayStoreAppUpdates();

  @override
  Future<void> checkAndShowUpdateIfNeeded(
    BuildContext context,
    UpdateLocalizations localizations,
    UpdateSheetBuilder sheetBuilder,
  ) => updates.checkAndShowUpdateIfNeeded(context, localizations, sheetBuilder);

  @override
  Widget buildUpdateCheckWidget({
    required UpdateLocalizations localizations,
    required Widget Function(BuildContext, Widget) cardBuilder,
  }) => updates.UpdateCheckWidget(
    localizations: localizations,
    cardBuilder: cardBuilder,
  );
}
