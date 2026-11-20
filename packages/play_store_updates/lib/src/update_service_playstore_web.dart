// The web has no Play Store: the same names as update_service_playstore.dart,
// doing nothing, so the conditional import in update_service_factory.dart
// compiles for the browser.
import 'update_service_noop.dart';

void initializePlayStoreUpdatesLogger() {}

class PlayStoreUpdateService extends NoOpUpdateService {
  const PlayStoreUpdateService();
}

class PlayStoreUpdateNotifier extends NoOpUpdateNotifier {}
